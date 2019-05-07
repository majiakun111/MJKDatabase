#
# Be sure to run `pod lib lint MJKActiveObject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name                      = 'MJKDatabase'
    s.version                   = '1.0.2'
    s.summary                   = 'Model direct save Database'
    s.description               = <<-DESC
                Model direct save Database. Simple Simple!!!!
                                DESC
    s.homepage                  = 'https://github.com/majiakun111/MJKDatabase'
    s.license                   = { :type => 'MIT', :file => 'LICENSE' }
    s.author                    = { 'majiakun111' => 'majiakun111@sina.cn' }
    s.source                    = { :git => 'https://github.com/majiakun111/MJKDatabase.git', :tag => s.version.to_s }
    s.platform                  = :ios, '8.0'
    s.ios.deployment_target     = '8.0'
    s.requires_arc              = true
    s.source_files              = 'MJKDatabase/Classes/**/*'

    s.dependency                'MJExtension'
end
