# frozen_string_literal: true

module ExperimentHelper
  def experiment_show_recaptcha_sign_up?
    Gitlab::Recaptcha.enabled?
  end
end
