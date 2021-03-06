require "ostruct"
require "openssl"
require "uri"
require "rest_client"
require "json"
require "securerandom"

require_relative "ibanity/util"
require_relative "ibanity/error"
require_relative "ibanity/collection"
require_relative "ibanity/client"
require_relative "ibanity/http_signature"
require_relative "ibanity/api/base_resource"
require_relative "ibanity/api/xs2a/account"
require_relative "ibanity/api/xs2a/transaction"
require_relative "ibanity/api/xs2a/financial_institution"
require_relative "ibanity/api/xs2a/account_information_access_request"
require_relative "ibanity/api/xs2a/customer_access_token"
require_relative "ibanity/api/xs2a/customer"
require_relative "ibanity/api/xs2a/payment_initiation_request"
require_relative "ibanity/api/xs2a/synchronization"
require_relative "ibanity/api/o_auth_resource"
require_relative "ibanity/api/isabel_connect/account"
require_relative "ibanity/api/isabel_connect/balance"
require_relative "ibanity/api/isabel_connect/transaction"
require_relative "ibanity/api/isabel_connect/account_report"
require_relative "ibanity/api/isabel_connect/access_token"
require_relative "ibanity/api/isabel_connect/refresh_token"
require_relative "ibanity/api/isabel_connect/bulk_payment_initiation_request"
require_relative "ibanity/api/sandbox/financial_institution_account"
require_relative "ibanity/api/sandbox/financial_institution_transaction"
require_relative "ibanity/api/sandbox/financial_institution_user"

module Ibanity
  class << self
    def client
      options = configuration.to_h.delete_if { |_, v| v.nil? }
      @client ||= Ibanity::Client.new(options)
    end

    def configure
      @client                    = nil
      @xs2a_api_schema           = nil
      @isabel_connect_api_schema = nil
      @sandbox_api_schema        = nil
      @configuration             = nil
      yield configuration
    end

    def configuration
      @configuration ||= Struct.new(
        :certificate,
        :key,
        :key_passphrase,
        :signature_certificate,
        :signature_certificate_id,
        :signature_key,
        :signature_key_passphrase,
        :client_id,
        :client_secret,
        :api_scheme,
        :api_host,
        :api_port,
        :ssl_ca_file
      ).new
    end

    def xs2a_api_schema
      @xs2a_api_schema ||= client.get(uri: "#{client.base_uri}/xs2a")["links"]
    end

    def sandbox_api_schema
      @sandbox_api_schema ||= client.get(uri: "#{client.base_uri}/sandbox")["links"]
    end

    def isabel_connect_api_schema
      @isabel_connect_api_schema ||= client.get(uri: "#{client.base_uri}/isabel-connect")["links"]
    end

    def respond_to_missing?(method_name, include_private = false)
      client.respond_to?(method_name, include_private)
    end

    def method_missing(method_name, *args, &block)
      if client.respond_to?(method_name)
        client.__send__(method_name, *args, &block)
      else
        super
      end
    end
  end
end
