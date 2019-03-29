# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::PushOptions do
  describe 'namespace and key validation' do
    it 'ignores unrecognised namespaces' do
      options = described_class.new(['invalid.key=value'])

      expect(options.get(:invalid)).to eq(nil)
    end

    it 'ignores unrecognised keys' do
      options = described_class.new(['merge_request.key=value'])

      expect(options.get(:merge_request)).to eq(nil)
    end

    it 'ignores blank keys' do
      options = described_class.new(['merge_request'])

      expect(options.get(:merge_request)).to eq(nil)
    end

    it 'parses recognised namespace and key pairs' do
      options = described_class.new(['merge_request.target=value'])

      expect(options.get(:merge_request)).to eq({
        target: 'value'
      })
    end
  end

  describe '#get' do
    it 'can emulate Hash#dig' do
      options = described_class.new(['merge_request.target=value'])

      expect(options.get(:merge_request, :target)).to eq('value')
    end
  end

  describe '#to_h' do
    it 'returns all options as a Hash' do
      options = described_class.new([
        'merge_request.create',
        'merge_request.target=value'
      ])

      expect(options.to_h).to eq({
        merge_request: {
          create: true,
          target: 'value'
        }
      })
    end
  end

  it 'can parse multiple push options' do
    options = described_class.new([
      'merge_request.create',
      'merge_request.target=value'
    ])

    expect(options.get(:merge_request)).to eq({
      create: true,
      target: 'value'
    })
    expect(options.get(:merge_request, :create)).to eq(true)
    expect(options.get(:merge_request, :target)).to eq('value')
  end

  it 'selects the last option when options contain duplicate namespace and key pairs' do
    options = described_class.new([
      'merge_request.target=value1',
      'merge_request.target=value2'
    ])

    expect(options.get(:merge_request, :target)).to eq('value2')
  end

  it 'defaults values to true' do
    options = described_class.new(['merge_request.create'])

    expect(options.get(:merge_request, :create)).to eq(true)
  end

  it 'expands aliases' do
    options = described_class.new(['mr.target=value'])

    expect(options.get(:merge_request, :target)).to eq('value')
  end

  it 'forgives broken push options' do
    options = described_class.new(['merge_request . target = value'])

    expect(options.get(:merge_request, :target)).to eq('value')
  end
end
