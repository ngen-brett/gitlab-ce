# frozen_string_literal: true

module HasVariable
  extend ActiveSupport::Concern

  class_methods do
    def variable_type_options
      [
        %w(Variable env_var),
        %w(File file)
      ]
    end
  end

  included do
    enum variable_type: {
      env_var: 1,
      file: 2
    }

    validates :key,
      presence: true,
      length: { maximum: 255 },
      format: { with: /\A[a-zA-Z0-9_]+\z/,
                message: "can contain only letters, digits and '_'." }

    scope :order_key_asc, -> { reorder(key: :asc) }

    attr_encrypted :value,
       mode: :per_attribute_iv_and_salt,
       insecure_mode: true,
       key: Settings.attr_encrypted_db_key_base,
       algorithm: 'aes-256-cbc'

    def key=(new_key)
      super(new_key.to_s.strip)
    end

    def variable_type
      super.presence || 'env_var'
    end
  end

  def to_runner_variable
    { key: key, value: value, public: false, file: file? }
  end
end
