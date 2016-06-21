Pod::Spec.new do |s|
s.name         = "QRManager"
s.version      = "0.0.1"
s.summary      = '二维码扫描和生成'
s.homepage     = "https://github.com/suxiangxiao/QRManager"
s.license      = 'MIT'
s.author       = {'kbo' => '13751882497.com'}
s.source       = { :git => 'https://github.com/suxiangxiao/QRManager'}
s.platform     = :ios
s.source_files = 'QRManager/*.{h,m}'
s.resources    = 'QRManager/*.{png}'
#s.frameworks = '*.helloFramework/helloFramework'
end
