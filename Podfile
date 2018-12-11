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

def defaults
    external
    internal
end

target 'PhotoEditor' do
  defaults

  target 'PhotoEditorKit' do
      inherit! :search_paths
  end

  target 'PhotoEditorTests' do
    inherit! :search_paths
    pod 'iOSSnapshotTestCase'
    pod 'EarlGrey'
    pod 'Nimble'
  end
  
  target 'PhotoEditorTodayWidget' do
      inherit! :search_paths
  end
end

