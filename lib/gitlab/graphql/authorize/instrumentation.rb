# frozen_string_literal: true

module Gitlab
  module Graphql
    module Authorize
      class Instrumentation
        # Replace the resolver for the field with one that will only return the
        # resolved object if the permissions check is successful.
        #
        # Collections are not supported. Apply permissions checks for those at the
        # database level instead, to avoid loading superfluous data from the DB
        def instrument(_type, field)
          authorization_checks = Array.wrap(field.metadata[:authorize])
          return field if authorization_checks.empty?

          old_resolver = field.resolve_proc

          new_resolver = -> (obj, args, ctx) do
            resolved_obj = old_resolver.call(obj, args, ctx)
            checker = build_checker(ctx[:current_user], authorization_checks)

            if resolved_obj.respond_to?(:then)
              resolved_obj.then(&checker)
            else
              checker.call(resolved_obj)
            end
          end

          field.redefine do
            resolve(new_resolver)
          end
        end

        private

        def build_checker(current_user, abilities)
          lambda do |value|
            # Load the elements if they weren't loaded by BatchLoader yet
            value = value.sync if value.respond_to?(:sync)

            check = lambda do |object|
              abilities.all? do |ability|
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
