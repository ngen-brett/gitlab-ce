# frozen_string_literal: true

module UpdateProjectStatistics
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :update_project_statistics_attribute,
                :update_project_statistics_stat,
                :update_project_statistics_configured

    private

    def update_project_statistics(stat:, attribute: :size)
      @update_project_statistics_configured = true
      @update_project_statistics_stat = stat
      @update_project_statistics_attribute = attribute
    end
  end

  included do
    after_save :update_project_statistics_after_save, if: :update_project_statistics_configured_and_attribute_changed?
    after_destroy :update_project_statistics_after_destroy, if: :update_project_statistics_configured_and_not_project_destroyed?

    def project_destroyed?
      project.pending_delete?
    end

    def update_project_statistics_attribute_changed?
      attribute_changed?(self.class.update_project_statistics_attribute)
    end

    def update_project_statistics_configured_and_attribute_changed?
      return false unless self.class.update_project_statistics_configured

      update_project_statistics_attribute_changed?
    end

    def update_project_statistics_configured_and_not_project_destroyed?
      return false unless self.class.update_project_statistics_configured

      !project_destroyed?
    end

    def update_project_statistics_after_save
      attr = self.class.update_project_statistics_attribute
      delta = read_attribute(attr).to_i - attribute_was(attr).to_i

      update_project_statistics(delta)
    end

    def update_project_statistics_after_destroy
      update_project_statistics(-read_attribute(self.class.update_project_statistics_attribute).to_i)
    end

    def update_project_statistics(delta)
      ProjectStatistics.increment_statistic(project_id, self.class.update_project_statistics_stat, delta)
    end
  end
end
