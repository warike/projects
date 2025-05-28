class UserMailer < ActionMailer::Base
  default :from => "info@pivoter.cl"

  def enviar_invitacion(user, url)
    @user = user
    @numero_invitacion = 10 + user.id
    @url = url
    mail(:to => user.email, :subject => t("email_confirmation"))

  end
end
