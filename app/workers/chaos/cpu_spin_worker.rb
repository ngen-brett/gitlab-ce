# frozen_string_literal: true

module Chaos
  class CPUSpinWorker
    include ApplicationWorker
    include ChaosQueue

    def perform(duration_s)
      Gitlab::Chaos.cpuspin(duration_s)
    end
  end
end
