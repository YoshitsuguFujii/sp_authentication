# SpAuthentication

認証用Gem

## インストール

Add this line to your application's Gemfile:

    gem 'sp_authentication', :git => "https://github.com/YoshitsuguFujii/sp_authentication.git"

And then execute:

    $ bundle

##設定
設定可能項目  

設定項目	|設定値			|内容
:----------|:----------|:----------
secret_key	|string			|シークレットキー
consumer_key	|string			|コンシューマーキー
print_debug	|boolean			|デバッグ文出力の場合
stdout	|boolean			|デバッグ文を標準出力に出したい場合

設定例　
```ruby
# config/initializers/sp_authentication.rb　　
SpAuthentication.configure do |config|
  config.secret_key = "#{YOUR CUSTOM SECRET_KEY}"
  config.consumer_key = "#{YOUR CUSTOM CONSUMER_KEY}"
end
```

### 使用方法
check without search user(ユーザ特定なしの認証)
```ruby
class ApplicationController < ActionController::Base
  before_filter :authenticate_request
end
```

check with search user(ユーザ特定ありの認証)
```ruby
class ApplicationController < ActionController::Base
  before_filter :authenticate_user
end
```