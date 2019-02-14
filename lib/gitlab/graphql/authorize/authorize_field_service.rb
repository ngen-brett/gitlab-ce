# frozen_string_literal: true

module Gitlab
  module Graphql
    module Authorize
      class AuthorizeFieldService
        def initialize(type, field)
          @type = type
          @field = field
          @old_resolve_proc = @field.resolve_proc
        end

        def authorization_checks?
          authorization_checks.present?
        end

        def authorized_resolve
          proc do |obj, args, ctx|
            resolved_object = @old_resolve_proc.call(obj, args, ctx)

            authorized = authorization_checks.all? do |authorization_check|
              # Authorization checks can be a Symbol (i.e.: :read_project)
              # or a Proc.
              #
              # If the check is a Symbol, turn this into an Ability check.
              if authorization_check.is_a?(Symbol)
                ability_subject = subject_for_ability(resolved_object, obj)
                Ability.allowed?(ctx[:current_user], authorization_check, ability_subject)
              elsif authorization_check.is_a?(Proc)
                authorization_check.call(obj, args, ctx)
              else
                raise NotImplementedError, "Cannot handle authorization for #{authorization_check.inspect}"
              end
            end

            if authorized
              resolved_object
            end
          end
        end

        private

        def authorization_checks
          type_authorization_checks + field_authorization_checks
        end

        # Returns any authorize metadata from the return type of @field
        def type_authorization_checks
          type = @field.metadata[:type_class]&.type
          if type.respond_to?(:authorize) && type.authorize
            type.authorize.flatten
          end
        end

        # Returns any authorize metadata from the field
        def field_authorization_checks
          Array.wrap(@field.metadata[:authorize])
        end

        def subject_for_ability(resolved_object, obj)
          if resolved_object.respond_to?(:sync)
            resolved_object.sync
          else
            obj.object
          end
        end
      end
    end
  end
end
