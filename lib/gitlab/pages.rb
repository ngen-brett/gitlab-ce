# frozen_string_literal: true

module Gitlab
  class Pages
    VERSION = File.read(Rails.root.join("GITLAB_PAGES_VERSION")).strip.freeze
    INTERNAL_API_REQUEST_HEADER = 'Gitlab-Pages-Api-Request'.freeze

    # Supposedly the effective key size for HMAC-SHA256 is 256 bits, i.e. 32
    # bytes https://tools.ietf.org/html/rfc4868#section-2.6
    SECRET_LENGTH = 32

    class << self
      def verify_api_request(request_headers)
        decode_jwt(request_headers[INTERNAL_API_REQUEST_HEADER])
      rescue JWT::DecodeError
        false
      end

      def decode_jwt(encoded_message)
        JWT.decode(
          encoded_message,
          secret,
          true,
          { iss: 'gitlab-pages', verify_iss: true, algorithm: 'HS256' }
        )
      end

      def secret
        @secret ||= begin
                      bytes = Base64.strict_decode64(File.read(secret_path).chomp)
                      raise "#{secret_path} does not contain #{SECRET_LENGTH} bytes" if bytes.length != SECRET_LENGTH

                      bytes
                    end
      end

      def secret_path
        Gitlab.config.pages.secret_file
      end

      def write_secret
        bytes = SecureRandom.random_bytes(SECRET_LENGTH)
        File.open(secret_path, 'w:BINARY', 0600) do |f|
          f.chmod(0600) # If the file already existed, the '0600' passed to 'open' above was a no-op.
          f.write(Base64.strict_encode64(bytes))
        end
      end
    end
  end
end
