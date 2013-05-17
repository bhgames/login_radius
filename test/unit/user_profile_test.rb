require_relative 'base_test.rb'
class UserProfileTest < BaseTest
  test "basic user profile login sync" do
    user_profile = LoginRadius::UserProfile.new({
      :token => "token",
      :secret => "secret",
      :async => false
    })
    
    assert(!user_profile.id.blank?)
    assert_not_nil()
  end
end
