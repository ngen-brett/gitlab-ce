# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MigrateLegacyUploads < ActiveRecord::Migration[5.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  MIGRATION = 'PrepareUntrackedUploads'

  def up
    BackgroundMigrationWorker.perform_async(MIGRATION)
  end

  # not needed
  def down
  end
end



{
  "id"=>2293755,
  "size"=>66616,
  "path"=>"uploads/-/system/note/attachment/104322/non-resourceful-routes.png",
  "checksum"=>"07be2c8ba605fddb9cb170bca116b50852cf53eaccb7b535175354170c095b3e",
  "model_id"=>104322,
  "model_type"=>"Note",
  "uploader"=>"AttachmentUploader",
  "created_at"=>Wed, 20 Dec 2017 19:05:40 UTC +00:00,
  "store"=>1,
  "mount_point"=>nil,
  "secret"=>nil
}


<Upload:0x00007fb2c247fa78
 id: 2,
 size: 463378,
 path: "c0157a5da5e0eb3baeb7953b2468fb44/recepty-04-proteinove-chispy.png",
 checksum: "86469b78ea6910568e255767ad585eb2f05959f7ed23805b609a1b9189a75640",
 model_id: 6,
 model_type: "Project",
 uploader: "FileUploader",
 created_at: Tue, 08 Jan 2019 13:57:45 UTC +00:00,
 store: 1,
 mount_point: nil,
 secret: "c0157a5da5e0eb3baeb7953b2468fb44">



 #<LegacyDiffNote id: 104322,
 note: "If you're defining routes using HTTP VERB, again n...",
 noteable_type: "Commit",
 author_id: 29746,
 created_at: "2014-05-14 08:57:03",
 updated_at: "2014-05-14 08:57:03",
 project_id: 36787,
 attachment: "non-resourceful-routes.png",
 line_code: "f30f8125d530a2f0316a8ebb6d25ab234f9a6814_8_14",
 commit_id: "708ef3737a26a3c9eaa91fc674f4926b51ef817d",
 noteable_id: nil,
 type: "LegacyDiffNote",
 note_html: nil, cached_markdown_version: nil, change_position: nil, resolved_by_push: nil, review_id: nil>```



note.note
"If you're defining routes using HTTP VERB, again no need to mention HTTP VERB using via key.
\r\n\r\n\r\n>**Example:**\r\n```ruby\r\nget \"/login\" => redirect(\"auth/identity\"), as: login\r\n```\r\nor\r\n```
ruby\r\nmatch \"login\" => redirect(\"auth/identity\"), via: :get\r\n```\r\n\r\nFor details refer the topic
**\"Non-Resourceful routes\"** at the following url, http://guides.rubyonrails.org/routing.html"

note.attachment
=> #<AttachmentUploader:0x00007f5cdae75a98
  @model=
  #<LegacyDiffNote id: 104322, note: "If you're defining routes using HTTP VERB, again n...", noteable_type: "Commit", author_id: 29746, created_at: "2014-05-14 08:57:03", updated_at: "2014-05-14 08:57:03", project_id: 36787, attachment: "non-resourceful-routes.png", line_code: "f30f8125d530a2f0316a8ebb6d25ab234f9a6814_8_14", commit_id: "708ef3737a26a3c9eaa91fc674f4926b51ef817d", noteable_id: nil, st_diff: {:diff=>"--- a/gayathri/rails/merchant/config/routes.rb\n+++ b/gayathri/rails/merchant/config/routes.rb\n@@ -1,10 +1,21 @@\n Merchant::Application.routes.draw do\n+\n+  resources :addresses\n+\n   resources :orders\n \n   resources :order_items\n \n   resources :products\n-  root to: \"products#index\"\n+  \n+  post \"/auth/:provider/callback\", to: \"sessions#create\"\n+  get \"auth/failure\",  to: \"sessions#failure\"\n+\n+  get \"/login\" => redirect(\"/auth/identity\"), as: :login, via: :get\n+  get \"/logout\" => \"sessions#destroy\", as: :logout, via: :get\n+\n+  resources :identities\n+  root to: \"sessions#new\"\n \n   # The priority is based upon order of creation: first created -> highest priority.\n   # See how all your routes lay out with \"rake routes\".", :new_path=>"gayathri/rails/merchant/config/routes.rb", :old_path=>"gayathri/rails/merchant/config/routes.rb", :a_mode=>nil, :b_mode=>"100644", :new_file=>false, :renamed_file=>false, :deleted_file=>false}, system: false, updated_by_id: nil, type: "LegacyDiffNote", position: nil, original_position: nil, resolved_at: nil, resolved_by_id: nil, discussion_id: "7a6f35d7c88da85ca05a2a329344a973d0436a6d", note_html: nil, cached_markdown_version: nil, change_position: nil, resolved_by_push: nil, review_id: nil>,
  @mounted_as=:attachment,

  @file=#<CarrierWave::SanitizedFile:0x00007f5cdb558018
    @file="/opt/gitlab/embedded/service/gitlab-rails/public/uploads/-/system/legacy_diff_note/attachment/104322/non-resourceful-routes.png",
    @original_filename=nil, @content_type=nil, @content=nil>, @filename=nil, @cache_id=nil, @versions={}, @object_store=1,
    @storage=#<CarrierWave::Storage::File:0x00007f5cdb59b2c8 @uploader=#<AttachmentUploader:0x00007f5cdae75a98 ...>, @cache_called=nil>>```
