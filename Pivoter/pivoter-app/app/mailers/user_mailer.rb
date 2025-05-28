class UserMailer < ActionMailer::Base
  default :from => "pivoterapp@gmail.com"

  def registration_confirmation(user)
  	 @user = user
  	mail(:to => user.email, :subject => "Registered")
  end
  def invite_user(current_user,guest,startup)
  	#@user = current_user
  	#@guest = guest
  	#@startup = startup
  	mail(:to => mail, :subject => "someone want to invite you to participate in a startup")
  	#mail(:to => mail, :subject => "#{@user.name} want to invite you to participate in a startup")

  end
end
