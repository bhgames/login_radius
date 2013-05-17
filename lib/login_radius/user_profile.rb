module LoginRadius
  class UserProfile
    attr_accessible :user_profile_hash, :secret, :token

    # Takes a hash of account secret, token, and connection type(net_http or em_http)
    # and uses it to auth against the LoginRadius API. Then it returns the Account object. If
    # both keys :net_http and :em_http exist and are set to true, :net_http is used by default.
    # 
    # @param opts [Hash] Must have keys :token, :secret, and :net_http/:em_http.
    # @return [LoginRadius::Account]
    def initialize(opts = {})
      self.token = opts[:token]
      self.secret = opts[:secret]
      
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
    # @return user_profile_hash [Hash] Returned user_profile hash from server(also saved to this Account object)
    def login
      
    end

    # Generic call function that other submodules can use to hit the API.
    #
    # @param url [String] Target URL to fetch data from.
    # @return data [Hash] Parsed JSON data from the call
    def call_api(url)

    end
  end
end
