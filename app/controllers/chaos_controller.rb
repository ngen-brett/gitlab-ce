# frozen_string_literal: true

class ChaosController < ActionController::Base
  before_action :validate_chaos_secret, unless: :development?

  def leakmem
    do_chaos :leakmem, Chaos::LeakMemWorker, memory_mb, duration_s
  end

  def cpu_spin
    do_chaos :leakmem, Chaos::CPUSpinWorker, duration_s
  end

  def db_spin
    do_chaos :db_spin, Chaos::DBSpinWorker, duration_s, interval_s
  end

  def sleep
    do_chaos :sleep, Chaos::SleepWorker, duration_s
  end

  def kill
    do_chaos :kill, Chaos::KillWorker
  end

  private

  def do_chaos(method, worker, *args)
    if async
      worker.perform_async(*args)
    else
      Gitlab::Chaos.method(method).call(*args)
    end

    render plain: "OK"
  end

  def validate_chaos_secret
    unless chaos_secret_configured
      render plain: "chaos misconfigured: please configure GITLAB_CHAOS_SECRET",
             status: :internal_server_error
      return
    end

    unless Devise.secure_compare(chaos_secret_configured, chaos_secret_request)
      render plain: "To experience chaos, please set a valid `X-Chaos-Secret` header or `token` param",
             status: :unauthorized
      return
    end
  end

  def chaos_secret_configured
    ENV['GITLAB_CHAOS_SECRET']
  end

  def chaos_secret_request
    request.headers["HTTP_X_CHAOS_SECRET"] || params[:token]
  end

  def interval_s
    interval_s = params[:interval_s] || 1
    interval_s.to_f.seconds
  end

  def duration_s
    duration_s = params[:duration_s] || 30
    duration_s.to_i.seconds
  end

  def memory_mb
    memory_mb = params[:memory_mb] || 100
    memory_mb.to_i
  end

  def async
    async = params[:async] || false
    ActiveModel::Type::Boolean.new.cast(async)
  end

  def development?
    Rails.env.development?
  end
end
