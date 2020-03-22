# frozen_string_literal: true

module Intelligence
  module V1
    class Gravatar
      attr_reader :email

      def initialize(email)
        @email = email
        @data  = { email: email }
      end

      def md5
        @md5 ||= Digest::MD5.hexdigest(email)
      end

      def data
        (@data.keys - [:email]).any? ? @data : {}
      end

      def fetch
        info = try_gravatar

        return self if !info || info.empty?
        return self unless info.key?('entry')
        return self unless info['entry'].count.positive?

        extract_data info['entry'][0]
        self
      end

      protected

      def extract_data(info)
        @data[:id] = info['id']
        @data[:md5] = md5
        @data[:primary_md5] = info['hash']
        @data[:urls] = info['urls']

        @data[:username] = info['profileUrl'].split('/').last
        @data[:preferred_username] = info['preferredUsername']
        @data[:display_name] = info['displayName']

        return if !info['name'] || info['name'].empty?

        @data[:name] = info['name']['formatted']
        @data[:first_name] = info['name']['givenName']
        @data[:last_name] = info['name']['familyName']
      end

      private

      def try_gravatar
        response = Faraday.get "https://en.gravatar.com/#{md5}.json"
        response.status >= 300 ? nil : JSON.parse(response.body)
      rescue StandardError
        nil
      end
    end
  end
end
