# frozen_string_literal: true

require 'fast_spec_helper'
require 'rspec-parameterized'

describe Gitlab::Tracing::Rails::ActionViewSubscriber do
  using RSpec::Parameterized::TableSyntax

  describe '.instrument' do
    it 'is unsubscribeable' do
      unsubscribe = described_class.instrument

      expect(unsubscribe).not_to be_nil
      expect { unsubscribe.call }.not_to raise_error
    end
  end

  describe '#notify_render_template' do
    subject { described_class.new }
    let(:start) { Time.now }
    let(:finish) { Time.now }

    where(:identifier, :layout, :exception) do
      nil         | nil           | nil
      ""          | nil           | nil
      "show.haml" | nil           | nil
      nil         | ""            | nil
      nil         | "layout.haml" | nil
      nil         | nil           | StandardError.new
    end

    with_them do
      def payload
        {
          exception: exception,
          identifier: identifier,
          layout: layout
        }
      end

      def expected_tags
        {
          'component' =>       'ActionView',
          'span.kind' =>       'client',
          'template.id' =>     identifier,
          'template.layout' => layout
        }
      end

      it 'should notify the tracer when the hash contains null values' do
        expect(subject).to receive(:postnotify_span).with("render_template", start, finish, tags: expected_tags, exception: exception)

        subject.notify_render_template(start, finish, payload)
      end

      it 'should notify the tracer when the payload is missing values' do
        expect(subject).to receive(:postnotify_span).with("render_template", start, finish, tags: expected_tags, exception: exception)

        subject.notify_render_template(start, finish, payload.compact)
      end

      it 'should not throw exceptions when with the default tracer' do
        expect { subject.notify_render_template(start, finish, payload) }.not_to raise_error
      end
    end
  end

  describe '#notify_render_collection' do
    subject { described_class.new }
    let(:start) { Time.now }
    let(:finish) { Time.now }

    where(
      :identifier, :count, :expected_count, :cache_hits, :expected_cache_hits, :exception) do
      nil         | nil           | 0 | nil | 0 | nil
      ""          | nil           | 0 | nil | 0 | nil
      "show.haml" | nil           | 0 | nil | 0 | nil
      nil         | 0             | 0 | nil | 0 | nil
      nil         | 1             | 1 | nil | 0 | nil
      nil         | nil           | 0 | 0   | 0 | nil
      nil         | nil           | 0 | 1   | 1 | nil
      nil         | nil           | 0 | nil | 0 | StandardError.new
    end

    with_them do
      def payload
        {
          exception: exception,
          identifier: identifier,
          count: count,
          cache_hits: cache_hits
        }
      end

      def expected_tags
        {
          'component' =>            'ActionView',
          'span.kind' =>            'client',
          'template.id' =>          identifier,
          'template.count' =>       expected_count,
          'template.cache.hits' =>  expected_cache_hits
        }
      end

      it 'should notify the tracer when the hash contains null values' do
        expect(subject).to receive(:postnotify_span).with("render_collection", start, finish, tags: expected_tags, exception: exception)

        subject.notify_render_collection(start, finish, payload)
      end

      it 'should notify the tracer when the payload is missing values' do
        expect(subject).to receive(:postnotify_span).with("render_collection", start, finish, tags: expected_tags, exception: exception)

        subject.notify_render_collection(start, finish, payload.compact)
      end

      it 'should not throw exceptions when with the default tracer' do
        expect { subject.notify_render_collection(start, finish, payload) }.not_to raise_error
      end
    end
  end

  describe '#notify_render_partial' do
    subject { described_class.new }
    let(:start) { Time.now }
    let(:finish) { Time.now }

    where(:identifier, :exception) do
      nil         | nil
      ""          | nil
      "show.haml" | nil
      nil         | StandardError.new
    end

    with_them do
      def payload
        {
          exception: exception,
          identifier: identifier
        }
      end

      def expected_tags
        {
          'component' =>            'ActionView',
          'span.kind' =>            'client',
          'template.id' =>          identifier
        }
      end

      it 'should notify the tracer when the hash contains null values' do
        expect(subject).to receive(:postnotify_span).with("render_partial", start, finish, tags: expected_tags, exception: exception)

        subject.notify_render_partial(start, finish, payload)
      end

      it 'should notify the tracer when the payload is missing values' do
        expect(subject).to receive(:postnotify_span).with("render_partial", start, finish, tags: expected_tags, exception: exception)

        subject.notify_render_partial(start, finish, payload.compact)
      end

      it 'should not throw exceptions when with the default tracer' do
        expect { subject.notify_render_partial(start, finish, payload) }.not_to raise_error
      end
    end
  end
end
