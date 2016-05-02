Pod::Spec.new do |s|
  s.name         = "TTReflect"
  s.version      = "1.3.1"
  s.summary      = "TTReflect: swift - convert json with model easily"
  s.description  = <<-DESC
                  Swift: convert json with model easily, use data with grace way
                   DESC
  s.homepage     = "https://github.com/TifaTsubasa/TTReflect"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "TifaTsubasa" => "15922402179@163.com" }
  s.source       = { :git => "https://github.com/TifaTsubasa/TTReflect.git", :tag => s.version }
  s.source_files  = "TTReflect/**/*"
  s.platform     = :ios, "8.0"
  s.requires_arc = true

end
