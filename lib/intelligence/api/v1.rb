# frozen_string_literal: true

module Intelligence
  class API
    class V1 < Grape::API
      LIB = Intelligence::V1::Email

      version 'v1', using: :path
      format :json
      prefix :api

      default_error_status 400
      rescue_from Grape::Exceptions::ValidationErrors, ->(e) { show_error!(e) }
      rescue_from :all, ->(e) { show_error!(e) }

      helpers do
        def fetch_data(email, *fields)
          email = Base64.decode64(email)
          info = LIB.new(email)
          info.fetch(*fields)
          info.data
        end

        def show_error!(err)
          error! "#{err.class} - #{err.message}\n- #{err.backtrace.join("\n- ")}", 400
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
        # requires :str, type: String, desc: 'Base64 encoded email value.'
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
        fetch_data params[:str], *params[:fields]
      end

      route :any, '*path' do
        error!({ message: 'Not Found', with: Intelligence::API::Error }, 404)
      end
    end
  end
end
