# frozen_string_literal: true

require 'spec_helper'

describe Admin::RequestsProfilesController do
  set(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe '#show' do
    def generate_basename(profile_type, extension)
      "profile_#{Time.now.to_i}_#{profile_type}.#{extension}"
    end

    def prepare_profile_report_file(basename, sample_data)
      tmpdir = Dir.mktmpdir('profiler-test')
      test_file = File.join(tmpdir, basename)

      create_file(tmpdir, test_file, sample_data)
    end

    def create_file(dir, file_path, data)
      stub_const('Gitlab::RequestProfiler::PROFILES_DIR', dir)
      output = File.open(file_path, 'w')
      output.write(data)
      output.close

      file_path
    end

    def delete_file(file_path)
      File.unlink(file_path)
    end

    it 'loads an HTML profile' do
      sample_data =
        <<~HTML
          <!DOCTYPE html>
          <html>
          <body>
          <h1>My First Heading</h1>
          <p>My first paragraph.</p>
          </body>
          </html>
        HTML

      basename = generate_basename('execution', 'html')
      test_file = prepare_profile_report_file(basename, sample_data)

      get :show, params: { name: basename }

      expect(response).to have_gitlab_http_status(200)
      expect(response.body).to eq(sample_data)

      delete_file(test_file)
    end

    it 'loads a TXT profile' do
      sample_data =
        <<~TXT
          Total allocated: 112096396 bytes (1080431 objects)
          Total retained:  10312598 bytes (53567 objects)

          allocated memory by gem
          -----------------------------------
              12416994  sprockets-3.7.2
            11530224  json-1.8.6
        TXT

      basename = generate_basename('memory', 'txt')
      test_file = prepare_profile_report_file(basename, sample_data)

      get :show, params: { name: basename }

      expect(response).to have_gitlab_http_status(200)
      expect(response.body).to eq(sample_data)

      delete_file(test_file)
    end

    it 'loads a PDF profile' do
      sample_data =
        <<~PDF
          Sample content of a PDF file.
        PDF

      basename = generate_basename('memory', 'pdf')
      test_file = prepare_profile_report_file(basename, sample_data)

      expect { get :show, params: { name: basename } }.to raise_error(ActionController::UrlGenerationError, /No route matches.*unmatched constraints:/)

      delete_file(test_file)
    end
  end
end
