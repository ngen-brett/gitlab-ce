# frozen_string_literal: true

require_dependency 'gitlab/popen'

module Gitlab
  def self.root
    Pathname.new(File.expand_path('..', __dir__))
  end

  def self.config
    Settings
  end

  def self.revision
    @_revision ||= begin
      if File.exist?(root.join("REVISION"))
        File.read(root.join("REVISION")).strip.freeze
      else
        result = Gitlab::Popen.popen_with_detail(%W[#{config.git.bin_path} log --pretty=format:%h -n 1])

        if result.status.success?
          result.stdout.chomp.freeze
        else
          "Unknown".freeze
        end
      end
    end
  end

  def self.version_info
    Gitlab::VersionInfo.parse(Gitlab::VERSION)
  end

  COM_URL = 'https://gitlab.com'.freeze
  APP_DIRS_PATTERN = %r{^/?(app|config|ee|lib|spec|\(\w*\))}
  SUBDOMAIN_REGEX = %r{\Ahttps://[a-z0-9]+\.gitlab\.com\z}
  VERSION = File.read(root.join("VERSION")).strip.freeze
  INSTALLATION_TYPE = File.read(root.join("INSTALLATION_TYPE")).strip.freeze

  def self.pre_release?
    VERSION.include?('pre')
  end

  def self.final_release?
    !VERSION.include?('rc') && !pre_release?
  end

  def self.minor_release
    version_info.major.to_s + '.' + version_info.minor.to_s
  end

  def self.previous_release
    if version_info.minor.to_i > 0
      if version_info.patch.to_i > 0
        "#{version_info.major}.#{version_info.minor}"
      else
        "#{version_info.major}.#{version_info.minor - 1}"
      end
    else
      (version_info.major.to_i - 1).to_s
    end
  end

  def self.new_major_release?
    version_info.minor.to_i.zero?
  end

  def self.com?
    # Check `gl_subdomain?` as well to keep parity with gitlab.com
    Gitlab.config.gitlab.url == COM_URL || gl_subdomain?
  end

  def self.org?
    Gitlab.config.gitlab.url == 'https://dev.gitlab.org'
  end

  def self.gl_subdomain?
    SUBDOMAIN_REGEX === Gitlab.config.gitlab.url
  end

  def self.dev_env_or_com?
    Rails.env.development? || org? || com?
  end
end
