Pod::Spec.new do |s|
  s.name             = "RPInstantAlpha"
  s.version          = "0.5.0"
  s.summary          = "Easily allow users to remove the background from an image"
  s.homepage         = "https://github.com/RobotsAndPencils/RPInstantAlpha"
  s.screenshots      = "http://f.cl.ly/items/3t1Q32101W1j1p251J0Z/demo.gif"
  s.license          = 'MIT'
  s.author           = { "Brandon Evans" => "brandon.evans@robotsandpencils.com" }
  s.source           = { :git => "https://github.com/RobotsAndPencils/RPInstantAlpha.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/RobotsNPencils'

  s.platform     = :osx, '10.9'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = ["Classes/**/*.xib"]

  s.public_header_files = 'Classes/**/*.h'
end