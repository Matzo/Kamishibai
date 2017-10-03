#
# Be sure to run `pod lib lint Kamishibai.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Kamishibai'
  s.version          = '0.1.0'
  s.summary          = 'Kamishibai makes easy to create long tutorial.'
  s.description      = <<-DESC
    Manage progress of tutorial
    Support presenting transitioning of UIViewController
    Support push/pop transitioning of NavigationController
    Focus with animation where you want
    Support custom guide view
                       DESC

  s.homepage         = 'https://github.com/Matzo/Kamishibai'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ksk.matsuo@gmail.com' => 'ksk.matsuo@gmail.com' }
  s.source           = { :git => 'https://github.com/ksk.matsuo@gmail.com/Kamishibai.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ksk_matsuo'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Kamishibai/Classes/**/*'
end
