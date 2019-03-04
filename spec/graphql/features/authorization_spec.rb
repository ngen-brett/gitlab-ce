# frozen_string_literal: true

require 'spec_helper'

describe 'Gitlab::Graphql::Authorization' do
  set(:user) { create(:user) }

  let(:permission_single) { :foo }
  let(:permission_collection) { [:foo, :bar] }
  let(:test_object) { double(name: 'My name') }
  let(:query_string) { '{ object() { name } }' }
  let(:result) { execute_query(query_type)['data'] }

  subject { result['object'] }

  shared_examples 'authorization with a single permission' do
    it 'returns the protected field when user has permission' do
      permit(permission_single)

      expect(subject).to eq('name' => test_object.name)
    end

    it 'returns nil when user is not authorized' do
      expect(subject).to be_nil
    end
  end

  shared_examples 'authorization with a collection of permissions' do
    it 'returns the protected field when user has all permissions' do
      permit(*permission_collection)

      expect(subject).to eq('name' => test_object.name)
    end

    it 'returns nil when user only has one of the permissions' do
      permit(permission_collection.first)

      expect(subject).to be_nil
    end

    it 'returns nil when user only has none of the permissions' do
      expect(subject).to be_nil
    end
  end

  before do
    # By default, disallow all permissions.
    allow(Ability).to receive(:allowed?).and_return(false)
  end

  describe 'Field authorizations' do
    let(:type) { type_factory }

    describe 'with a single permission' do
      let(:query_type) do
        query_factory do |query|
          query.field :object, type, null: true, resolve: ->(obj, args, ctx) { test_object }, authorize: permission_single
        end
      end

      include_examples 'authorization with a single permission'
    end

    describe 'with a collection of permissions' do
      let(:query_type) do
        query_factory do |qt|
          qt.field :object, type, null: true, resolve: ->(obj, args, ctx) { test_object } do
            authorize [:foo, :bar]
          end
        end
      end

      include_examples 'authorization with a collection of permissions'
    end

    describe 'Type authorizations' do
      let(:query_type) do
        query_factory do |query|
          query.field :object, type, null: true, resolve: ->(obj, args, ctx) { test_object }
        end
      end

      describe 'with a single permission' do
        let(:type) do
          type_factory do |type|
            type.authorize permission_single
          end
        end

        include_examples 'authorization with a single permission'
      end

      describe 'with a collection of permissions' do
        let(:type) do
          type_factory do |type|
            type.authorize permission_collection
          end
        end

        include_examples 'authorization with a collection of permissions'
      end
    end

    describe 'type and field authorizations together' do
      let(:permission_1) { permission_collection.first }
      let(:permission_2) { permission_collection.last }

      let(:type) do
        type_factory do |type|
          type.authorize permission_1
        end
      end

      let(:query_type) do
        query_factory do |query|
          query.field :object, type, null: true, resolve: ->(obj, args, ctx) { test_object }, authorize: permission_2
        end
      end

      include_examples 'authorization with a collection of permissions'
    end

    describe 'type authorizations when applied to a connection' do
      let(:query_string) { '{ object() { edges { node { name } } } }' }

      let(:type) do
        type_factory do |type|
          type.authorize permission_single
        end
      end

      let(:query_type) do
        query_factory do |query|
          query.field :object, type.connection_type, null: true, resolve: ->(obj, args, ctx) { [test_object] }
        end
      end

      subject { result.dig('object', 'edges') }

      it 'returns the protected field when user has permission' do
        permit(:foo)

        expect(subject).not_to be_empty
        expect(subject.first['node']).to eq('name' => test_object.name)
      end

      it 'returns nil when user is not authorized' do
        expect(subject).to be_empty
      end
    end

    describe 'when connections do not follow the correct specification' do
      let(:query_string) { '{ object() { edges { node { name }} } }' }

      let(:type) do
        bad_node = type_factory do |type|
          type.graphql_name 'BadNode'
          type.field :bad_node, GraphQL::STRING_TYPE, null: true
        end

        type_factory do |type|
          type.field :edges, [bad_node], null: true
        end
      end

      let(:query_type) do
        query_factory do |query|
          query.field :object, type, null: true, resolve: ->(obj, args, ctx) { double(edges: %w(foo bar)) }
        end
      end

      it 'throws an error' do
        expect { result }.to raise_error(Gitlab::Graphql::Errors::ConnectionDefinitionError)
      end
    end
  end

  private

  def permit(*permissions)
    permissions.each do |permission|
      allow(Ability).to receive(:allowed?).with(user, permission, test_object).and_return(true)
    end
  end

  def type_factory
    Class.new(Types::BaseObject) do
      graphql_name 'TestObject'

      field :name, GraphQL::STRING_TYPE, null: true

      yield(self) if block_given?
    end
  end

  def query_factory
    Class.new(Types::BaseObject) do
      graphql_name 'TestQuery'

      yield(self) if block_given?
    end
  end

  def execute_query(query_type)
    schema = Class.new(GraphQL::Schema) do
      use Gitlab::Graphql::Authorize
      query(query_type)
    end

    schema.execute(
      query_string,
      context: { current_user: user },
      variables: {}
    )
  end
end
