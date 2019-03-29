# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::PushOptions do
  it 'ignores unrecognised namespaces' do
    options = described_class.new(['invalid.key=value'])

    expect(options.get(:invalid)).to eq(nil)
  end

  it 'can parse multiple push options' do
    options = described_class.new([
      'merge_request.key1=value1',
      'merge_request.key2=value2'
    ])

    expect(options.get(:merge_request)).to eq({
      key1: 'value1',
      key2: 'value2'
    })
    expect(options.get(:merge_request, :key1)).to eq('value1')
    expect(options.get(:merge_request, :key2)).to eq('value2')
  end

  it 'defaults values to true' do
    options = described_class.new(['merge_request.create'])

    expect(options.get(:merge_request, :create)).to eq(true)
  end

  it 'expands aliases' do
    options = described_class.new(['mr.key=value'])

    expect(options.get(:merge_request, :key)).to eq('value')
  end

  it 'forgives broken push options' do
    options = described_class.new(['merge_request . key = value'])

    expect(options.get(:merge_request, :key)).to eq('value')
  end
end
