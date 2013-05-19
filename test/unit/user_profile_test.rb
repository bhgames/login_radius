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
    @user_profile.login
  end
  
  test "basic user profile login sync" do
    assert_not_nil(@user_profile.id)
    assert_not_nil(@user_profile.provider)
    assert(@user_profile.authenticated?)
  end
  
  test "mentions" do
    assert(@user_profile.twitter_mentions.is_a?(Array))
  end
  
  test "timeline" do
    assert(@user_profile.twitter_timeline.is_a?(Array))
  end
  
  test "companies" do
    assert(@user_profile.linked_in_companies.is_a?(Array))
  end
  
  test "contacts" do
    assert(@user_profile.contacts.is_a?(Array))
  end
  
  test "groups" do
    binding.pry
    
    assert(@user_profile.facebook_groups.is_a?(Array))
  end
end
