# frozen_string_literal: true

module Gitlab
  module Utils
    module Override
      class Extension
        cattr_accessor :ancestors

        def self.verify_class!(klass, method_name, arity)
          verify_method!(subject: klass, klass: klass, method_name: method_name, expected_arity: arity)
        end

        def self.instance_method_defined?(klass, name)
          klass.instance_methods(false).include?(name) ||
            klass.private_instance_methods(false).include?(name)
        end

        def self.verify_method!(subject:, klass:, method_name:, expected_arity:)
          index = self.ancestors_for(klass).index(subject)
          parents = klass.ancestors.drop(index + 1)

          overridden_parent = parents.find do |parent|
            instance_method_defined?(parent, method_name)
          end

          raise NotImplementedError.new("#{klass}\##{method_name} doesn't exist!") unless overridden_parent

          original_arity = find_direct_instance_method(overridden_parent, method_name).parameters.length

          if original_arity != expected_arity
            raise NotImplementedError.new("#{subject}\##{method_name} has arity of #{expected_arity}, but #{overridden_parent}\##{method_name} has arity of #{original_arity}")
          end
        end

        def self.find_direct_instance_method(klass, name)
          method = klass.instance_method(name)
          method = method.super_method until method && klass == method.owner
          method
        end

        def self.ancestors_for(klass)
          self.ancestors ||= {}
          self.ancestors[klass] ||= klass.ancestors
        end

        attr_reader :subject

        def initialize(subject)
          @subject = subject
        end

        def add_method_name(method_name, arity = nil)
          method_names[method_name] = arity
        end

        def add_class(klass)
          classes << klass
        end

        def verify_override?(method_name)
          method_names.has_key?(method_name)
        end

        def verify!
          classes.each do |klass|
            method_names.each_pair do |method_name, arity|
              self.class.verify_method!(subject: subject, klass: klass, method_name: method_name, expected_arity: arity)
            end
          end
        end

        def method_names
          @method_names ||= {}
        end

        private

        def classes
          @classes ||= []
        end
      end

      # Instead of writing patterns like this:
      #
      #     def f
      #       raise NotImplementedError unless defined?(super)
      #
      #       true
      #     end
      #
      # We could write it like:
      #
      #     extend ::Gitlab::Utils::Override
      #
      #     override :f
      #     def f
      #       true
      #     end
      #
      # This would make sure we're overriding something. See:
      # https://gitlab.com/gitlab-org/gitlab-ee/issues/1819
      def override(method_name)
        return unless ENV['STATIC_VERIFICATION']

        Override.extensions[self] ||= Extension.new(self)
        Override.extensions[self].add_method_name(method_name)
      end

      def method_added(method_name)
        super

        return unless ENV['STATIC_VERIFICATION']
        return unless Override.extensions[self]&.verify_override?(method_name)

        method_arity = instance_method(method_name).parameters.length
        if is_a?(Class)
          Extension.verify_class!(self, method_name, method_arity)
        else # We delay the check for modules
          Override.extensions[self].add_method_name(method_name, method_arity)
        end
      end

      def included(base = nil)
        super

        queue_verification(base) if base
      end

      def prepended(base = nil)
        super

        queue_verification(base) if base
      end

      def extended(mod = nil)
        super

        queue_verification(mod.singleton_class) if mod
      end

      def queue_verification(base)
        return unless ENV['STATIC_VERIFICATION']

        if base.is_a?(Class) # We could check for Class in `override`
          # This could be `nil` if `override` was never called
          Override.extensions[self]&.add_class(base)
        end
      end

      def self.extensions
        @extensions ||= {}
      end

      def self.verify!
        extensions.values.each(&:verify!)
      end
    end
  end
end
