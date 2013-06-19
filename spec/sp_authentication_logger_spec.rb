# coding: utf-8
require 'spec_helper'
require 'sp_authentication/sp_authentication_logger'

describe SpAuthentication::SpAuthenticationLogger do

  let(:file_name){"sp_authentication.log"}

  context "ログ出力" do
    it "ファイルに追記されること" do
      message = "test output #{Time.now}"
      SpAuthentication::SpAuthenticationLogger.logger.error(message)
      last_line = open(file_name) do |file|
                    lines = file.read
                    lines.each_line.to_a.last
                  end
      last_line.include?(message)
    end
  end
end
