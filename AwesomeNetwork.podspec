#
# Be sure to run `pod lib lint AwesomeNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AwesomeNetwork'
  s.version          = '0.2.0'
  s.summary          = 'Network handling.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Network handling.
                       DESC

  s.homepage         = 'https://github.com/iOSWizards/AwesomeNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'evandro@itsdayoff.com' => 'evandro@itsdayoff.com' }
  s.source           = { :git => 'https://github.com/iOSWizards/AwesomeNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  
  # Platforms
  s.platforms = {
      :ios => '10.0',
      :osx => '10.10',
      :watchos => '4.0',
      :tvos => '10.0'
  }

  s.source_files = 'AwesomeNetwork/Classes/**/*.{swift}'
  
  # s.resource_bundles = {
  #   'AwesomeNetwork' => ['AwesomeNetwork/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RealmSwift'
end
