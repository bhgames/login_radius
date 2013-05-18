module LoginRadius
  class UserProfile
    attr_accessor :user_profile_hash, :secret, :token, :async
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
      self.user_profile_hash = call_api("userprofile.ashx", {:token => token, :apisecrete => secret})
      
      #define methods for each key in the hash, so they are accessible:
      #(I dont like using method missing returns because then respond_to? doesn't work)
      user_profile_hash.each do |key, value|
        define_singleton_method(key) do 
          return value
        end
      end
      
      return user_profile_hash[:id].blank?
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
  end
end
