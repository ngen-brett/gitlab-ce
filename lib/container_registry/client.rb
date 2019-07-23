# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'digest'

module ContainerRegistry
  class Client
    attr_accessor :uri

    MANIFEST_VERSION = 'application/vnd.docker.distribution.manifest.v2+json'.freeze

    # Taken from: FaradayMiddleware::FollowRedirects
    REDIRECT_CODES = Set.new [301, 302, 303, 307]

    def initialize(base_uri, options = {})
      @base_uri = base_uri
      @options = options
    end

    def repository_tags(name)
      response_body faraday.get("/v2/#{name}/tags/list")
    end

    def repository_manifest(name, reference)
      response_body faraday.get("/v2/#{name}/manifests/#{reference}")
    end

    def repository_tag_digest(name, reference)
      response = faraday.head("/v2/#{name}/manifests/#{reference}")
      response.headers['docker-content-digest'] if response.success?
    end

    def delete_repository_tag(name, reference)
      faraday.delete("/v2/#{name}/manifests/#{reference}").success?
    end

    def upload_blob(name, content, digest)
      upload = faraday.post("/v2/#{name}/blobs/uploads/") do |req|
      end

      location = URI(upload.headers['location'])

      upload = faraday.put("#{location.path}?#{location.query}") do |req|
        req.params['digest'] = digest
        req.headers['Content-Type'] = 'application/octect-stream'
        req.body = content
      end
    end

    # Replace a tag on the registry with a dummy tag.
    # this is a hack as the registry doesn't support deleting individual
    # tags. This code effectvely pushes a dummy image and assigns the tag to it.
    # This way when the tag is deleted only the dummy image is affected.
    # See https://gitlab.com/gitlab-org/gitlab-ce/issues/21405 for a discussion
    def put_dummy_tag(name, reference)
      # docker doest seem to care for the actual content of these blobs,
      # so we're just uploading dummy gibberish
      image = "image-container-dont-care"
      rootfs = "rootfs-also-dont-care.tar.gz"

      blobs = [image, rootfs]

      digests = blobs.each_with_object({}) { |blob, hash|
        hash[blob] = "sha256:#{Digest::SHA256.hexdigest(blob)}"
      }

      # simply upload these fake blobs to docker registry
      digests.each_pair do |blob, digest|
        upload_blob(name, blob, digest)
      end

      # upload the replacement docker manifest for the tag,
      # so that it points to the dummy image
      faraday.put("/v2/#{name}/manifests/#{reference}") do |req|
        req.headers['Content-Type'] = 'application/vnd.docker.distribution.manifest.v2+json'
        req.body = <<~DIGEST
        {
          "schemaVersion": 2,
          "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
          "config": {
              "mediaType": "application/vnd.docker.container.image.v1+json",
              "size": #{image.size},
              "digest": "#{digests[image]}"
          },
          "layers": [
              {
                "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
                "size": #{rootfs.size},
                "digest": "#{digests[rootfs]}"
              }
          ]
        }
        DIGEST
      end
    end

    def blob(name, digest, type = nil)
      type ||= 'application/octet-stream'
      response_body faraday_blob.get("/v2/#{name}/blobs/#{digest}", nil, 'Accept' => type), allow_redirect: true
    end

    def delete_blob(name, digest)
      faraday.delete("/v2/#{name}/blobs/#{digest}").success?
    end

    private

    class MyEncoder
      def self.encode(params)
        Faraday::FlatParamsEncoder.encode(params).gsub("%3A", ":")
      end

      def self.decode(query)
        Faraday::FlatParamsEncoder.decode(query)
      end
    end

    def initialize_connection(conn, options)
      conn.request :json

      if options[:user] && options[:password]
        conn.request(:basic_auth, options[:user].to_s, options[:password].to_s)
      elsif options[:token]
        conn.request(:authorization, :bearer, options[:token].to_s)
      end

      conn.options.params_encoder = MyEncoder

      yield(conn) if block_given?

      conn.adapter :net_http
    end

    def accept_manifest(conn)
      conn.headers['Accept'] = MANIFEST_VERSION

      conn.response :json, content_type: 'application/json'
      conn.response :json, content_type: 'application/vnd.docker.distribution.manifest.v1+prettyjws'
      conn.response :json, content_type: 'application/vnd.docker.distribution.manifest.v1+json'
      conn.response :json, content_type: 'application/vnd.docker.distribution.manifest.v2+json'
    end

    def response_body(response, allow_redirect: false)
      if allow_redirect && REDIRECT_CODES.include?(response.status)
        response = redirect_response(response.headers['location'])
      end

      response.body if response && response.success?
    end

    def redirect_response(location)
      return unless location

      faraday_redirect.get(location)
    end

    def faraday
      @faraday ||= Faraday.new(@base_uri) do |conn|
        initialize_connection(conn, @options, &method(:accept_manifest))
      end
    end

    def faraday_blob
      @faraday_blob ||= Faraday.new(@base_uri) do |conn|
        initialize_connection(conn, @options)
      end
    end

    # Create a new request to make sure the Authorization header is not inserted
    # via the Faraday middleware
    def faraday_redirect
      @faraday_redirect ||= Faraday.new(@base_uri) do |conn|
        conn.request :json
        conn.adapter :net_http
      end
    end
  end
end
