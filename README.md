# YUDisplacementTransition

[![Version](https://img.shields.io/cocoapods/v/YUDisplacementTransition.svg?style=flat)](https://cocoapods.org/pods/YUDisplacementTransition)
[![License](https://img.shields.io/cocoapods/l/YUDisplacementTransition.svg?style=flat)](https://cocoapods.org/pods/YUDisplacementTransition)
[![Platform](https://img.shields.io/cocoapods/p/YUDisplacementTransition.svg?style=flat)](https://cocoapods.org/pods/YUDisplacementTransition)

A GPU accelerated transition library which makes use of displacement maps to create distortion effects.

Inspired by [hover-effect](https://github.com/robin-dela/hover-effect).

Built with [MetalPetal](https://github.com/MetalPetal/MetalPetal).

## Example

<p>
    <img alt="example 1" src="https://raw.githubusercontent.com/robin-dela/hover-effect/master/gifs/1.gif" width="256">
    <img alt="example 2" src="https://raw.githubusercontent.com/robin-dela/hover-effect/master/gifs/2.gif" width="256">
</p>

To run the example project, clone the repo, and run `pod install` from the `Example` directory first.

## Usage

### Displacement Map

A displacement map is a image file used to create distortion effects for the transition.

### YUDisplacementTransition.Options

`displacementIntensity` Intensity of the distortion effect.

`duration` Transition duration.

`timingFunction` Timing function for the transition. Defaults: `CubicEaseOut`. More timing functions can be found at [AHEasing](https://github.com/warrenm/AHEasing/blob/master/AHEasing/easing.c).

`angle` The angle applied to the distortion effect, in radian.

### YUViewControllerDisplacementTransition

Conforms to `UIViewControllerAnimatedTransitioning` protocol, can be used in view controller transitions.

### YUCGImageDisplacementTransition

Can be used to transition between two `CGImage`s.

### YUDisplacementTransition

Can be used to transition between two `MTIImage`s.

## Installation

YUDisplacementTransition is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YUDisplacementTransition'
```

## Credits

Robin Dela for the javascript library [hover-effect](https://github.com/robin-dela/hover-effect).

Photos from [Unsplash](https://unsplash.com/).

[Live demo](https://tympanus.net/Development/DistortionHoverEffect/) by Codrops.

## License

YUDisplacementTransition is available under the MIT license. See the LICENSE file for more info.
