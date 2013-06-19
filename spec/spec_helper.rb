# encoding: utf-8
require 'rubygems'
require 'sp_authentication'

def initialize_setting
  SpAuthentication.configure do |config|
    config.secret_key = "afdaAAA0dscaqH82ZEtuXG7Lctz9DryENvJcea9Ta2d"
    config.consumer_key = "KCMDJ2343FDK4de"
#    config.print_debug = true
#    config.stdout = true
  end
end
