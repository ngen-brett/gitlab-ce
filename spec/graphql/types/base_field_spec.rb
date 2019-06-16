# frozen_string_literal: true

require 'spec_helper'

describe Types::BaseField do
  let(:default_test_complexity) { 1 }

  context 'when considering complexity' do
    let(:resolver) do
      Class.new(described_class) do
        def self.resolver_complexity(args)
          2 if args[:foo]
        end

        def self.complexity_multiplier(args)
          0.01
        end
      end
    end

    it 'defaults to 1' do
      field = described_class.new(name: 'test', type: GraphQL::STRING_TYPE, null: true)

      expect(field.to_graphql.complexity).to eq default_test_complexity
    end

    it 'has specified value' do
      field = described_class.new(name: 'test', type: GraphQL::STRING_TYPE, null: true, complexity: 12)

      expect(field.to_graphql.complexity).to eq 12
    end

    it 'sets complexity depending on arguments for resolvers' do
      field = described_class.new(name: 'test', type: GraphQL::STRING_TYPE, resolver_class: resolver, max_page_size: 100, null: true)

      expect(field.to_graphql.complexity.call({}, {}, 2)).to eq 4
      expect(field.to_graphql.complexity.call({}, { first: 50 }, 2)).to eq 3
    end

    it 'sets complexity depending on number load limits for resolvers' do
      field = described_class.new(name: 'test', type: GraphQL::STRING_TYPE, resolver_class: resolver, max_page_size: 100, null: true)

      expect(field.to_graphql.complexity.call({}, { first: 1 }, 2)).to eq 2
      expect(field.to_graphql.complexity.call({}, { first: 1, foo: true }, 2)).to eq 4
    end

    context 'calls_gitaly' do
      it 'adds 1 if true' do
        field = described_class.new(name: 'test', type: GraphQL::STRING_TYPE, null: true, calls_gitaly: true)

        expect(field.to_graphql.complexity).to eq 2
      end

      it 'defaults to false and adds nothing' do
        field = described_class.new(name: 'test', type: GraphQL::STRING_TYPE, null: true)

        expect(field.to_graphql.complexity).to eq default_test_complexity
      end
    end

    describe '#calls_gitaly_check' do
      let(:gitaly_field) { described_class.new(name: 'test', type: GraphQL::STRING_TYPE, null: true, calls_gitaly: true) }
      let(:no_gitaly_field) { described_class.new(name: 'test', type: GraphQL::STRING_TYPE, null: true, calls_gitaly: false) }

      context 'if there are no Gitaly calls' do
        before do
          allow(Gitlab::GitalyClient).to receive(:get_request_count).and_return(0)
        end

        it 'does not raise an error if calls_gitaly is false' do
          expect(no_gitaly_field.send(:calls_gitaly_check)).to_not raise_error
        end

        it 'raises an error if calls_gitaly is true' do
          expect(gitaly_field.send(:calls_gitaly_check)).to_not raise_error
        end
      end

      context 'if there is at least 1 Gitaly call' do
        before do
          allow(Gitlab::GitalyClient).to receive(:get_request_count).and_return(1)
        end

        it 'does not raise an error if calls_gitaly is true' do
          expect(gitaly_field.send(:calls_gitaly_check)).to_not raise_error
        end

        it 'raises an error if calls_gitaly is false' do
          expect(no_gitaly_field.send(:calls_gitaly_check)).to_not raise_error
        end
      end
    end
  end
end
