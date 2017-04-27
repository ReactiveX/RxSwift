//: [Back](@previous)
/*:
 Follow these instructions to enable `RxSwift.Resources.total` in your project:
 #
 **CocoaPods**
 1. Add a `post_install` hook to your Podfile, e.g.:
 ```
 target 'AppTarget' do
 pod 'RxSwift'
 end
 
 post_install do |installer|
     installer.pods_project.targets.each do |target|
         if target.name == 'RxSwift'
             target.build_configurations.each do |config|
                 if config.name == 'Debug'
                     config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                 end
             end
         end
     end
 end
 ```
 2. Run `pod update`.
 3. Build project (**Product** → **Build**).
 #
 **Carthage**
 1. Run `carthage build --configuration Debug`.
 2. Build project (**Product** → **Build**).
 */
