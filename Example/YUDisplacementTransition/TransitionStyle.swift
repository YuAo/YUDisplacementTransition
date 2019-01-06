//
//  TransitionStyle.swift
//  YUDisplacementTransition_Example
//
//  Created by YuAo on 2019/1/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

struct TransitionStyle {
    var duration: TimeInterval
    var intensity: Float
    var angle: Float
    var displacementMap: CGImage
    
    static let a = TransitionStyle(duration: 1.2, intensity: -0.65, angle: .pi/4, displacementMap: UIImage(named: "M1")!.cgImage!)
    
    static let b = TransitionStyle(duration: 1.6, intensity: 0.2, angle: .pi/4, displacementMap: UIImage(named: "M2")!.cgImage!)
    
    static let c = TransitionStyle(duration: 0.7, intensity: -0.4, angle: .pi/4, displacementMap: UIImage(named: "M3")!.cgImage!)
    
    static let d = TransitionStyle(duration: 0.8, intensity: 0.9, angle: .pi/4, displacementMap: UIImage(named: "M4")!.cgImage!)

    static let e = TransitionStyle(duration: 1.0, intensity: 0.7, angle: .pi/4, displacementMap: UIImage(named: "M5")!.cgImage!)
    
    static let f = TransitionStyle(duration: 1.0, intensity: 0.3, angle: .pi/4, displacementMap: UIImage(named: "M6")!.cgImage!)

    static let g = TransitionStyle(duration: 1.0, intensity: 0.25, angle: .pi/4, displacementMap: UIImage(named: "M7")!.cgImage!)

    static let h = TransitionStyle(duration: 1.0, intensity: 0.1, angle: .pi/2, displacementMap: UIImage(named: "M8")!.cgImage!)
    
    static let styles: [TransitionStyle] = [.a, .b, .c, .d, .e, .f, .g, .h]
}
