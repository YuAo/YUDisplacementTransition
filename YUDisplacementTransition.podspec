#
# Be sure to run `pod lib lint YUDisplacementTransition.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YUDisplacementTransition'
  s.version          = '1.0'
  s.summary          = 'A GPU accelerated displacement transition library.'

  s.description      = <<-DESC
  A GPU accelerated transition library which makes use of displacement maps to create distortion effects.
                       DESC

  s.homepage         = 'https://github.com/yuao/YUDisplacementTransition'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yuao' => 'me@imyuao.com' }
  s.source           = { :git => 'https://github.com/yuao/YUDisplacementTransition.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'YUDisplacementTransition/Classes/**/*'
  
  s.dependency 'MetalPetal/Swift'
  
  s.swift_version = '5.0'
  
end
