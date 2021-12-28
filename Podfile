# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source "https://github.com/CocoaPods/Specs.git"

target 'POCreCaptchaRenner' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for POCreCaptchaRenner
  pod 'ReCaptcha'
  pod 'lottie-ios'

end

post_install do |i|
  target = File.join(Dir.pwd, "../.git/hooks/pre-push")
  unless File.symlink?(target)
    puts "Installing git hook for pre-push"

    begin
      File.symlink(File.join(Dir.pwd, "../pre-push.sh"), target)
    rescue => exc
    end
  end
end
