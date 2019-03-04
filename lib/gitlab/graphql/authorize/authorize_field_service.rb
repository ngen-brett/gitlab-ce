# frozen_string_literal: true

module Gitlab
  module Graphql
    module Authorize
      class AuthorizeFieldService
        def initialize(field)
          @field = field
          @old_resolve_proc = @field.resolve_proc
        end

        def authorizations?
          authorizations.present?
        end

        def authorized_resolve
          proc do |obj, args, ctx|
            resolved_obj = @old_resolve_proc.call(obj, args, ctx)
            checker = build_checker(ctx[:current_user])

            if resolved_obj.respond_to?(:then)
              resolved_obj.then(&checker)
            else
              checker.call(resolved_obj)
            end
          end
        end

        private

        def authorizations
          @authorizations ||= (type_authorizations + field_authorizations).uniq
        end

        # Returns any authorize metadata from the return type of @field
        def type_authorizations
          type = @field.metadata[:type_class]&.type

          # For connections, dig to find the type class that might
          # have authorizations on it. This will be the type class of edges.node
          if type.respond_to?(:fields) && type.fields['edges']
            begin
              type = type.fields['edges'].type.unwrap.fields['node'].type.metadata[:type_class]
            rescue NoMethodError
              raise Gitlab::Graphql::Errors::ConnectionDefinitionError,
                    'Connection Type must conform to the Relay Cursor Connections Specification'
            end
          end

          if type.respond_to?(:to_graphql)
            Array.wrap(type.to_graphql.metadata[:authorize])
          else
            []
          end
        end

        # Returns any authorize metadata from @field
        def field_authorizations
          Array.wrap(@field.metadata[:authorize])
        end

        def build_checker(current_user)
          lambda do |value|
            # Load the elements if they were not loaded by BatchLoader yet
            value = value.sync if value.respond_to?(:sync)

            check = lambda do |object|
              authorizations.all? do |ability|
                Ability.allowed?(current_user, ability, object)
              end
            end

            case value
            when Array
              value.select(&check)
            else
              value if check.call(value)
            end
          end
        end
      end
    end
  end
end
