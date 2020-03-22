# frozen_string_literal: true

module Intelligence
  module V1
    class Email
      attr_reader :email, :data
      AVAILABLE = %i[basic smtp gravatars].freeze
      EMAIL_FIELDS = %i[canonical provided corrected normal].freeze

      def initialize(str)
        @data  = {}
        @email = str
      end

      def fetch(*fields)
        fields = fields.map(&:to_sym)
        fields = AVAILABLE if fields.empty?
        fields = AVAILABLE & fields

        fields.each do |field|
          send("fetch_#{field}") if respond_to?("fetch_#{field}")
        end

        add_key :success, success?
        sanitize_data
        self
      end

      def fetch_basic
        add_var :provided, @email
        add_var :corrected, fetch_replacement, replace: true
        add_email_info :tag, :normal, :canonical

        @email = data[:canonical]
        add_email_info :mailbox, :provider, :host_name
        add_key :temporary, temporary?
      end

      def fetch_smtp
        check_smtp
        parse_smtp_debug
        data[:smtp_debug] = data[:smtp_debug].first if data[:smtp_debug]
      end

      def fetch_gravatars
        add_key :gravatars, try_gravatars # .reject(&:empty?)
      end

      def errored?
        data[:errors] && !data[:errors].empty?
      end

      def success?
        return false if errored?
        return true unless data[:smtp_debug]
        return false if data[:smtp_debug]['errors']

        data[:smtp_debug].values_at('port_opened', 'connection', 'rcptto', 'helo', 'mailfrom').all?
      end

      def sanitize_data
        invalid   = data[:errors][:smtp] && data[:errors][:smtp] == 'smtp error'
        invalid ||= data[:smtp_debug] && data[:smtp_debug][:errors]
        invalid &&= !data[:success]
        return unless invalid

        data[:errors][:smtp] = data[:smtp_debug][:errors].values.first.to_s.strip
        return unless data[:errors][:smtp].empty?

        values = data[:smtp_debug].slice(:port_opened, :connection, :rcptto, :helo, :mailfrom)
        data[:errors][:smtp] = values.reject { |_k, v| v.nil? }.reject { |_k, v| v }.map { |k, _v| "#{k}=false" }.join(' ')
      end

      protected

      def fetch_replacement
        data = EmailInquire.validate(email)
        data.hint? ? data.replacement : email
      end

      def temporary?
        EmailInquire.validate(email).invalid? || !MailChecker.valid?(email)
      end

      def check_smtp
        fields = %i[success domain mail_servers errors smtp_debug]
        info = Truemail.validate(email, with: :smtp).result
        fields.each do |key|
          val = info[key]
          val = (data[key] || {}).merge(info[key]) if key == :errors
          add_key key, val
        end
      end

      def parse_smtp_debug
        data[:smtp_debug] = (data[:smtp_debug] || []).map do |attempt|
          attempt.response.to_h.map do |k, v|
            [k, v.respond_to?(:message) ? v.message.strip : v]
          end.to_h
        end
      end

      def try_gravatars
        emails = data.values_at(*EMAIL_FIELDS).compact
        emails |= emails.map { |m| m.gsub(/\+.*?@/, '@') }
        emails.flatten.uniq.map { |m| Gravatar.new(m).fetch.data }
      end

      def add_email_info(*fields)
        info = EmailAddress.new(email)
        fields.each { |key| add_key key, info.send(key) }
        add_key :errors, check: info.error unless info.error.to_s.strip.empty?
      end

      private

      def add_key(key, value, replace: false)
        @email = value if replace
        data[key] = value
      end

      def add_var(key, value, replace: false)
        instance_variable_set("@#{key}", value)
        add_key key, value, replace: replace
      end
    end
  end
end
