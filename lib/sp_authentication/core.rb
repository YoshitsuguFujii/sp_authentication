require 'sp_authentication/custom_error'

module SpAuthentication
  module Core
    include CustomError

    def sp_authentication
      # 判定用のメソッドを追加
      class_eval do

        # ユーザの特定なしの認証
        # 1.consumer_key
        # 2.signature
        # 3.sp_type
        # 4.version
        def authenticate_request
          require_logger
          setting_check
          header_signature    = request.env[SpAuthentication.signature_header_name]
          header_consumer_key = request.env[SpAuthentication.consumer_key_header_name]

          if SpAuthentication.print_debug
            SpAuthenticationLogger.logger.error("header_signature:    #{header_signature}")
            SpAuthenticationLogger.logger.error("header_consumer_key: #{header_consumer_key}")
            SpAuthenticationLogger.logger.error("REQUEST URL:         #{request.url}")
            SpAuthenticationLogger.logger.error("REQUEST METHOD:      #{request.method}")
          end

          if header_signature.nil?
            SpAuthenticationLogger.raise_with_log(RequestArgumentError, "header_signature not provided")
          end

          if header_consumer_key.nil?
            SpAuthenticationLogger.raise_with_log(RequestArgumentError, "header_consumer_key not provided")
          end

          parameters = nil
          if request.get?
            parameters = request.query_parameters
          else
            parameters = request.request_parameters
          end

          generated_signature = Generator.create_signature(request.method, request.url.split('?').first, parameters, SpAuthentication.secret_key)

          if SpAuthentication.print_debug
            SpAuthenticationLogger.logger.info("header_signature: " + header_signature)
            SpAuthenticationLogger.logger.info("generate_signature: " + generated_signature )
          end

          # 作成したシグネチャとコンシューマーキーが一致していたら認証OKとする
          if header_signature == generated_signature && header_consumer_key == SpAuthentication.consumer_key
            return true
          else
            SpAuthenticationLogger.raise_with_log(UnauthorizedError, "access_token or consumer_key or siganature not match")
          end
        end


        # ユーザ特定ありの認証
          def authenticate_user
            unless authenticate_request
              SpAuthenticationLogger.raise_with_log(UnauthorizedError, "access_token or consumer_key or siganature not match")
            end

            header_access_token  = request.env[SpAuthentication.access_token_header_name]

            if header_access_token.nil?
              SpAuthenticationLogger.raise_with_log(RequestArgumentError, "header_access_token not provided")
            end

            model = Object.const_get(SpAuthentication.user_model.capitalize)
            #TODO Railsでしか動かん
            user = model.where("#{SpAuthentication.access_token_attribute.to_s} = ?", header_access_token).first

            if user.nil?
              SpAuthenticationLogger.raise_with_log(UserNotFound, "header_access_token match user not exists")
            else
              return user
            end
          end


        def require_logger
          # configureを呼び出して色々設定してからloggerを作りたいのでこの位置に・・・
          require 'sp_authentication/sp_authentication_logger'
        end

        # setting_check
        def setting_check
          # error if setting is none
          if SpAuthentication.secret_key.nil? || SpAuthentication.consumer_key.nil?
            err_message = <<-'EOS'
            Don't given secret_key, consumer_key, plz setting like below
            SpAuthentication.configure do |config|
              config.secret_key = "#{YOUR CUSTOM SECRET_KEY}"
              config.consumer_key = "#{YOUR CUSTOM CONSUMER_KEY}"
            end
            EOS

            SpAuthenticationLogger.raise_with_log(SettingError, err_message)
          end
        end

      end
    end
  end
end
