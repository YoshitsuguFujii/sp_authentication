# coding: utf-8
require 'spec_helper'

describe SpAuthentication::Core do

  let(:request) { ActionController::Base.new }

  before do
    extend SpAuthentication
    initialize_setting
    request.env["HTTP_ACCESSTOKEN"] = "aa1"
    request.env["HTTP_CONSUMERKEY"] = "KCMDJ2343FDK4de"
    request.env["HTTP_SIGNATURE"]   = "HlTL6%2FauoNvt3mhzwgkGuMJIveg%3D"
    request.stub(:url){"http://localhost"}
    request.stub(:method){:get}
    request.stub(:get?){ true }
    request.stub(:query_parameters){ Hash.new }
    request.stub(:request_parameters){ Hash.new }

    class User; end
  end

#  context "for" do
#    it "debug" do
#      require "pry-debugger"
#      binding.pry
#      authenticate_request
#    end
#  end


  context "共通パターン" do # {{{
    context "失敗パターン" do
      it "サーバー側設定のコンシューマーキー未設定" do
        SpAuthentication.configure{|config| config.consumer_key = nil }
        expect { authenticate_request }.to raise_error(SpAuthentication::CustomError::SettingError)
      end

      it "サーバー側設定のシークレットキー未設定" do
        SpAuthentication.configure{|config| config.secret_key = nil }
        expect { authenticate_request }.to raise_error(SpAuthentication::CustomError::SettingError)
      end
    end
  end # }}}

  context "ユーザ特定なし" do #{{{
    context "成功パターン" do
      it "get to http://localhost" do
        request.stub(:method){:get}
        authenticate_request.should be_true
      end

      it "post to http://localhost" do
        request.stub(:method){:post}
        request.env["HTTP_SIGNATURE"]   = "BLdRnU46clxjrUJfcNN9q%2F1XwZc%3D"
        authenticate_request.should be_true
      end

      it "put to http://localhost" do
        request.stub(:method){:put}
        request.env["HTTP_SIGNATURE"]   = "FoYh7Xw4q4WCVu%2B3IIAnOsBY3to%3D"
        authenticate_request.should be_true
      end
    end

    context "失敗パターン" do
      it "ヘッダのコンシューマーキー未設定" do
        request.env["HTTP_CONSUMERKEY"] = nil
        expect { authenticate_request }.to raise_error(SpAuthentication::CustomError::RequestArgumentError)
      end

      it "ヘッダのシグネチャ未設定" do
        request.env["HTTP_SIGNATURE"]   = nil
        expect { authenticate_request }.to raise_error(SpAuthentication::CustomError::RequestArgumentError)
      end

      it "シグネチャが一致しない" do
        request.stub(:method){:get}
        request.env["HTTP_SIGNATURE"]   = "ABDAFDFEE"
        expect { authenticate_request }.to raise_error(SpAuthentication::Core::UnauthorizedError)
      end
    end
  end  #}}}

  context "ユーザ特定あり" do #{{{
    context "成功パターン" do
      before do
        User.should_receive(:where).and_return([User.new])
      end

      it "get to http://localhost" do
        request.stub(:method){:get}
        authenticate_user.should be_an_instance_of(User)
      end

      it "post to http://localhost" do
        request.stub(:method){:post}
        request.env["HTTP_SIGNATURE"]   = "BLdRnU46clxjrUJfcNN9q%2F1XwZc%3D"
        authenticate_user.should be_an_instance_of(User)
      end

      it "put to http://localhost" do
        request.stub(:method){:put}
        request.env["HTTP_SIGNATURE"]   = "FoYh7Xw4q4WCVu%2B3IIAnOsBY3to%3D"
        authenticate_user.should be_an_instance_of(User)
      end
    end

    context "失敗パターン" do
      before do
        User.stub(:where){[User.new]}
      end

      it "ヘッダのコンシューマーキー未設定" do
        request.env["HTTP_CONSUMERKEY"] = nil
        expect { authenticate_user }.to raise_error(SpAuthentication::CustomError::RequestArgumentError)
      end

      it "ヘッダのシグネチャ未設定" do
        request.env["HTTP_SIGNATURE"]   = nil
        expect { authenticate_user }.to raise_error(SpAuthentication::CustomError::RequestArgumentError)
      end

      it "ヘッダのアクセストークン未設定" do
        request.env["HTTP_SIGNATURE"]   = nil
        expect { authenticate_user }.to raise_error(SpAuthentication::CustomError::RequestArgumentError)
      end

      it "シグネチャが一致しない" do
        request.stub(:method){:get}
        request.env["HTTP_SIGNATURE"]   = "ABDAFDFEE"
        expect { authenticate_user }.to raise_error(SpAuthentication::CustomError::UnauthorizedError)
      end

      it "ユーザが一致しない" do
        request.stub(:method){:put}
        request.env["HTTP_SIGNATURE"]   = "FoYh7Xw4q4WCVu%2B3IIAnOsBY3to%3D"
        User.stub(:where){[]}
        expect { authenticate_user }.to raise_error(SpAuthentication::CustomError::UserNotFound)
      end
    end
  end  #}}}
end

