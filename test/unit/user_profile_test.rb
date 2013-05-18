require_relative 'base_test.rb'
class UserProfileTest < BaseTest
  TOKEN = "db245596-cb04-4cf7-9162-a0e6b5189aab"
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
    binding.pry
    
    @user_profile.mentions
  end
end
