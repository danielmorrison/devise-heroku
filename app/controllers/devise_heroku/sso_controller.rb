class DeviseHeroku::SsoController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter "authenticate_#{DeviseHeroku.resource.to_s.parameterize.underscore}!".to_sym

  def login
    cookies['heroku-nav-data'] = params['nav-data']
    session[:heroku_app] = params[:app]
    redirect_to DeviseHeroku.redirect_path
  end
end
