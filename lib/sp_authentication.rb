require 'action_controller'
require "sp_authentication/version"
require 'sp_authentication/configuration'
require 'sp_authentication/generator'
require 'sp_authentication/core'
#require 'pry-debugger'
require 'sp_authentication/custom_error'

module SpAuthentication
  extend Configuration
  include Core

  def self.extended(obj)
    obj.sp_authentication
  end
end

ActionController::Base.send(:extend, SpAuthentication) if defined?(ActionController)
