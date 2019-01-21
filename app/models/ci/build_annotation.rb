# frozen_string_literal: true

module Ci
  class BuildAnnotation < ActiveRecord::Base
    self.table_name = 'ci_build_annotations'

    belongs_to :build, class_name: 'Ci::Build'

    enum severity: {
      info: 0,
      warning: 1,
      error: 2
    }

    validates :severity, presence: true
    validates :ci_build_id, presence: true
    validates :summary, presence: true, length: { maximum: 512 }
    validates :line_number, inclusion: { in: -32768..32767 }

    def summary_html
      if summary_html_from_redis
        summary_html_from_redis
      else
        raise 'The HTML cache for the summary must be eager loaded'
      end
    end

    def description_html
    end
  end
end
