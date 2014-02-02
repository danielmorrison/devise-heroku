#DeviseHeroku::Engine.routes.draw do
Rails.application.routes.draw do
  devise_scope :user do
    scope :module => "devise_heroku" do
      post "/heroku/sso/login" => "sso#create"
    end
  end
end