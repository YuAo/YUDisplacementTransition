//
//  ViewController.swift
//  YUDisplacementTransition
//
//  Created by yuao on 01/05/2019.
//  Copyright (c) 2019 yuao. All rights reserved.
//

import UIKit
import YUDisplacementTransition

class ImageTransitionViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    
    private let demoImages: [CGImage] = ["DemoImageA", "DemoImageB", "DemoImageC", "DemoImageD", "DemoImageE", "DemoImageF"].map({ UIImage(named: $0)!.cgImage! })
    
    private weak var transitionTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(cgImage: self.demoImages[0])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.transitionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { timer in
            self.performTransition()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.transitionTimer?.invalidate()
    }
    
    private var imageIndex = 0
    
    private var transitionStyleIndex = 0
    
    private func performTransition() {
        let nextImageIndex = (self.imageIndex + 1) % self.demoImages.count
        let transitionStyle = TransitionStyle.styles[self.transitionStyleIndex]
        var options = YUDisplacementTransition.Options()
        options.duration = transitionStyle.duration
        options.displacementIntensity = transitionStyle.intensity
        options.angle = transitionStyle.angle
        try! YUCGImageDisplacementTransition.transition(from: self.demoImages[self.imageIndex], to: self.demoImages[nextImageIndex], displacementMap: transitionStyle.displacementMap, options: options, updater: { image in
            self.imageView.image = UIImage(cgImage: image)
        }, completion: nil)
        self.imageIndex = nextImageIndex
        self.transitionStyleIndex = (self.transitionStyleIndex + 1) % TransitionStyle.styles.count
    }
    
}

