# frozen_string_literal: true

require 'rails_helper'

describe Gitlab::BackgroundMigration::PopulateNamespaceRootIdColumn, :migration, schema: 20190617181054 do
  let(:namespaces_table) { table(:namespaces) }

  let(:gitlab_org) { namespaces_table.create(name: 'gitlab', path: 'gitlab-org') }

  def create_child_namespace_for(parent_id:, id:)
    namespaces_table.create(
      name: "group_#{id}",
      path: "group_#{id}",
      parent_id: parent_id
    )
  end

  describe '#perform' do
    before do
      (1..10).each do |group_id|
        create_child_namespace_for(parent_id: gitlab_org.id, id: group_id)
      end
    end

    it 'updates the root id of all namespaces' do
      subject.perform(1, 4)

      gitlab_org.reload

      self_and_descendants = namespaces_table.where(parent_id: gitlab_org.id)

      self_and_descendants.each do |group|
        expect(group.root_id).to eq(gitlab_org.id)
      end
    end

    context 'when group has inner groups' do
      it 'should update inner groups'
    end
  end
end
