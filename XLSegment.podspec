Pod::Spec.new do |s|
  s.name         = "XLSegment"
  s.version      = "0.0.1"
  s.summary      = "A simple user segmentControl "
  s.license      = { :type => 'MIT License', :file => 'LICENSE' } # 协议
  s.homepage     = "https://github.com/sfmDev/XLSegment"
  s.author       = { "TBXark" => "https://github.com/sfmDev" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/sfmDev/XLSegment.git", :tag => s.version }
  s.source_files  = "XLSegmentControl/XLSegmentControl.swift"
  s.requires_arc = true
end
