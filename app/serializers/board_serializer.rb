# frozen_string_literal: true

class BoardSerializer < BaseSerializer
  entity BoardSimpleEntity

  def represent(resource, opts = {})
    if resource.is_a?(ActiveRecord::Relation)
      raise "doing a thing"
      resource = resource.with_associations
    end

    super
  end

end
