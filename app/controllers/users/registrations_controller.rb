class Users::RegistrationsController < Devise::RegistrationsController
  def after_sign_up_path_for(resource)
    # TODO: Hack! We get this error if we use |app_root_path|:
    # In order to use #url_for, you must include routing helpers explicitly. For instance, `include Rails.application.routes.url_helpers
    '/app'
  end
end
