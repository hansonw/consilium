class Mailer < PostageApp::Mailer
  DEFAULT_FROM = 'no-reply@scigit.com'

  default :from => DEFAULT_FROM

  def user_welcome(params = {})
    postageapp_template 'user_welcome'
    postageapp_variables params[:variables]

    mail(
      :to => {
        params[:to] => {},
      },
      :from => DEFAULT_FROM,
    )
  end
end
