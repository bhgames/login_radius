#Include this module in UserProfile, and UserProfile will magically have all the methods
#I dynamically generate below!
module LoginRadius
  module UserProfileMethods
    # Below is metaprogramming. This is what Ruby is magic for.
    # Since most API calls are similar, I define an interface for them.
    # You add a hash with these keys below, and it makes a method for them on loadup:
    # 
    # @param method [Symbol] Method's name
    # @param route [String] Route, ex. is "/users/:token/:secret" (:something is interpolated to be self.something)
    # @param params [Hash] Hash of params you wish to send to the route. If you use symbols for values, are interpolated.
    # @param key_success_check [Symbol] Key to check for in the response to see if it was successful. Ex, :id for login, if not set, whole response hash is returned instead of true/false
    # @return [Boolean] Whether or not it was successful.
    [
      {
        :method => :login, 
        :route => "userprofile.ashx", 
        :params => {:token => :token, :apisecrete => :secret}, 
        :key_success_check => :id
      },
      {
        :method => :mentions,
        :route => "status/mentions/:secret/:token",
        :params => {}
      },
      {
        :method => :company,
        :route => "GetCompany/:secret/:token",
        :params => {}
      },
      {
        :method => :contacts,
        :route => "contacts/:secret/:token",
        :params => {}
      }
    ].each do |method_info|
      define_method(method_info[:method]) do
        
        #when params have symbols as values, means we actually want fields on the object,
        #so we dynamically generate real params.
        real_params = method_info[:params].inject(Hash.new) do |hash, entry|
          hash[entry.first] = self.send(entry.last) 
          hash
        end

        #allows interpolation of routes - so /blah/:token becomes /blah/2323-233d3e etc.
        real_route = method_info[:route].gsub(/\/:(\w+)/) do |match|
          key = match.split(":").last
          "/"+self.send(key).to_s
        end
        response = call_api(real_route, real_params)

        if response.is_a?(Hash)
          #Special feature: If we get a hash back instead of an array,
          #we create methods on the user profile object for each key.
          #If we're just getting an array back, there is no need for this,
          #The method itself that it's called from is all that is needed to access
          #the data.

          #define methods for each key in the hash, so they are accessible:
          #(I dont like using method missing returns because then respond_to? doesn't work)
          response.each do |key, value|
            define_singleton_method(key) do 
              return value
            end
          end
        end

        #If the user wants to check for a particular key in the response hash to determine
        #whether or not call is successful, we use it. If they don't, then we return the response hash.
        return method_info[:key_success_check] ? response[method_info[:key_success_check]].blank? : response
      end
    end
  end
end