platform :ios, '11.0'
use_frameworks!

def external
    source 'https://github.com/CocoaPods/Specs.git'
    pod 'SnapKit'
    pod 'R.swift'
end

def internal
    source 'git@github.com:app-craft/internal-pods.git'
    pod 'AppCraftUtils/Core'
    pod 'AppCraftUtils/Interface'
end

target 'PhotoEditor' do
  internal
  external

  target 'PhotoEditorTests' do
    inherit! :search_paths
    pod 'iOSSnapshotTestCase'
  end

end
