# frozen_string_literal: true

require 'spec_helper'

describe CreateSnippetService do
  before do
    @user = create :user
    @admin = create :user, admin: true
    @opts = {
      title: 'Test snippet',
      file_name: 'snippet.rb',
      content: 'puts "hello world"',
      visibility_level: Gitlab::VisibilityLevel::PRIVATE
    }
  end

  context 'When public visibility is restricted' do
    before do
      stub_application_setting(restricted_visibility_levels: [Gitlab::VisibilityLevel::PUBLIC])

      @opts.merge!(visibility_level: Gitlab::VisibilityLevel::PUBLIC)
    end

    it 'non-admins are not able to create a public snippet' do
      snippet = create_snippet(nil, @user, @opts)
      expect(snippet.errors.messages).to have_key(:visibility_level)
      expect(snippet.errors.messages[:visibility_level].first).to(
        match('has been restricted')
      )
    end

    it 'admins are able to create a public snippet' do
      snippet = create_snippet(nil, @admin, @opts)
      expect(snippet.errors.any?).to be_falsey
      expect(snippet.visibility_level).to eq(Gitlab::VisibilityLevel::PUBLIC)
    end
  end

  context 'checking spam' do
    shared_examples 'marked as spam' do
      let(:snippet) { create_snippet(nil, @admin, @opts) }
      it 'marks a snippet as a spam ' do
        expect(snippet).to be_spam
      end

      it 'an issue is not valid ' do
        expect(snippet.valid?).to be_falsey
      end

      it 'creates a new spam_log' do
        expect {snippet}.to change {SpamLog.count}.from(0).to(1)
      end

      it 'assigns a spam_log to an issue' do
        expect(snippet.spam_log).to eq(SpamLog.last)
      end
    end

    before do
      @opts.merge!(visibility_level: Gitlab::VisibilityLevel::PUBLIC, request: double(:request, env: {})
      )
      allow_any_instance_of(AkismetService).to receive(:spam?).and_return(true)
    end

    context 'when recaptcha_disabled feature flag is false' do
      before do
        stub_feature_flags(recaptcha_disabled: false)
      end

      it_behaves_like 'marked as spam'
    end

    context 'when recaptcha_disabled feature flag is true' do
      before do
        stub_feature_flags(recaptcha_disabled: true)
      end

      it_behaves_like 'marked as spam'
    end
  end

  describe 'usage counter' do
    let(:counter) { Gitlab::UsageDataCounters::SnippetCounter }

    it 'increments count' do
      expect do
        create_snippet(nil, @admin, @opts)
      end.to change { counter.read(:create) }.by 1
    end

    it 'does not increment count if create fails' do
      expect do
        create_snippet(nil, @admin, {})
      end.not_to change { counter.read(:create) }
    end
  end

  def create_snippet(project, user, opts)
    CreateSnippetService.new(project, user, opts).execute
  end
end
