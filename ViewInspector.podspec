
Pod::Spec.new do |s|

  s.name = "ViewInspector"
  s.version = "0.8.1"
  s.summary = "ViewInspector is a library for unit testing SwiftUI views."
  s.homepage = "https://github.com/nalexn/ViewInspector"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Alexey Naumov" => "alexey@naumov.tech" }

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  #s.tvos.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.framework = 'XCTest'
  s.source = { :git => "https://github.com/nalexn/ViewInspector.git", :tag => "#{s.version}" }

  s.source_files  = 'Sources/ViewInspector/**/*.swift'

  s.test_spec 'Tests' do |unit|
    unit.source_files = 'Tests/ViewInspectorTests/**/*.swift'
    unit.resources = 'Tests/ViewInspectorTests/TestResources/**/*'
  end

end
