Pod::Spec.new do |s|
  s.name        = 'FaceUnity'
  s.version     = '0.1.0-dev'
  s.license     = 'MIT'
  s.summary     = 'iOS face-beautification toolkit built upon FaceUnity Nama SDK and FULiveDemo.'
  s.homepage    = 'https://github.com/ElfSundae/FaceUnity'
  s.authors     = { 'Elf Sundae' => 'https://0x123.com' }
  s.source      = { :git => 'https://github.com/ElfSundae/FaceUnity.git', :tag => s.version }
  s.platform    = :ios, '9.0'

  s.static_framework = true

  s.default_subspec = 'Lite'

  s.subspec 'Core' do |ss|
    ss.resource = 'FaceUnity/FULiveDemo/Config/*'
    ss.resource_bundle = {
      'FaceUnity' => 'FaceUnity/**/*.{xib,xcassets}'
    }
    ss.dependency 'ESFramework', '~> 3.20'
    ss.dependency 'Masonry', '~> 1.1'
    ss.dependency 'SVProgressHUD', '~> 2.2'
  end

  # 相芯 SDK 的每个版本都有可能增加或删除美颜参数，为了防止不同的 Nama 版本所包含的
  # 美颜参数和本库所支持的参数不一致，所以给 Nama 依赖指定一个确切的版本号。

  s.subspec 'Lite' do |ss|
    ss.source_files = 'FaceUnity/**/*.{h,m}'
    ss.dependency 'FaceUnity/Core'
    ss.dependency 'Nama-lite', '6.6.0'
  end

  s.subspec 'Full' do |ss|
    ss.source_files = 'FaceUnity/**/*.{h,m}'
    ss.dependency 'FaceUnity/Core'
    ss.dependency 'Nama', '6.6.0'
  end
end
