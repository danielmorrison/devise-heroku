Warden::Strategies.add(:heroku_sso_authenticable) do
  def valid?
    # try this strategy if correct params are present
    !(params[:token].nil? || params[:id].nil? || params[:timestamp].nil?)
  end

  def authenticate! 
    if params[:timestamp].to_i < (Time.now - 2*60).to_i
      heroku_error_response "Expired Timestamp"
    elsif token != params[:token]
      heroku_error_response "Invalid Token"
    elsif resource = DeviseHeroku.resource.find(params[:id])
      success!(resource) 
    else
      heroku_error_response "Invalid User"
    end
  end

  private
  def heroku_error_response(body)
    custom!([403, {}, [body]])
  end

  def token
    pre_token = params[:id] + ':' + DeviseHeroku.sso_salt + ':' + params[:timestamp]
    Digest::SHA1.hexdigest(pre_token).to_s
  end
end
