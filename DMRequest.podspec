Pod::Spec.new do |s|
  s.name             = "DMRequest"
  s.version          = "0.0.5"
  s.summary          = "iOS block based HTTP request library."
  s.homepage         = "https://github.com/devmode/dm-request"
  s.license          = 'MIT'
  s.author           = { "John Bailey" => "john@devmode.com" }
  s.source           = { :git => "https://github.com/devmode/dm-request.git", :tag => s.version.to_s }
  s.platform     = :ios, '5.0'
  s.requires_arc = true
  s.source_files = 'Classes/**/*.{h,m}'
end
