# frozen_string_literal: true

require 'spec_helper'

describe UserEmailsFinder do
  describe '#execute' do
    let(:user) { create(:user) }
    let!(:email1) { create(:email, user: user) }
    let!(:email2) { create(:email, user: user) }

    def expect_emails(emails, expected_emails)
      expect(slice_email_attributes(emails)).to eq(slice_email_attributes(expected_emails))
    end

    def slice_email_attributes(emails)
      emails.map { |email| email.slice('id', 'email') }
    end

    it 'returns the primary email with nil id when types is primary' do
      emails = described_class.new(user.reload, types: %w[primary]).execute

      expect_emails(emails, [Email.new(email: user.email)])
    end

    it 'returns the secondary emails when types is secondary' do
      emails = described_class.new(user.reload, types: %w[secondary]).execute

      expect_emails(emails, [email1, email2])
    end

    it 'returns both primary and secondary emails when type is primary,secondary sorted by id asc null first' do
      emails = described_class.new(user.reload, types: %w[primary secondary]).execute

      expect_emails(emails, [Email.new(email: user.email), email1, email2])
    end

    it 'returns an empty relation when types is empty' do
      emails = described_class.new(user.reload, types: []).execute

      expect(emails).to be_empty
    end
  end
end
