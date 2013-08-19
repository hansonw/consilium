class Mailer < PostageApp::Mailer
  DEFAULT_FROM = 'no-reply@scigit.com'

  default :from => DEFAULT_FROM

  def user_welcome(params = {})
    simple_mail(params[:token].nil? ? 'user_welcome' : 'user_welcome_activate', params)
  end

  def reset_password(params = {})
    simple_mail('reset_password', params)
  end

  private
    def simple_mail(template, params)
      postageapp_template template
      postageapp_variables params[:variables]

      mail(
        :to => {
          params[:to] => {},
        },
        :from => DEFAULT_FROM,
      )
    end
end
