class DeviseHeroku::SsoController < DeviseController
  skip_before_action :verify_authenticity_token

  def create
    warden.logout(resource_name)
    self.resource = warden.authenticate!(:scope => resource_name)

    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)

    cookies['heroku-nav-data'] = params['nav-data']
    session[:heroku_app] = params[:app]
    redirect_to DeviseHeroku.redirect_path
  end
end
