require "faraday" # HTTP Client
require 'logger'

module Firim
  class Runner
    attr_accessor :options
    attr_reader :firim_client

    def self.firim_hostname
      return "http://api.fir.im/"
    end

    def initialize(options)
      self.options = options

      conn_options = {
       request: {
          timeout:       300,
          open_timeout:  300
        }
      }

      @firim_client = Faraday.new(self.class.firim_hostname, conn_options) do |c|
        c.response :json, content_type: /\bjson$/
        c.request  :url_encoded             # form-encode POST params
        c.response :logger                  # log requests to STDOUT
        c.response :json
        c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      Firim::DetectValues.new.run!(self.options)
      FastlaneCore::PrintTable.print_values(config: options, title: "firim #{Firim::VERSION} Summary")
    end

    def run
      FastlaneCore::PrintTable.print_values(config: get_app_info, title: "Current online infomation")

    end

    def validation_response response_data
      if response_data[:errors][:code] == 100020
        UI.user_error!("Firim API Token(#{options[:firim_api_token]}) not correct")
      end
    end

    def get_app_info
      app_info_path = "apps/latest/" + options[:app_identifier]
      response = self.firim_client.get app_info_path, { :api_token => options[:firim_api_token], :type => "ios" }
      info = response.body
      validation_response info
      info
    end

    def upload_binary_and_icon
      upload_publish_path = "apps/"
      response = self.firim_client.get app_info_path, { :api_token => options[:firim_api_token], :type => "ios" }
      response = self.firim_client.post do |req|
        req.url = upload_publish_path
        req.headers['Content-Type'] = 'application/json'
        req.body = { :type => 'ios', :bundle_id => options[:app_identifier], :api_token => options[:firim_api_token] }
      end
      info = response.body
      validation_response info

      unless info[:cert][:icon] && info[:cert][:binary]
        upload_binary info[:cert][:binary]
        upload_icon info[:cert][:icon]
      else
        raise UI.user_error!("Firim Server error #{info}")
      end

    end

    def get_upload_conn
      conn_options = {
       request: {
          timeout:       1000,
          open_timeout:  300
        }
      }
      Faraday.new(:options => conn_options) do |c|
        c.response :json, content_type: /\bjson$/
        c.request  :url_encoded             # form-encode POST params
        c.response :logger                  # log requests to STDOUT
        c.response :json
        c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def upload_binary binary_info
      binary_conn = get_upload_conn
      options = {
        key: binary_info[:key],
        token: binary_info[:token],
        file: Faraday::UploadIO.new(self.options[:ipa], 'application/octet-stream'),
        'x:name': self.options[:app_name],
        'x:version': self.options[:app_version],
        'x:build': self.options[:app_build_version]
      }
      options['x:release_type'] = self.options[:app_release_type] if self.options[:app_release_type]
      options['x:changelog'] = self.options[:app_changelog] if self.options[:app_changelog]
      response = binary_conn binary_info[:upload_url], options
      unless response[:is_completed]
        raise UI.user_error!("Upload binary to Qiniu error #{response}")
      end
    end

    def upload_icon icon_info
      return unless self.options[:app_icon]
      binary_conn = get_upload_conn
      options = {
        key: icon_info[:key],
        token: icon_info[:token],
        file: Faraday::UploadIO.new(self.options[:app_icon], 'image/x-png'),
      }
      response = binary_conn icon_info[:upload_url], options
      unless response[:is_completed]
        raise UI.user_error!("Upload icon to Qiniu error #{response}")
      end
    end

  end
end