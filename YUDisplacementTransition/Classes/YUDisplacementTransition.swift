//
//  YUDisplacementTransition.swift
//  Pods
//
//  Created by YuAo on 2019/1/5.
//

import MetalPetal
import VideoToolbox

public final class YUDisplacementTransition {
    
    public final class Filter: NSObject, MTIFilter {
        
        public var outputPixelFormat: MTLPixelFormat = .unspecified
        
        public var inputImage: MTIImage?
        
        public var inputTargetImage: MTIImage?
        
        public var inputDisplacementImage: MTIImage?
        
        public var displacementIntensity: Float = 1.0
        
        public var angle: Float = .pi / 4
        
        public var progress: Float = 0
        
        public var outputImage: MTIImage? {
            guard let image = self.inputImage, let targetImage = self.inputTargetImage, let displacementImage = self.inputDisplacementImage else {
                return nil
            }
            let fromSize = float2(Float(image.dimensions.width), Float(image.dimensions.height))
            let toSize = float2(Float(targetImage.dimensions.width), Float(targetImage.dimensions.height))
            let currentSize = max(mix(fromSize, toSize, t: self.progress), float2(1.0,1.0))
            return Filter.kernel.apply(toInputImages: [image, targetImage, displacementImage],
                                       parameters: ["progress": self.progress,
                                                    "intensity": self.displacementIntensity,
                                                    "angleSource": self.angle,
                                                    "angleTarget": self.angle - .pi],
                                       outputTextureDimensions: MTITextureDimensions(width: UInt(currentSize.x), height: UInt(currentSize.y), depth: 1),
                                       outputPixelFormat: outputPixelFormat)
        }
        
        private static let kernel = MTIRenderPipelineKernel(
            vertexFunctionDescriptor: MTIFunctionDescriptor(name: MTIFilterPassthroughVertexFunctionName),
            fragmentFunctionDescriptor: MTIFunctionDescriptor(name: "yuDisplacementTransitionFragmentShader", libraryURL: MTIDefaultLibraryURLForBundle(Bundle(for: Filter.self)))
        )
    }
    
    public struct Options {
        
        public var angle: Float = .pi / 4
        
        public var displacementIntensity: Float = 1
        
        public var duration: TimeInterval = 0.6
        
        public var timingFunction: (Float) -> Float = { p in
            let f = (p - 1);
            return f * f * f + 1;
        }
        
        public init() {
            
        }
    }
    
    private weak var driver: CADisplayLink?
    
    private var completion: ((Bool) -> Void)?
    
    private var updater: ((MTIImage) -> Void)?
    
    private var startTime: CFTimeInterval?
    
    private let options: Options
    
    private let filter = Filter()
    
    @discardableResult public init(from image: MTIImage, to targetImage: MTIImage, displacementMap displacement: MTIImage, options: Options, updater: @escaping (_ image: MTIImage) -> Void, completion: ((_ finished: Bool) -> Void)?) {
        self.options = options
        self.updater = updater
        self.completion = completion
        let driver = CADisplayLink(target: self, selector: #selector(render))
        driver.add(to: RunLoop.main, forMode: .common)
        self.driver = driver
        self.filter.inputImage = image
        self.filter.inputTargetImage = targetImage
        self.filter.inputDisplacementImage = displacement
        self.filter.displacementIntensity = options.displacementIntensity
        self.filter.angle = options.angle
    }
    
    @objc private func render(sender: CADisplayLink) {
        let startTime: CFTimeInterval
        if let time = self.startTime {
            startTime = time
        } else {
            startTime = sender.timestamp
            self.startTime = startTime
        }
        
        let progress = (sender.timestamp - startTime) / self.options.duration
        if progress >= 1 {
            self.driver?.invalidate()
            self.driver = nil
            self.updater = nil
            self.completion?(true)
            self.completion = nil
            return
        }
        
        let transitionProgress = self.options.timingFunction(Float(progress))
        self.filter.progress = transitionProgress
        if let outputImage = self.filter.outputImage {
            self.updater?(outputImage)
        }
    }
    
    public func cancel() {
        self.driver?.invalidate()
        self.driver = nil
        self.updater = nil
        self.completion?(false)
        self.completion = nil
    }
}

public final class YUCGImageDisplacementTransition {
    
    private var transition: YUDisplacementTransition!
    
    private let pixelBufferPool: MTICVPixelBufferPool
    
    private let context: MTIContext
    
    public enum Error: Swift.Error {
        case noMetalDeviceFound
    }
    
    @discardableResult public init(from image: CGImage, to targetImage: CGImage, displacementMap displacement: CGImage, options: YUDisplacementTransition.Options, updater: @escaping (_ image: CGImage) -> Void, completion: ((_ finished: Bool) -> Void)?) throws {
        
        if let device = MTLCreateSystemDefaultDevice() {
            self.context = try MTIContext(device: device)
        } else {
            throw Error.noMetalDeviceFound
        }
        
        func mtiImage(from cgImage: CGImage) -> MTIImage {
            return MTIImage(cgImage: cgImage, options: [.SRGB: false], isOpaque: false).unpremultiplyingAlpha()
        }
        
        // Ensure soure and target image have the same aspect ratio.
        assert(abs(Double(image.width)/Double(image.height) - Double(targetImage.width)/Double(targetImage.height)) < 0.01)
        
        self.pixelBufferPool = try MTICVPixelBufferPool(pixelBufferWidth: targetImage.width, pixelBufferHeight: targetImage.height, pixelFormatType: kCVPixelFormatType_32BGRA, minimumBufferCount: 10)
        
        self.transition = YUDisplacementTransition(from: mtiImage(from: image), to: mtiImage(from: targetImage), displacementMap: mtiImage(from: displacement), options: options, updater: { image in
            guard let pixelBuffer = try? self.pixelBufferPool.makePixelBuffer(allocationThreshold: 10) else {
                return
            }
            try? self.context.render(image, to: pixelBuffer, sRGB: false)
            var cgImage: CGImage?
            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
            if let cgImage = cgImage {
                updater(cgImage)
            }
        }, completion: completion)
    }
    
    @discardableResult public static func transition(from image: CGImage, to targetImage: CGImage, displacementMap displacement: CGImage, options: YUDisplacementTransition.Options, updater: @escaping (_ image: CGImage) -> Void, completion: ((_ finished: Bool) -> Void)?) throws -> YUCGImageDisplacementTransition {
        return try YUCGImageDisplacementTransition(from: image, to: targetImage, displacementMap: displacement, options: options, updater: updater, completion: completion)
    }
    
    public func cancel() {
        self.transition.cancel()
    }
}

public final class YUViewControllerDisplacementTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let options: YUDisplacementTransition.Options

    private let displacementMap: CGImage
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.options.duration
    }
    
    private var transition: YUDisplacementTransition!

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to), let toViewController = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView
        UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, false, UIScreen.main.nativeScale)
        containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
        let currentSnapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetCurrentContext()?.clear(containerView.bounds)
        toView.frame = transitionContext.finalFrame(for: toViewController)
        containerView.addSubview(toView)
        fromView.alpha = 0
        containerView.drawHierarchy(in: containerView.bounds, afterScreenUpdates: true)
        let finalSnapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        fromView.alpha = 1
        toView.alpha = 0
        
        let renderView = MTIImageView(frame: containerView.bounds)
        renderView.clearColor = MTLClearColorMake(0, 0, 0, 0)
        renderView.isOpaque = false
        containerView.addSubview(renderView)
        
        func mtiImage(from cgImage: CGImage) -> MTIImage {
            return MTIImage(cgImage: cgImage, options: [.SRGB: false], isOpaque: false).unpremultiplyingAlpha()
        }
        
        guard let fromCGImage = currentSnapshotImage?.cgImage, let toCGImage = finalSnapshotImage?.cgImage else {
            transitionContext.completeTransition(true)
            return
        }
        
        self.transition = YUDisplacementTransition(from: mtiImage(from: fromCGImage), to: mtiImage(from: toCGImage), displacementMap: mtiImage(from: self.displacementMap), options: self.options, updater: { image in
            fromView.alpha = 0
            toView.alpha = 0
            renderView.image = image
        }, completion: { finished in
            toView.alpha = 1
            fromView.alpha = 1
            fromView.removeFromSuperview()
            renderView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
    
    public init(displacementMap displacement: CGImage, options: YUDisplacementTransition.Options) {
        self.options = options
        self.displacementMap = displacement
    }
}
