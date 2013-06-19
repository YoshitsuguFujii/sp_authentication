module SpAuthentication::CustomError
  class SettingError < StandardError; end;
  class RequestArgumentError < StandardError; end;
  class UnauthorizedError < StandardError; end;
  class UserNotFound < StandardError; end;
end
