# frozen_string_literal: true

# An environment name is not necessarily suitable for use in URLs, DNS
# or other third-party contexts, so provide a slugified version. A slug has
# the following properties:
#   * contains only lowercase letters (a-z), numbers (0-9), and '-'
#   * begins with a letter
#   * has a maximum length of 24 bytes (OpenShift limitation)
#   * cannot end with `-`
module Gitlab
  module Slug
    class Environment
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def generate
        # Lowercase letters and numbers only
        slugified = +name.to_s.downcase.gsub(/[^a-z0-9]/, '-')

        # Must start with a letter
        slugified = 'env-' + slugified unless ('a'..'z').cover?(slugified[0])

        # Repeated dashes are invalid (OpenShift limitation)
        slugified.gsub!(/\-+/, '-')

        # Maximum length: 24 characters (OpenShift limitation)
        slugified = slugified[0..23]

        # Cannot end with a dash (Kubernetes label limitation)
        slugified.chop! if slugified.end_with?('-')

        # Add a random suffix, shortening the current string if necessary, if it
        # has been slugified. This ensures uniqueness.
        if slugified != name
          slugified = slugified[0..16]
          slugified << '-' unless slugified.ends_with?('-')
          slugified << suffix
        end

        slugified
      end

      private

      # Slugifying a name may remove the uniqueness guarantee afforded by it being
      # based on name (which must be unique). To compensate, we add a predictable
      # 6-byte suffix in those circumstances. This is not *guaranteed* uniqueness,
      # but the chance of collisions is vanishingly small
      def suffix
        Digest::SHA2.hexdigest(name).last(6)
      end
    end
  end
end
