# frozen_string_literal: true

module Gitlab
  # Chaos methods for GitLab. See https://docs.gitlab.com/ee/development/chaos_endpoints.html for more details.
  class Chaos
    def self.leakmem(memory_mb, duration_s)
      start_time = Time.now

      retainer = []
      # Add `n` 1mb chunks of memory to the retainer array
      memory_mb.times { retainer << "x" * 1.megabyte }

      duration_left = [start_time + duration_s - Time.now, 0].max
      Kernel.sleep(duration_left)
    end

    def self.cpu_spin(duration_s)
      expected_end_time = Time.now + duration_s

      rand while Time.now < expected_end_time
    end

    def self.db_spin(duration_s, interval_s)
      expected_end_time = Time.now + duration_s

      while Time.now < expected_end_time
        ActiveRecord::Base.connection.execute("SELECT 1")

        end_interval_time = Time.now + [duration_s, interval_s].min
        rand while Time.now < end_interval_time
      end
    end

    def self.sleep(duration_s)
      Kernel.sleep(duration_s)
    end

    def self.kill
      Process.kill("KILL", Process.pid)
    end

  end
end
