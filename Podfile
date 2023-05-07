# Uncomment the next line to define a global platform for your project

inhibit_all_warnings!
platform :ios, '9.0'

target 'SamaraCounter' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Izumrud

  # Networking
  pod 'Alamofire'
  pod 'PromiseKit'
  pod 'CodableAlamofire'

  # User Data
  pod 'KeychainAccess'

  # Data base
  pod 'RealmSwift', '= 10.32.3'

  # UI
  pod 'Charts', :git => 'https://github.com/corteggo/Charts', :tag => 'v3.6.1'
  pod 'BxInputController/Common'
  #pod 'BxInputController/Photo' need rights in Info.plist
  
  # XML
  pod 'Fuzi'
  pod 'XMLDictionary'
  
  # Progress
  pod 'RSLoadingView'
  pod 'GTProgressBar'
  pod 'CircularSpinner', :git => 'https://github.com/Altarix/CircularSpinner.git'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

