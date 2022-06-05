# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Chit-Chat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Chit-Chat
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'Firebase/Crashlytics'
pod 'Firebase/Analytics'

#Facebook Pods
pod 'FBSDKLoginKit'

#Google Pods
pod 'GoogleSignIn'

pod 'JGProgressHUD'
pod 'SDWebImage'
pod 'Toast-Swift', '~> 5.0.1'

# Agora
pod 'AgoraUIKit_iOS'
pod ‘AgoraRtm_iOS’

pod 'ChatMessageKit'

# Spinner
pod 'NVActivityIndicatorView'
    

  target 'Chit-ChatTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Chit-ChatUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end