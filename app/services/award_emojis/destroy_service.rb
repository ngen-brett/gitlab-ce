# frozen_string_literal: true

module AwardEmojis
  class DestroyService < AwardEmojis::BaseService
    def execute
      # return error('User cannot award emoji to awardable') unless awardable.user_can_award?(current_user)
      # return error('Awardable cannot be awarded emoji') unless awardable.emoji_awardable?

      # Is this check correct? - it's based off of the REST Api check
      #
      unless awardable.awarded_emoji?(name, current_user) || current_user.admin?
        return error("User cannot destroy emoji of type #{name} on the awardable", :forbidden)
      end

      # May need to make a finder??
      awards = awardable.award_emoji.where(name: name, user: current_user).destroy_all # rubocop: disable DestroyAll
      errors = collect_errors(awards)

      return error(errors) if errors

      success
    end

    private

    def collect_errors(awards)
      awards.map { |a| a.errors.full_messages }.to_sentence.presence
    end
  end
end
