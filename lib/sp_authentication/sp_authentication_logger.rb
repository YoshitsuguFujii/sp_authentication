module SpAuthentication
  class SpAuthenticationLogger
    require "logger"

    class << self
      def logger_new(file_name)
        if SpAuthentication.stdout
          logger = Logger.new(STDOUT)
        else
          logger = Logger.new("#{log_dir}#{file_name}", 'daily')
        end
        logger.formatter = Logger::Formatter.new
        logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        logger.level = Logger::DEBUG
        logger
      end

      def log_dir
        out_dir = "log/"
        FileTest.exist?(out_dir)? out_dir : ""
      end

      # ログ出力してエラーも出す
      # @params [StandardError] ex エラークラス
      # @params [string] err_message エラーメッセージ
      def raise_with_log(ex, err_message)
        SpAuthenticationLogger.logger.error(err_message)
        raise ex, err_message
      end
    end

    cattr_accessor :logger
    if defined?(Rails)
      self.logger = Rails.logger
    else
      self.logger = logger_new("sp_authentication.log")
    end

  end
end
