# frozen_string_literal: true

module Intelligence
  class API
    class V1 < Grape::API
      LIB = Intelligence::V1::Email

      version 'v1', using: :path
      format :json
      prefix :api

      default_error_status 400
      rescue_from Grape::Exceptions::ValidationErrors, ->(e) { error!(e, 400) }
      rescue_from :all, ->(e) { hide_error!(e) }

      helpers do
        def fetch_data(email, *fields)
          email = Base64.decode64(email)
          info = LIB.new(email)
          info.fetch(*fields)
          info.data
        end

        def show_error!(err)
          return hide_error!(err) if ENV['RACK_ENV'] == 'production'

          error! "#{err.class} - #{err.message}\n- #{err.backtrace.join("\n- ")}", 400
        end

        def hide_error!(_err)
          error! 'Encountered an error!', 500
        end
      end

      desc 'Fetches all available data for an email' do
        hidden false
        deprecated false
        nickname 'fetchAllEmailData'
        produces ['application/json']
        consumes ['application/json']
        success LIB
        tags %w[email validation smtp gravatars]
        failure [[401, 'Unauthorized', 'Intelligence::API::Error']]
      end
      params do
        auth = ENV['API_KEY'].present? ? :requires : :optional
        send auth, :api_key, type: String,
                             desc: 'API Key if set via environment variable'

        optional :fields, type: [String], default: [],
                          desc: 'Which fields/checks to keep in the response?',
                          values: {
                            value: LIB::AVAILABLE.map(&:to_s),
                            message: "must be in #{LIB::AVAILABLE.join(', ')}"
                          },
                          coerce_with: lambda { |v|
                            (v.is_a?(Array) ? v : v.split(',')).map(&:strip)
                          }
      end
      get 'fetch/:str' do
        if ENV['API_KEY'].present? && params[:api_key] != ENV['API_KEY']
          error!('Unauthorized', 401)
        end

        fetch_data params[:str], *params[:fields]
      end

      route :any, '*path' do
        error!({ message: 'Not Found', with: Intelligence::API::Error }, 404)
      end
    end
  end
end
