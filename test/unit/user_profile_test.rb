require_relative 'base_test.rb'
class UserProfileTest < BaseTest
  TOKEN = "2f801222-adf5-4a07-98aa-8caacc3da3cf"
  SECRET = "1337670d-f7fd-4066-a2e3-e440aec071ee"
  
  def setup
    @user_profile = LoginRadius::UserProfile.new({
      :token => TOKEN,
      :secret => SECRET,
      :async => false
    })
  end
  
  test "basic user profile login sync" do
    @user_profile = LoginRadius::UserProfile.new({
      :token => TOKEN,
      :secret => SECRET,
      :async => false
    })
    @user_profile.login
    assert_not_nil(@user_profile.id)
    assert_not_nil(@user_profile.provider)
    assert(@user_profile.authenticated?)
  end
  
  test "mentions" do
    @user_profile.login    
    assert(@user_profile.mentions.is_a?(Array))
  end
  
  test "timeline" do
    @user_profile.login    
    assert(@user_profile.timeline.is_a?(Array))
  end
  
  test "companies" do
    @user_profile.login
    assert(@user_profile.companies.is_a?(Array))
  end
  
  test "contacts" do
    @user_profile.login
    assert(@user_profile.contacts.is_a?(Array))
  end
end
