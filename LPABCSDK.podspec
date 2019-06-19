Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "LPABCSDK"
s.summary = "LPABCSDK"
s.requires_arc = true

# 2
s.version = "1.0.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Omer Berher" => "oberger@liveperson.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "hhttps://developers.liveperson.com/apple-business-chat-sdk-overview.html"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/LivePersonInc/iOS-LPABC-SDK.git", 
             :tag => "#{s.version}" }

# 7
#s.framework = "UIKit"
#s.dependency 'Alamofire', '~> 4.7'
#s.dependency 'MBProgressHUD', '~> 1.1.0'

# 8
s.source_files = "LPABCSDK/**/*.{swift}"

# 9
s.resources = "LPABCSDK/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

end