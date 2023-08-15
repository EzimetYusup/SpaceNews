# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target 'DemoApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DemoApp
  # Redux pods
  pod 'ReSwift'
  pod 'ReSwiftThunk'
  pod "TinyConstraints"
  
  # Reactive pods
  pod 'CombineCocoa'

  # Diffing pods
#  pod 'DifferenceKit/UIKitExtension'

  #Image library
  pod 'SDWebImage'
  pod 'SwiftLint'
  target 'DemoAppTests' do
    inherit! :search_paths
    # Pods for testing
   pod 'ReSwiftThunk/ExpectThunk'
  end

  target 'DemoAppUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
             end
        end
 end
end
