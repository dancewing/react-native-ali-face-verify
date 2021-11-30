
require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "RNAliFaceVerify"
  s.version      = package["version"]
  s.summary      = "RNAliFaceVerify"
  s.description  = <<-DESC
                  RNAliFaceVerify
                   DESC
  s.homepage     = "https://github.com/dancewing"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/author/RNAliFaceVerify.git", :tag => "v#{s.version}" }
  s.source_files  = "RNAliFaceVerify/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React-Core"

  #s.dependency "others"

end

