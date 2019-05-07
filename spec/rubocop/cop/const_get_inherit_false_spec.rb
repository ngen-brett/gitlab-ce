require 'spec_helper'
require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../../../rubocop/cop/const_get_inherit_false'

describe RuboCop::Cop::ConstGetInheritFalse do
  include CopHelper

  subject(:cop) { described_class.new }

  context 'Object.const_get' do
    it 'registers an offense with no 2nd argument' do
      expect_offense(<<~PATTERN.strip_indent)
        Object.const_get(:CONSTANT)
               ^^^^^^^^^ Use inherit=false when using const_get.
      PATTERN
    end

    it 'does not register an offense if inherit is false' do
      expect_no_offenses(<<~PATTERN.strip_indent)
        Object.const_get(:CONSTANT, false)
      PATTERN
    end

    it 'registers an offense if inherit is true' do
      expect_offense(<<~PATTERN.strip_indent)
        Object.const_get(:CONSTANT, true)
               ^^^^^^^^^ Use inherit=false when using const_get.
      PATTERN
    end
  end

  context 'const_get for a nested class' do
    it 'registers an offense on reload usage' do
      expect_offense(<<~PATTERN.strip_indent)
        Nested::Blog.const_get(:CONSTANT)
                     ^^^^^^^^^ Use inherit=false when using const_get.
      PATTERN
    end

    it 'does not register an offense if inherit is false' do
      expect_no_offenses(<<~PATTERN.strip_indent)
        Nested::Blog.const_get(:CONSTANT, false)
      PATTERN
    end

    it 'registers an offense if inherit is true' do
      expect_offense(<<~PATTERN.strip_indent)
        Nested::Blog.const_get(:CONSTANT, true)
                     ^^^^^^^^^ Use inherit=false when using const_get.
      PATTERN
    end
  end
end
