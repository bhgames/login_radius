module LoginRadius
  class UserProfile
    attr_accessor :secret, :token, :async
    API_ROOT = "https://hub.loginradius.com/"

    # Takes a hash of account secret, token, and connection type(net_http or em_http)
    # and uses it to auth against the LoginRadius API. Then it returns the Account object. The
    # async key is optional, if set to true, will use Em::HTTP instead of Net::HTTP.
    # 
    # @param opts [Hash] Must have keys :token, :secret, and :async(optional)
    # @return [LoginRadius::Account]
    def initialize(opts = {})
      self.token = opts[:token]
      self.secret = opts[:secret]
      self.async = opts[:async]
      raise LoginRadius::Exception.new("Invalid Request") unless token
      raise LoginRadius::Exception.new("Invalid Token") unless guid_valid?(token)
      raise LoginRadius::Exception.new("Invalid Secret") unless guid_valid?(secret)
    end

    # Takes a guid and returns whether or not it is valid.
    #
    # @param guid [String]
    # @return [Boolean]
    def guid_valid?(guid)
      guid.match(/^\{?[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}\}?$/i)
    end

    # Returns whether or not this object is authed.
    #
    # @return [Boolean]
    def authenticated?
      respond_to?(:id)
    end

    # Generic GET call function that other submodules can use to hit the API.
    #
    # @param url [String] Target URL to fetch data from.
    # @param params [Hash] Parameters to send
    # @return data [Hash] Parsed JSON data from the call
    def call_api(url, params = {})
      url = API_ROOT+url unless url.match(/^#{API_ROOT}/) #in case api root is included,
      #as would happen in a recursive redirect call.
      
      if async
        #TODO: Test async!
        #if async is true, we expect you to be using EM::Synchrony submodule and to be in an eventloop,
        #like with a thin server using the Cramp framework. Otherwise, this method blows up.
        response = EM::Synchrony.sync EventMachine::HttpRequest.new(url).aget :query => params
        response = response.body        
      else
        #synchronous version of the call.
        url_obj = URI.parse(url)
        url_obj.query = URI.encode_www_form(params)
        
        http = Net::HTTP.new(url_obj.host, url_obj.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.get(url_obj.request_uri)
        
        if response.is_a?(Net::HTTPTemporaryRedirect)
          #for some reason, we always get redirected when calling server first time.
          #so if we do, we scan body for the redirect url, and the scan returns
          #an array of arrays. So we grab the array we know has what we need,
          #and grab the first element.
          redirect_url_array = response.body.scan(/<a href=\"([^>]+)\">/i)[1]
          redirect_url = redirect_url_array.first
          return call_api(redirect_url, params) 
        end
      end
      
      unconverted_response_hash = JSON.parse(response.body)
      #it's all String keys in CamelCase above, so...
      converted_response_hash = Hash.lr_convert_hash_keys(unconverted_response_hash).symbolize_keys!
      
      return converted_response_hash
    end
    
    
    # Below is metaprogramming. This is what Ruby is magic for.
    # Since most API calls are similar, I define an interface for them.
    # You add a hash with these keys:
    # 
    # @param method [Symbol] Method's name
    # @param route [String] Route, ex. is "/users/:token/:secret" (:something is interpolated to be self.something)
    # @param params [Hash] Hash of params you wish to send to the route. If you use symbols for values, are interpolated.
    # @param key_success_check [Symbol] Key to check for in the response to see if it was successful. Ex, :id for login
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
        :params => {},
        :key_success_check => 0 #first timeline entry
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
      
        return response[method_info[:key_success_check]].blank?
      end
    end
  end
end
