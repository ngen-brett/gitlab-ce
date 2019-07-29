# frozen_string_literal: true

class AddMergeRequestsRequireCodeOwnerApprovalToProtectedBranches < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    add_column :protected_branches, :merge_requests_require_code_owner_approval, :boolean
  end
end
