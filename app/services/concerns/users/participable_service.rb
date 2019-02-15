# frozen_string_literal: true

module Users
  module ParticipableService
    extend ActiveSupport::Concern

    included do
      attr_reader :noteable
    end

    def noteable_owner
      return [] unless noteable && noteable.author.present?

      [as_hash(noteable.author)]
    end

    def participants_in_noteable
      return [] unless noteable

      users = noteable.participants(current_user)
      sorted(users)
    end

    def sorted(users)
      users.uniq.to_a.compact.sort_by(&:username).map do |user|
        as_hash(user)
      end
    end

    def groups
      current_user.authorized_groups.sort_by(&:path).map do |group|
        as_hash(group)
      end
    end

    private

    def as_hash(user)
      type_hash = user.is_a?(Group) ? group_as_hash(user) : project_as_hash(user)
      { type: user.class.name, avatar: user.avatar_url }.merge(type_hash)
    end

    def project_as_hash(user)
      { username: user.username, name: user.name }
    end

    def group_as_hash(group)
      { username: group.full_path, name: group.full_name, count: group.users.count }
    end
  end
end
