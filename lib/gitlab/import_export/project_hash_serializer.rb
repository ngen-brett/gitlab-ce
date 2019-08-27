# frozen_string_literal: true

module Gitlab
  module ImportExport
    class ProjectHashSerializer
      attr_reader :project, :tree

      def initialize(project, tree)
        @project = project
        @tree = tree
      end

      def execute
        # Let's serialize in batches :merge_requests only
        key = :merge_requests
        selection = extract_from_tree!(key)

        # data = @project.as_json(tree)
        data = {}
        data[key.to_s] = []

        records = project.send(key)

        records.in_batches(of: 100) do |batch|
          data[key.to_s] += batch.as_json(selection)
        end

        data
      end


      private

      def extract_from_tree!(attr)
        index = index_in_include_arr(attr)

        tree[:include].delete_at(index)[attr]
      end

      def index_in_include_arr(attr)
        tree[:include].find_index do |x|
          x.is_a?(Hash) && x.keys.first == attr
        end
      end

      # as_json implementation (current master)
      def execute_old
        @project.as_json(tree)
      end

      # Stan's implementation
      def execute_stan_ver
        preload_data = extract_preload_clause(tree)
        # Detach the top-level includes so only the project attributes
        # are serialized
        included_tree = tree.delete(:include)
        data = project.as_json(tree)

        # Now serialize each top-level association (e.g. issues, merge requests, etc.)
        # in batches.
        preload_data.each do |key, preload_clause|
          records = project.send(key)

          next unless records

          if records.is_a?(ActiveRecord::Base)
            data[key.to_s] = records
            next
          end

          data[key.to_s] = []
          selection = serialize_options(included_tree, key)

          # Not all models use EachBatch, whereas ActiveRecord guarantees all models can use in_batches.
          records.in_batches do |batch| # rubocop:disable Cop/InBatches
            batch = batch.preload(preload_clause) if preload_clause
            data[key.to_s] += batch.as_json(selection)
          end
        end

        data
      end

      # The `include` tree contains rows of entries that can contain a Hash or a symbol
      # sorted in any particular way:
      #
      # [{:labels=>...,
      #  {:milestones=>...,
      #  :releases,
      #  ...
      # ]
      #
      # This method does a linear search to find the matching association key.
      def serialize_options(included_tree, key)
        selected_include = included_tree.find { |row| row.is_a?(Hash) ? row.keys.first == key : nil }

        selected_include ? selected_include[key] : nil
      end

      def extract_preload_clause(options)
        clause = {}

        return unless options[:include]

        add_includes(options) do |association, opts|
          preload_clause = extract_preload_clause(opts)
          # XXX Hack
          preload_clause.delete(:notes) if association == :ci_pipelines
          preload_clause.merge!({ source_project: nil, target_project: nil }) if association == :merge_requests
          # XXX
          clause[association] = preload_clause
        end

        clause
      end

      # Taken from https://github.com/rails/rails/blob/v5.0.7/activemodel/lib/active_model/serialization.rb#L170
      # but repurposed here.
      #
      # Add associations specified via the <tt>:include</tt> option.
      #
      # Expects a block that takes as arguments:
      #   +association+ - name of the association
      #   +records+     - the association record(s) to be serialized
      #   +opts+        - options for the association records
      def add_includes(options = {})
        return unless includes = options[:include]

        unless includes.is_a?(Hash)
          includes = Hash[Array(includes).map { |n| n.is_a?(Hash) ? n.to_a.first : [n, {}] }]
        end

        includes.each do |association, opts|
          yield association, opts
        end
      end
    end
  end
end
