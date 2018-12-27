require 'spec_helper'

describe Releases::UpdateService do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:new_name) { 'A new name' }
  let(:new_description) { 'The best release!' }
  let(:params) { { name: new_name, description: new_description, tag: tag_name } }
  let(:service) { described_class.new(project, user, params) }
  let!(:release) { create(:release, project: project, author: user) }
  let(:tag_name) { release.tag }

  before do
    project.add_developer(user)
  end

  shared_examples 'a failed update' do
    it 'raises an error' do
      result = service.execute
      expect(result[:status]).to eq(:error)
    end
  end

  it 'successfully updates an existing release' do
    result = service.execute
    expect(result[:status]).to eq(:success)

    release = project.releases.find_by(tag: tag_name)
    expect(release.name).to eq(new_name)
    expect(release.description).to eq(new_description)
  end

  context 'when the tag does not exists' do
    let(:tag_name) { 'foobar' }

    it_behaves_like 'a failed update'
  end

  context 'when the release does not exist' do
    before do
      project.releases.delete_all
    end

    it_behaves_like 'a failed update'
  end

  context 'with an invalid update' do
    let(:new_description) { '' }

    it_behaves_like 'a failed update'
  end
end
