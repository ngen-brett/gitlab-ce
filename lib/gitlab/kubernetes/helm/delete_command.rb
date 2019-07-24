# frozen_string_literal: true

module Gitlab
  module Kubernetes
    module Helm
      class DeleteCommand
        include BaseCommand
        include ClientCommand

        attr_reader :predelete, :postdelete
        attr_accessor :name, :files

        def initialize(name:, rbac:, files:, predelete: nil, postdelete: nil)
          @name = name
          @files = files
          @rbac = rbac
          @predelete = predelete
          @postdelete = postdelete
        end

        def generate_script
          super + [
            init_command,
            wait_for_tiller_command,
            predelete_command,
            delete_command,
            postdelete_command
          ].compact.join("\n")
        end

        def pod_name
          "uninstall-#{name}"
        end

        def rbac?
          @rbac
        end

        private

        def delete_command
          command = ['helm', 'delete', '--purge', name] + optional_tls_flags

          command.shelljoin
        end

        def predelete_command
          predelete.join("\n") if predelete
        end

        def postdelete_command
          postdelete.join("\n") if postdelete
        end

        def optional_tls_flags
          return [] unless files.key?(:'ca.pem')

          [
            '--tls',
            '--tls-ca-cert', "#{files_dir}/ca.pem",
            '--tls-cert', "#{files_dir}/cert.pem",
            '--tls-key', "#{files_dir}/key.pem"
          ]
        end
      end
    end
  end
end
