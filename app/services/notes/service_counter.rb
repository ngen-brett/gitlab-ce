# frozen_string_literal: true

module Notes
  module ServiceCounter
    extend ActiveSupport::Concern
    include ::ServiceCounter

    def usage_log(note)
      self.class.increment(self.class.usage_key(note.noteable_type))
    end

    class_methods do
      def usage_total_count(noteable_type)
        total_count(usage_key(noteable_type))
      end

      def usage_key(noteable_type)
        [name.underscore, noteable_type]
      end
    end
  end
end
