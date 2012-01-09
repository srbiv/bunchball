module Bunchball
  module Nitro
    class Actions < ApiBase
      CATEGORIES = [:unknown, :consume_content, :create_content, :information_sharing, :membership_activity]

      def self.create(name, params = {})
        params[:category] = Actions::CATEGORIES.index(params[:category]) if params[:category]
        params[:prefixMatch] = params[:prefixMatch] ? 1 : 0
        params[:lowSecurity] = params[:prefixMatch] ? 1 : 0

        Admin.create_action_tag(name, params)
      end

      def self.update(name, params = {})
        params[:category] = Actions::CATEGORIES.index(params[:category]) if params[:category]
        params[:prefixMatch] = params[:prefixMatch] ? 1 : 0
        params[:lowSecurity] = params[:prefixMatch] ? 1 : 0

        Admin.update_action_tag(name, params)
      end

      def self.all
        Admin.get_action_tags
      end

      # Log for currently logged in user
      def self.log(tags, params = {})
        User.log_action(current_user, tags, params)
      end

      # Log for any user
      def self.log_for_user(user_id, tags, params = {})
        User.log_action(user_id, tags, params)
      end

      def self.get_error_codes(params = {})
        response = post("server.getErrorCodes", params)
        response = Response.new(response)
        response.payload = response.nitro['errorCodeList']
        response
      end

      # Pings the server
      def self.hello
        response = post("hello")
        Bunchball::Nitro::Response.new(response)
      end

      def self.get_tag_id(tag_name)
        if (tag = self.all.select{|g| g['name'] == tag_name}.first)
          return tag['id']
        end
      end

      def self.status
        response = post("server.status")
        Bunchball::Nitro::Response.new(response)
      end

    end
  end
end