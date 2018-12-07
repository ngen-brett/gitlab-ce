# frozen_string_literal: true

# The PoolRepository model is the database equivalent of an ObjectPool for Gitaly
# That is; PoolRepository is the record in the database, ObjectPool is the
# repository on disk
class PoolRepository < ActiveRecord::Base
  include Shardable

  has_many :member_projects, class_name: 'Project'

  after_create :correct_disk_path

  private

  def correct_disk_path
    update!(disk_path: storage.disk_path)
  end

  def storage
    Storage::HashedProject
      .new(self, prefix: Storage::HashedProject::POOL_PATH_PREFIX)
  end
end
