# coding: utf-8
require 'spec_helper'

describe SpAuthentication::Generator do

  context "confirm" do
    it "generate value" do
      signature = SpAuthentication::Generator.create_signature(:post, "http://www.yahoo.co.jp", {bbb: "ccc"}, "secret_key")
      signature.should eql "cL0Rv1uanBkSMjFYjfjfs2B57Lg%3D"
    end
  end

end
