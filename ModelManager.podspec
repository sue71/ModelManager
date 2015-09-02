Pod::Spec.new do |s|


  s.name         = "ModelManager"
  s.version      = "0.1.0"
  s.summary      = "Management Model which has Simple EventEmitter"

  s.homepage     = "https//github.com/sue71/ModelManager"
  s.license      = "MIT"
  s.author             = { "Masaki Sueda" => "s.masaki07@gmail.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "http://github.com/sue71/ModelManager.git", :tag => "0.1.0" }
  s.source_files  = "ModelManager/Classes", "ModelManager/Classes/*.swift"

end
