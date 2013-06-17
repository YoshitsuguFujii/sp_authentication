require 'action_controller'
require "sp_authentication/version"
require 'sp_authentication/configuration'

module SpAuthentication
  extend Configuration
  class SettingError < StandardError; end;

  def sp_authentication
    # configureを呼び出して色々設定してからloggerを作りたいのでこの位置に・・・
    require 'sp_authentication/sp_authentication_logger'

    # error if setting is none
    if SpAuthentication.secret_key.nil? || SpAuthentication.consumer_key.nil?
      error_mes = <<-'EOS'
        Don't given secret_key, consumer_key, plz setting like below
        SpAuthentication.configure do |config|
          config.secret_key = "#{YOUR CUSTOM SECRET_KEY}"
          config.consumer_key = "#{YOUR CUSTOM CONSUMER_KEY}"
        end
      EOS

      SpAuthenticationLogger.logger.error(error_mes)
      raise SettingError, error_mes
    end

    # 判定用のメソッドを追加
    class_eval do

      # ユーザの特定なしの認証
      # 1.consumer_key
      # 2.signature
      # 3.sp_type
      # 4.version
      def authenticate_request
#        auth = Certification::Authentication.new
#
#        # リクエストの妥当性チェック
#        @result = auth.check_consumer_key_and_signature request

        header_signature    = request.env[SpAuthentication.signature_header_name]
        header_consumer_key = request.env[SpAuthentication.consumer_key_header_name]

        if SpAuthentication.print_debug
          SpAuthenticationLogger.logger.error("header_signature:    #{header_signature}")
          SpAuthenticationLogger.logger.error("header_consumer_key: #{header_consumer_key}")

        #TODO ここまで
        require 'pry-debugger'
          SpAuthenticationLogger.logger.error("REQUEST URL:         #{request.url}")
          SpAuthenticationLogger.logger.error("REQUEST METHOD:      #{request.method}")
        end

        binding.pry
        if header_signature.nil?
          Rails.logger.error("header_signature not provided")
          @error = "header_signature not provided"
          return false
        end

        if header_consumer_key.nil?
          Rails.logger.info("header_consumer_key not provided")
          @error = "header_consumer_key not provided"
          return false
        end

        if @secret_key.nil?
          Rails.logger.info("secret_key not configured")
          @error = "secret_key not configured"
        end

        if @consumer_key.nil?
          @error = "consumer_key not configured"
          Rails.logger.info("consumer_key not configured")
        end

        parameters = nil
        if request.get?
          parameters = request.query_parameters
        else
          parameters = request.request_parameters
        end


        #generated_signature = create_signature(request.method, request.url, parameters, @secret_key)
        generated_signature = create_signature(request.method, request.url.split('?').first, parameters, @secret_key)

        Rails.logger.info("header_signature: " + header_signature)
        Rails.logger.info("generate_signature: " + generated_signature )


        # シグネチャとコンシューマーキーが一致していたら認証OKとする
        if header_signature == generated_signature && header_consumer_key == @consumer_key
          return true
        else
          @error = "access_token or consumer_key or siganature not match"
          Rails.logger.info("access_token or consumer_key or siganature not match")
          return false
        end

      end

      # ユーザ特定ありの認証 {{{
      def authenticate_user
        auth = Certification::Authentication.new

        result = auth.check request

        # 認証失敗
        if result == false
          render json: ApiResponse.auth_failed , :status => 401
        else
          @current_user = result
  #        if @current_user.expiration?
  #         if @current_user.update_access_token!
  #            @updated_access_token = @current_user.access_token
  #          end
  #        end
        end
      end
      # }}}
    end

  end

end

#ActionController::Base.send(:extend, SpAuthentication) if defined?(ActionController)
