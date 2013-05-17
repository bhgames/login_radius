module LoginRadius
  class UserProfile
    attr_accessible :user_profile_hash, :secret, :token, :async
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

    # Auth against, and then fetch user profile data from LoginRadius SaaS
    #
    # @return [Boolean] True/False whether login successful or not.
    def login
      response = call_api("userprofile.ashx", {:token => token, :apisecrete => secret})
      unless response[:id].blank?   
        this.user_profile_hash = response
        return true
      end
      return false
    end

    # Generic GET call function that other submodules can use to hit the API.
    #
    # @param url [String] Target URL to fetch data from.
    # @param params [Hash] Parameters to send
    # @return data [Hash] Parsed JSON data from the call
    def call_api(url, params = {})
      url = API_ROOT+url
      
      if async
        #if async is true, we expect you to be using EM::Synchrony submodule and to be in an eventloop,
        #like with a thin server using the Cramp framework. Otherwise, this method blows up.
        response = EM::Synchrony.sync EventMachine::HttpRequest.new(url).aget :query => params
        response = response.body        
      else
        #synchronous version of the call.
        url_obj = URI.parse(url)
        response = JSON.parse(Net::HTTP.get(url_obj, params).body)
      end
      
      return JSON.parse(response)
    end

    def method_missing(method, *arguments, &block)
     
      if(user_profile_hash[method.to_sym])
        raise LoginRadius::Exception.new("Too many arguments! 0 only!") if arguments.size>0
        return user_profile_hash([method.to_sym])
      end

      super
    end
  end
end
