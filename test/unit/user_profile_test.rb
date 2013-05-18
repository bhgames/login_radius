require_relative 'base_test.rb'
class UserProfileTest < BaseTest
  TOKEN = "2bcd37ec-6ceb-4770-90ba-80ea2df53e7e"
  SECRET = "1337670d-f7fd-4066-a2e3-e440aec071ee"
  test "basic user profile login sync" do
    user_profile = LoginRadius::UserProfile.new({
      :token => TOKEN,
      :secret => SECRET,
      :async => false
    })
    user_profile.login
    binding.pry
    assert_not_nil(user_profile.id)
    assert_not_nil(user_profile.provider)
  end
end
