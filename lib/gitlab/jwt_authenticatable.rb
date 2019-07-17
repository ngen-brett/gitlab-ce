# frozen_string_literal: true

module Gitlab
  module JwtAuthenticatable
    # Supposedly the effective key size for HMAC-SHA256 is 256 bits, i.e. 32
    # bytes https://tools.ietf.org/html/rfc4868#section-2.6
    SECRET_LENGTH = 32

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def decode_jwt_for_issuer(issuer, encoded_message)
        JWT.decode(
          encoded_message,
          secret,
          true,
          { iss: issuer, verify_iss: true, algorithm: 'HS256' }
        )
      end

      def secret
        @secret ||= begin
                      bytes = Base64.strict_decode64(File.read(secret_path).chomp)
                      raise "#{secret_path} does not contain #{SECRET_LENGTH} bytes" if bytes.length != SECRET_LENGTH

                      bytes
                    end
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
