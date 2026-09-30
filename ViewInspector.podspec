
Pod::Spec.new do |s|

  s.name = "ViewInspector"
  s.version = "0.10.5"
  s.summary = "ViewInspector is a library for unit testing SwiftUI views."
  s.homepage = "https://github.com/nalexn/ViewInspector"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Alexey Naumov" => "a.naumov91@gmail.com" }

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.tvos.deployment_target = '15.0'
  #s.watchos.deployment_target = '9.0'
  s.swift_version = '5.9'
  s.framework = 'XCTest'
  s.source = { :git => "https://github.com/nalexn/ViewInspector.git", :tag => "#{s.version}" }

  s.source_files  = 'Sources/ViewInspector/**/*.swift'
  s.pod_target_xcconfig = { 'ENABLE_TESTING_SEARCH_PATHS' => 'YES' }

  s.test_spec 'Tests' do |unit|
    unit.source_files = 'Tests/ViewInspectorTests/**/*.swift'
    unit.resources = 'Tests/ViewInspectorTests/TestResources/**/*'
  end

end
