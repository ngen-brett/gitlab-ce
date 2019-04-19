# rubocop:disable Naming/FileName
# frozen_string_literal: true

ServiceResponse = Struct.new(
  :status, :message, :http_status, keyword_init: true) do

  def self.success(message: nil)
    new(status: :success, message: message)
  end

  def self.error(message:, http_status: nil)
    new(status: :error, message: message, http_status: http_status)
  end

  def success?
    status == :success
  end

  def error?
    status == :error
  end
end
