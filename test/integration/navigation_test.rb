require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest

  setup :set_salt
  
  def setup
    @user1 = User.create!(:email => "bob@example.com")
    @user2 = User.create!(:email => "alice@example.com")
  end

  test "fail if missing params" do
    id, timestamp, token = valid_token(@user1)

    post "/heroku/sso/login", :token => token
    assert_equal 302, status
    assert_equal "/unauthenticated", path

    post "/heroku/sso/login", :id => id
    assert_equal 302, status
    assert_equal "/unauthenticated", path

    post "/heroku/sso/login", :timestamp => timestamp
    assert_equal 302, status
    assert_equal "/unauthenticated", path

    post "/heroku/sso/login", :id => id, :timestamp => timestamp
    assert_equal 302, status
    assert_equal "/unauthenticated", path

    post "/heroku/sso/login", :token => token, :timestamp => timestamp
    assert_equal 302, status
    assert_equal "/unauthenticated", path

    post "/heroku/sso/login", :token => token, :id => id
    assert_equal 302, status
    assert_equal "/unauthenticated", path
  end

  test "fail if bad token" do
    id, timestamp, token = valid_token(@user1)

    post "/heroku/sso/login", :id => id, :timestamp => timestamp, :token => "someOtherToken"
    assert_equal 403, status
  end

  test "fail if old token" do
    id, timestamp, token = old_token(@user1)

    post "/heroku/sso/login", :id => id, :timestamp => timestamp, :token => token
    assert_equal 403, status
  end

  test "fail if old not found" do
    id, timestamp, token = valid_token(@user2)
    post "/heroku/sso/login", :id => id, :timestamp => timestamp, :token => token
    assert_equal 403, status
  end
  
  test "succeeds with valid token" do
    id, timestamp, token = valid_token(@user1)
    post "/heroku/sso/login", :id => id, :timestamp => timestamp, :token => token

    assert_equal 302, status
    assert_equal "/heroku/sso/login", path
    assert_redirected_to "/"
  end
  
private
  def set_salt
    # must match value in dummy app initializer
    @sso_salt = "happy day!"
  end

  def valid_token(user)
    timestamp = Time.now.to_i
    pre_token = "#{user.id}:#{@sso_salt}:#{timestamp}"
    [user.id, timestamp,  Digest::SHA1.hexdigest(pre_token).to_s]
  end
  
  def old_token(user)
    timestamp = Time.at(0).to_i
    pre_token = "#{user.id}:#{@sso_salt}:#{timestamp}"
    [user.id, timestamp,  Digest::SHA1.hexdigest(pre_token).to_s]
  end    
end

