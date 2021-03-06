$:.unshift(File.dirname(__FILE__))

require 'httparty'

require 'bunchball/version'

require 'bunchball/nitro/api_base'
require 'bunchball/nitro/actions'
require 'bunchball/nitro/actions_manager'
require 'bunchball/nitro/admin'
require 'bunchball/nitro/challenge'
require 'bunchball/nitro/group'
require 'bunchball/nitro/level'
require 'bunchball/nitro/notification'
require 'bunchball/nitro/response'
require 'bunchball/nitro/rule'
require 'bunchball/nitro/site'
require 'bunchball/nitro/user'

module Bunchball
  module Nitro
    class <<self
      attr_accessor :format, :api_key, :current_user
      attr_writer :session_key

      # Create little accessor methods for each manager class so
      # we can do like Bunchball::Nitro.actions and so on.  Don't
      # hate me because this is beautiful.  And inefficient.
      ['actions'].each do |method_name|
        define_method(method_name) do
          const_get(method_name.capitalize)
        end
      end

      def login(user_id, api_key = nil)
        @api_key ||= api_key
        authenticate(user_id, api_key)
      end

      def logout
        @api_key = nil
        @current_user = nil
        @session_key = nil
      end

      def authenticate(user_id, api_key = nil)
        @api_key ||= api_key
        response = HTTParty.post(endpoint, :body => {:method => "user.login", :userId => user_id, :apiKey => api_key || Bunchball::Nitro.api_key})

        if response['Nitro']['Error']
          puts "Got an error response from API in authenticate:"
          p response.inspect
          return nil
        end

        if response['Nitro']['Login']
          response['Nitro']['Login']['sessionKey']
        else
          puts "Not sure in authenticate:"
          p response.inspect
        end
      end

      def login_admin(user_id, password, api_key = nil)
        @api_key ||= api_key

        response = HTTParty.post(endpoint, :body => {:method => "admin.loginAdmin", :userId => user_id, :password => password, :apiKey => api_key || Bunchball::Nitro.api_key})
        if response['Nitro']['Error']
          puts "Got an error response from API in login_admin:"
          p response.inspect
          return nil
        end

        if response['Nitro']['Login']['sessionKey']
          current_user = user_id
          @session_key = response['Nitro']['Login']['sessionKey']
        else
          puts "Unexpected response from API in login_admin:"
          p response.inspect
        end
      end

      def session_key
        @session_key || raise("Not logged in!")
      end

      def async_token=(token)
        @async_token = token
      end

      def async_token
        @async_token || random_async_token
      end

      def random_async_token
        ([rand(10), rand(10), rand(10)] * 3).join("-#{rand(30)}")
      end

      def endpoint=(url)
        @endpoint = url
      end

      def endpoint
        @endpoint || "http://sandbox.bunchball.net/nitro/#{@format || 'json'}"
      end
    end
  end
end
