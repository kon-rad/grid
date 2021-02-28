# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# add pods for any other desired Firebase products
# https://firebase.google.com/docs/ios/setup#available-pods

target 'grid' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  pod 'Firebase/Core', :inhibit_warnings => true
  pod 'Firebase/Database', :inhibit_warnings => true
  pod 'Firebase/Auth', :inhibit_warnings => true
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'

  # Optionally, include the Swift extensions if you're using Swift.
  pod 'FirebaseFirestoreSwift'

  # Pods for grid
  pod 'GeoFire/Utils'
  
  target 'gridTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'gridUITests' do
    # Pods for testing
  end

end
