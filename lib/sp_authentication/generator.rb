
module SpAuthentication
  class Generator
    class << self
      # signatureを生成する
      # 処理概要
      # 1. httpリクエストメソッド、url、キーでアルファベット順にソートしたリクエストパラメータの順番で&で連結し、rfc3986形式でurlエンコーディングを行います
      # 2. 1で生成した文字列をシークレットキーを使ってhmacsha1 アルゴリズムでhash値を生成します
      # 3. 2で生成したhash値をbase64エンコードします
      def create_signature(method, url, parameters, secret_key)
        target_str = "#{method}&#{url}"

        params_array = Array.new
        if parameters.length > 0
          parameters.sort.each do |key, value|
            params_array << "#{key}=#{CGI.escape(value)}"
          end
          params_str = params_array.join("&")
          target_str = target_str + "&#{params_str}"
        end

        if SpAuthentication.print_debug
         SpAuthenticationLogger.logger.info("encript target: #{target_str}")
        end
        digest = OpenSSL::Digest::Digest.new('sha1')
        ret = CGI.escape(Base64.strict_encode64(OpenSSL::HMAC.digest(digest, secret_key, target_str)))
        if SpAuthentication.print_debug
         SpAuthenticationLogger.logger.info("encripted string: #{ret}")
        end
        return ret
      end
    end
  end
end
