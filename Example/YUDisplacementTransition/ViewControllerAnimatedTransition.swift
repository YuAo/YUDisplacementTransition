//
//  ViewControllerA.swift
//  YUDisplacementTransition_Example
//
//  Created by YuAo on 2019/1/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import YUDisplacementTransition

class ViewControllerA: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBAction private func back(segue: UIStoryboardSegue) {
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let toViewController as ViewControllerB:
            toViewController.transitioningDelegate = self
        default:
            break
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionStyle = TransitionStyle(duration: 0.6, intensity: 0.3, angle: -.pi/4, displacementMap: UIImage(named: "M6")!.cgImage!)
        var options = YUDisplacementTransition.Options()
        options.duration = transitionStyle.duration
        options.displacementIntensity = transitionStyle.intensity
        options.angle = transitionStyle.angle
        return YUViewControllerDisplacementTransition(displacementMap: transitionStyle.displacementMap, options: options)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionStyle = TransitionStyle(duration: 0.6, intensity: -0.3, angle: -.pi/4, displacementMap: UIImage(named: "M6")!.cgImage!)
        var options = YUDisplacementTransition.Options()
        options.duration = transitionStyle.duration
        options.displacementIntensity = transitionStyle.intensity
        options.angle = transitionStyle.angle
        return YUViewControllerDisplacementTransition(displacementMap: transitionStyle.displacementMap, options: options)
    }
    
}

class ViewControllerB: UIViewController {
    
}
