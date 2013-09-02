Warden::Strategies.add(:heroku_sso_authenticable) do
  def valid?
    # try this strategy if correct params are present
    !(params[:token].nil? || params[:id].nil? || params[:timestamp].nil?)
  end

  def authenticate! 
    fail!("invalid parameters") if !valid?
    fail!("bad token") if params[:timestamp].to_i < (Time.now - 2*60).to_i

    pre_token = params[:id] + ':' + DeviseHeroku.sso_salt + ':' + params[:timestamp]
    token = Digest::SHA1.hexdigest(pre_token).to_s

    fail!("bad token") if token != params[:token]

    resource = DeviseHeroku.resource.find(params[:id])
    if resource
      success!(resource) 
    else
      fail!("not found")
    end
  end 
end
