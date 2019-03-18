#
#  Be sure to run `pod spec lint MetalReFresh.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name         = "MetalReFresh"
s.version      = "0.7.7"
s.summary      = "It is a library using metal."
s.homepage     = "https://github.com/daisukenagata/MetalReFresh"
s.license      = { :type => "MIT"}
s.author             = { "daisukenagata" => "dbank0208@gmail.com" }
s.authors            = { "daisukenagata" => "dbank0208@gmail.com" }
s.social_media_url   = "http://twitter.com/daisukenagata"
s.platform     = :ios, "11.3"
s.ios.deployment_target = "11.3"
s.source       = { :git => "https://github.com/daisukenagata/MetalReFresh.git", :tag => "#{s.version}" }
s.source_files = 'Metal/**/*'
end
