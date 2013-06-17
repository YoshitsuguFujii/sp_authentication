# encoding: utf-8
require 'rubygems'
require 'sp_authentication'

describe SpAuthentication do
  let(:request) { ActionController::Base.new }

  before do
    extend SpAuthentication
    initialize_setting
    request.env["HTTP_ACCESSTOKEN"] = "aa1"
    request.env["HTTP_CONSUMERKEY"] = "aa2"
    request.env["HTTP_SIGNATURE"]   = "aa3"
  end

  context "for" do
    it "debug" do
      require "pry-debugger"
      binding.pry
      sp_authentication
      authenticate_request
    end
  end

end

def initialize_setting
  SpAuthentication.configure do |config|
    config.secret_key = "afdaAAA0dscaqH82ZEtuXG7Lctz9DryENvJcea9Ta2d"
    config.consumer_key = "2jPiX3ZV2qJ6DAIF8LZUS7IlujHSfsrKaWIkuZE0dkpfiMecJbXXL"
    config.print_debug = true
    config.stdout = true
  end
end
