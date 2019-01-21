require 'spec_helper'

describe Gitlab::BackgroundMigration::MigrateLegacyUploads, :migration, schema: 20190103140724 do
  let(:test_dir) { FileUploader.options['storage_path'] }

  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:notes) { table(:notes) }
  let(:uploads) { table(:uploads) }

  let!(:namespace) { namespaces.create!(name: 'namespace', path: 'namespace') }
  let!(:project) { projects.create!(name: 'test', path: 'test', namespace_id: namespace.id) }
  let!(:note1) { notes.create!(note: 'some note text awesome', project_id: project.id, attachment: 'image.png') }
  let!(:note2) { notes.create!(note: 'some note bad', project_id: project.id, attachment: 'text.pdf') }
  let!(:note3) { notes.create!(note: 'new note', project_id: project.id) }

  let(:legacy_upload1) do
    uploads.create(
      size: 10, path: "uploads/-/system/note/attachment/#{note1.id}/image.png", checksum: 'abc',
      model_id: note1.id, model_type: 'Note', uploader: 'AttachmentUploader', store: 1, secret: nil)
  end
  let(:legacy_upload2) do
    uploads.create(
      size: 10, path: "uploads/-/system/note/attachment/#{note2.id}/text.pdf", checksum: 'def',
      model_id: note2.id, model_type: 'Note', uploader: 'AttachmentUploader', store: 1, secret: nil)
  end
  let(:standard_upload) do
    uploads.create(
      size: 10, path: "secretabcde/image.png", checksum: 'xyz', secret: 'secretabcde',
      model_id: project.id, model_type: 'Project', uploader: 'FileUploader', store: 1)
  end
  let(:legacy_uploads) { [legacy_upload1, legacy_upload2] }

  before do
    absolute_path = File.join(test_dir, legacy_upload1.path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    FileUtils.touch(absolute_path)

    absolute_path = File.join(test_dir, legacy_upload2.path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    FileUtils.touch(absolute_path)

    described_class.new.perform
  end

  it 'migrates legacy uploads to the correct location' do
    expected_path1 = File.join(test_dir, 'uploads', namespace.path, project.path, "#{legacy_upload1.reload.secret}", 'image.png')
    expected_path2 = File.join(test_dir, 'uploads', namespace.path, project.path, "#{legacy_upload2.reload.secret}", 'text.pdf')

    expect(File.exist?(expected_path1)).to be_truthy
    expect(File.exist?(expected_path2)).to be_truthy
  end

  it 'updates the legacy upload records correctly' do
    legacy_upload1.reload
    expect(legacy_upload1.secret).not_to be_nil
    expect(legacy_upload1.path).to eq("#{legacy_upload1.secret}/image.png")
    expect(legacy_upload1.model_id).to eq(project.id)
    expect(legacy_upload1.model_type).to eq('Project')
    expect(legacy_upload1.uploader).to eq('FileUploader')

    legacy_upload2.reload
    expect(legacy_upload2.secret).not_to be_nil
    expect(legacy_upload2.path).to eq("#{legacy_upload2.secret}/text.pdf")
    expect(legacy_upload2.model_id).to eq(project.id)
    expect(legacy_upload2.model_type).to eq('Project')
    expect(legacy_upload2.uploader).to eq('FileUploader')
  end

  it 'updates the legacy upload notes so that they include the file references in the mardown' do
    expected_path = File.join(test_dir, 'uploads', namespace.path, project.path, "#{legacy_upload1.reload.secret}", 'image.png')
    expected_markdown = "some note text awesome \n [attachment](#{expected_path})"

    expected_path = File.join(test_dir, 'uploads', namespace.path, project.path, "#{legacy_upload2.reload.secret}", 'text.pdf')
    expected_markdown = "some note bad \n [attachment](#{expected_path})"
  end

  it 'removes the attachment from the note' do
    expect(note1.attachment).to be_nil
    expect(note2.attachment).to be_nil
  end
end
