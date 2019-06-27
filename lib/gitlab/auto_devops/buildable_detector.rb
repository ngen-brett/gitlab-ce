module Gitlab
  module AutoDevops
    class BuildableDetector
      PATTERNS = [
        # https://github.com/heroku/heroku-buildpack-clojure
        'project.clj',

        # https://github.com/heroku/heroku-buildpack-go
        'go.mod',
        'Gopkg.mod',
        'Godeps/Godeps.json',
        'vendor/vendor.json',
        'glide.yaml',
        'src/**.go',

        # https://github.com/heroku/heroku-buildpack-gradle
        'gradlew',
        'build.gradle',
        'settings.gradle',

        # https://github.com/heroku/heroku-buildpack-java
        'pom.xml',
        'pom.atom',
        'pom.clj',
        'pom.groovy',
        'pom.rb',
        'pom.scala',
        'pom.yaml',
        'pom.yml',

        # https://github.com/heroku/heroku-buildpack-multi
        '.buildpacks',

        # https://github.com/heroku/heroku-buildpack-nodejs
        'package.json',

        # https://github.com/heroku/heroku-buildpack-php
        'composer.json',
        'index.php',

        # https://github.com/heroku/heroku-buildpack-play
        # TODO: detect script excludes some scala files
        '*/conf/application.conf',
        '*modules*',

        # https://github.com/heroku/heroku-buildpack-python
        # TODO: detect script checks that all of these exist, not any
        'requirements.txt',
        'setup.py',
        'Pipfile',

        # https://github.com/heroku/heroku-buildpack-ruby
        'Gemfile',

        # https://github.com/heroku/heroku-buildpack-scala
        '*.sbt',
        'project/*.scala',
        '.sbt/*.scala',
        'project/build.properties',

        # https://github.com/dokku/buildpack-nginx
        '.static',
      ].freeze

      def initialize(repo, ref)
        @repo = repo
        @ref = ref
      end

      def detect
        return unless tree = @repo.tree(@ref)

        tree.blobs.find do |blob|
          PATTERNS.any? do |pattern|
            File.fnmatch?(pattern, blob.path, File::FNM_CASEFOLD)
          end
        end
      end
    end
  end
end
