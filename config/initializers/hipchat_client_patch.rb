# frozen_string_literal: true
# This monkey patches the HTTParty used in https://github.com/hipchat/hipchat-rb.
module HipChat
  class Client
    connection_adapter ::Gitlab::ProxyHTTPConnectionAdapter
  end

  class Room
    connection_adapter ::Gitlab::ProxyHTTPConnectionAdapter
  end

  class User
    connection_adapter ::Gitlab::ProxyHTTPConnectionAdapter
  end
end
