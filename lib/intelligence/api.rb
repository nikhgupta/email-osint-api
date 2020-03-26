# frozen_string_literal: true

require 'json'
require 'grape'
require 'faraday'
require 'mail_checker'
require 'email_inquire'
require 'email_address'
require 'proxifier'

module Intelligence
  class API < Grape::API
  end
end

require_relative '../extensions/net_smtp.rb'
require_relative '../../config/truemail.rb'
require_relative './v1/gravatar.rb'
require_relative './v1/email.rb'
require_relative './api/error.rb'
require_relative './api/v1.rb'

module Intelligence
  class API
    mount V1
  end
end
