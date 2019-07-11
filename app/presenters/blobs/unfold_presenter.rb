# frozen_string_literal: true

require 'gt_one_coercion'

module Blobs
  class UnfoldPresenter < BlobPresenter
    include Virtus.model
    include Gitlab::Utils::StrongMemoize

    attribute :full, Boolean, default: false
    attribute :since, GtOneCoercion
    attribute :to, GtOneCoercion
    attribute :bottom, Boolean
    attribute :unfold, Boolean, default: true
    attribute :offset, Integer
    attribute :indent, Integer, default: 0

    def initialize(blob, params)
      @subject = blob
      @raw_diff_lines = Gitlab::Diff::Parser.new.parse(blob.data.lines).to_a
      @highlighted_lines = highlight.lines
      super(params)

      if full?
        self.attributes = { since: 1, to: @raw_diff_lines.size, bottom: false, unfold: false, offset: 0, indent: 0 }
      end
    end

    # Converts a String array to Gitlab::Diff::Line array, with match line added
    def diff_lines
      diff_lines = limited_raw_diff_lines.map.with_index do |line, index|
        line.rich_text = lines[index]
        line
      end

      add_match_line(diff_lines)

      diff_lines
    end

    def lines
      strong_memoize(:lines) { limit(@highlighted_lines).map(&:html_safe) }
    end

    def match_line_text
      return '' if bottom?

      lines_length = limited_raw_diff_lines.length - 1
      line = [since, lines_length].join(',')
      "@@ -#{line}+#{line} @@"
    end

    private

    def add_match_line(diff_lines)
      return unless unfold?

      if bottom? && to < @raw_diff_lines.size
        old_pos = to - offset
        new_pos = to
      elsif since != 1
        old_pos = new_pos = since
      end

      # Match line is not needed when it reaches the top limit or bottom limit of the file.
      return unless new_pos

      match_line = Gitlab::Diff::Line.new(match_line_text, 'match', nil, old_pos, new_pos)

      bottom? ? diff_lines.push(match_line) : diff_lines.unshift(match_line)
    end

    def limited_raw_diff_lines
      strong_memoize(:limited_raw_diff_lines) { limit(@raw_diff_lines) }
    end

    def limit(lines)
      return lines if full?

      lines[since - 1..to - 1]
    end
  end
end
