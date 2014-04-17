Pod::Spec.new do |s|
  s.name             = "DMRequest"
  s.version          = "0.1.0"
  s.summary          = "iOS block based HTTP request library."
  s.homepage         = "https://github.com/JohnnyDevMode/dm-request"
  s.license          = 'MIT'
  s.author           = { "John Bailey" => "john@devmode.com" }
  s.source           = { :git => "https://github.com/JohnnyDevMode/dm-request.git", :tag => s.version.to_s }
  s.platform     = :ios, '5.0'
  s.requires_arc = true
  s.source_files = 'Classes/**/*.{h,m}'
end
