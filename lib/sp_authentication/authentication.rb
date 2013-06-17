# encoding: utf-8

module Certification
  class Authentication
    require 'digest/md5'

    attr_accessor :secret_key, :access_token, :consumer_key, :access_token_header_name, :consumer_key_header_name, :signature_header_name, :error


    # 初期化　秘密鍵とコンシューマーキーを設定、ヘッダ名は渡されていたらそれを使う
    def initialize
      @access_token_header_name = "HTTP_ACCESSTOKEN"
      @consumer_key_header_name = "HTTP_CONSUMERKEY"
      @signature_header_name = "HTTP_SIGNATURE"

      @secret_key = Certification.secret_key
      @consumer_key = Certification.consumer_key
      @access_token_header_name = Certification.access_token_header_name unless Certification.access_token_header_name.blank?
      @consumer_key_header_name = Certification.consumer_key_header_name unless Certification.consumer_key_header_name.blank?
      @signature_header_name = Certification.signature_header_name unless Certification.signature_header_name.blank?

      @error = ""
    end

    # signatureを生成する
    # 処理概要
    # 1. HTTPリクエストメソッド、URL、キーでアルファベット順にソートしたリクエストパラメータの順番で&で連結し、RFC3986形式でURLエンコーディングを行います
    # 2. 1で生成した文字列をシークレットキーを使ってhmacsha1 アルゴリズムでHash値を生成します
    # 3. 2で生成したHash値をbase64エンコードします
    def create_signature method, url, parameters, secret_key
      target_str = "#{method}&#{url}"

      params_array = Array.new
      if parameters.length > 0
        parameters.sort.each do |key, value|
          params_array << "#{key}=#{CGI.escape(value)}"
        end
        params_str = params_array.join("&")
        target_str = target_str + "&#{params_str}"
      end

      p "encript target: #{target_str}"
      Rails.logger.info("encript target : " + target_str)
      digest = OpenSSL::Digest::Digest.new('sha1')
      ret = CGI.escape(Base64.strict_encode64(OpenSSL::HMAC.digest(digest, secret_key, target_str)))
      p "encripted string: #{ret}"
      return ret
    end



    # ユーザ特定ありの認証
    # 認証を実行する
    # 成功したらuserのレコードを返す
    # 失敗したらfalseを返す
    def check request
      header_access_token = request.env[@access_token_header_name]

      if header_access_token.nil?
        Rails.logger.error("header_access_token not provided")
        @error = "header_access_token not provided"
        return false
      end


      user = User.where("access_token = ?", header_access_token).first
      Rails.logger.info "user: "
      Rails.logger.info user
      if user.nil?
        @error = "header_access_token match user not exists"
        return false
      end

      if check_consumer_key_and_signature request
         return user
      else
         return false
      end
    end

    # ユーザ特定なしの認証
    # コンシューマーキーとシグネチャーのチェックをする
    # 成功時　true 失敗時　false
    def check_consumer_key_and_signature request
      # 暫定処理

      header_signature = request.env[@signature_header_name]
      header_consumer_key = request.env[@consumer_key_header_name]

      Rails.logger.error("header_signature: ")
      Rails.logger.error(header_signature)
      Rails.logger.error("header_consumer_key: ")
      Rails.logger.error(header_consumer_key)
      Rails.logger.error("REQUEST URL: ")
      Rails.logger.error(request.url)
      Rails.logger.error("REQUEST METHOD: ")
      Rails.logger.error(request.method)

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

  end
end
