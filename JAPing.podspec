#
# Be sure to run `pod lib lint JAPing.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JAPing'
  s.version          = '0.1.0'
  s.summary          = 'A usedful ping tool build by "Simple Ping"(Support swift 4), hope it can help you'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
JAPing contains a single ping tool and mutiple ping tools. Timeout configure have not implemented.
                       DESC

  s.homepage         = 'https://github.com/JadianZheng/JAPing'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JadianZheng' => 'jadianzheng@gmail.com' }
  s.source           = { :git => 'https://github.com/JadianZheng/JAPing.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '6.0'

  s.source_files = 'JAPing/Classes/**/*'
  
  # s.resource_bundles = {
  #   'JAPing' => ['JAPing/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
