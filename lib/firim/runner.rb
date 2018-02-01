require 'faraday' # HTTP Client
require 'faraday_middleware'
# require 'logger'

module Firim
  class Runner
    attr_accessor :options
    attr_reader :firim_client

    def self.firim_hostname
      return "http://api.fir.im/"
    end

    def initialize(options)
      self.options = options
      @app_info = {}

      conn_options = {
       request: {
          timeout:       300,
          open_timeout:  300
        }
      }

      @firim_client = Faraday.new(self.class.firim_hostname, conn_options) do |c|
        c.request  :url_encoded             # form-encode POST params
        c.adapter  :net_http
        c.response :json, :content_type => /\bjson$/
      end

      if self.options[:platform] == 'ios'
        Firim::DetectValues.new.run!(self.options)
      else
        Firim::DetectAndroidValues.new.run!(self.options)
      end

      FastlaneCore::PrintTable.print_values(config: options, title: "firim #{Firim::VERSION} Summary")
    end

    def run
      # FastlaneCore::PrintTable.print_values(config: get_app_info, title: "Current online infomation")
      @app_info.merge!( upload_binary_and_icon )
      @app_info.merge!( update_app_info(@app_info["id"]))
      write_app_info_to_file
      options = @app_info
      FastlaneCore::PrintTable.print_values(config: options, title: "#{@app_info["name"]}'s' App Info")
    end

    def write_app_info_to_file
      file_path = self.options[:app_info_to_file_path]
      return if file_path == nil
      File.open(file_path, "at") do |f|
        f.write("#{@app_info["name"]}: http://fir.im/#{@app_info["short"]} \n")
        UI.success "Write app info to #{file_path} successed!"
      end
    end

    def validation_response response_data
      error_code = response_data['code'].to_i rescue 0
      if error_code == 100020
        UI.user_error!("Firim API Token(#{options[:firim_api_token]}) not correct")
      end
    end

    def get_app_info
      app_info_path = "apps/latest/" + options[:app_identifier]
      response = self.firim_client.get app_info_path, { :api_token => options[:firim_api_token], :type => options[:platform] }
      info = response.body == nil ? {} : response.body
      validation_response info
      info
    end

    def upload_binary_and_icon
      upload_publish_path = "apps/"
      response = self.firim_client.post do |req|
        req.url upload_publish_path
        req.body = { :type => options[:platform], :bundle_id => options[:app_identifier], :api_token => options[:firim_api_token] }
      end
      info = response.body
      validation_response info
      begin
        upload_binary info['cert']['binary']
        upload_icon info['cert']['icon']
      rescue Exception => e
        # raise UI.user_error!("Firim Server error #{e}\n #{info}")
        raise e
      end
      info.select { |k, v| ["id", "type", "short"].include?(k) }
    end

    def get_upload_conn
      conn_options = {
       request: {
          timeout:       1000,
          open_timeout:  300
        }
      }
      Faraday.new(nil, conn_options) do |c|
        c.request :multipart
        c.request :url_encoded
        c.response :json, content_type: /\bjson$/
        c.adapter :net_http
      end
    end

    def upload_binary binary_info
      params = {
        'key' => binary_info['key'],
        'token' => binary_info['token'],
        'file' => Faraday::UploadIO.new(self.options[:file], 'application/octet-stream'),
        'x:name' => self.options[:app_name],
        'x:version' => self.options[:app_version],
        'x:build' => self.options[:app_build_version]
      }
      params['x:release_type'] = self.options[:app_release_type] if self.options[:app_release_type]
      params['x:changelog'] = self.options[:app_changelog] if self.options[:app_changelog]
      binary_conn = get_upload_conn
      UI.message "Start upload #{self.options[:app_name]} binary..."
      response = binary_conn.post binary_info['upload_url'], params
      unless response.body['is_completed']
        raise UI.user_error!("Upload binary to Qiniu error #{response.body}")
      end
      UI.success 'Upload binary successed!'
    end

    def upload_icon icon_info
      return unless self.options[:icon]
      binary_conn = get_upload_conn
      params = {
        'key' => icon_info['key'],
        'token' => icon_info['token'],
        'file' => Faraday::UploadIO.new(self.options[:icon], 'image/jpeg'),
      }
      UI.message "Start upload #{self.options[:app_name]} icon..."
      response = binary_conn.post icon_info['upload_url'], params
      unless response.body['is_completed']
        raise UI.user_error!("Upload icon to Qiniu error #{response.body}")
      end
      UI.success 'Upload icon successed!'
    end

    def update_app_info id
      params = {
        :api_token => self.options[:firim_api_token],
        :id => id
      }
      ["name", "desc", "short", "is_opened", "is_show_plaza", "passwd", "store_link_visible"].each do |k|
        key = :"app_#{k}"
        params[k] = self.options[key] if self.options[key] != nil
      end

      update_app_info_path = "apps/#{id}"
      response = self.firim_client.put do |req|
        req.url update_app_info_path
        req.body = params
      end
      info = response.body
      validation_response info
      UI.success "Update app info successed!"
      return info
    end

  end
end
