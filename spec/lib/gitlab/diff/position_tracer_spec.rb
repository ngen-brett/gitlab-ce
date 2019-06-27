require 'spec_helper'

describe Gitlab::Diff::PositionTracer do
  describe '.for' do
    subject { described_class.for(type, project: double, old_diff_refs: double, new_diff_refs: double) }

    context 'type is text' do
      let(:type) { 'text' }

      it 'returns a LinePositionTracer' do
        expect(subject).to be_a(Gitlab::Diff::PositionTracer::LinePositionTracer)
      end
    end
  end
end
