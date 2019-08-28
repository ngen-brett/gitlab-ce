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
        serializable_hash(project, tree)
      end

      # Took from Rails:
      # https://github.com/rails/rails/blob/5-2-stable/activemodel/lib/active_model/serialization.rb
      def serializable_hash(obj, options = nil)
        options ||= {}

        attribute_names = obj.attributes.keys
        if only = options[:only]
          attribute_names &= Array(only).map(&:to_s)
        elsif except = options[:except]
          attribute_names -= Array(except).map(&:to_s)
        end

        hash = {}
        attribute_names.each { |n| hash[n] = obj.send(n) }
        Array(options[:methods]).each { |m| hash[m.to_s] = obj.send(m) }

        serializable_add_includes(obj, options) do |association, records, opts|
          # ActiveRecord::StatementInvalid: PG::SyntaxError: ERROR:  zero-length delimited identifier at or near """"
          # LINE 1: ...gnees"."issue_id" = $1 ORDER BY "issue_assignees"."" ASC LIM...
          # in_batches doesn't work if the model doesn't have primary key
          hash[association.to_s] = if records.respond_to?(:to_ary) && records.model.primary_key.present?
            # p "*" * 50
            # p records.class
            # p records.first
            # p "*" * 50

            [].tap do |res|
              records.in_batches do |batch|
                res << batch.map { |el| serializable_hash(el, opts) }
              end
            end
          elsif records.respond_to?(:to_ary)
            records.to_ary.map { |a| serializable_hash(a, opts) }
          else
            serializable_hash(records, opts)
          end
        end

        p hash
        hash
      end

      # Add associations specified via the <tt>:include</tt> option.
      #
      # Expects a block that takes as arguments:
      #   +association+ - name of the association
      #   +records+     - the association record(s) to be serialized
      #   +opts+        - options for the association records
      def serializable_add_includes(obj, options = {}) #:nodoc:
        return unless includes = options[:include]

        unless includes.is_a?(Hash)
          includes = Hash[Array(includes).map { |n| n.is_a?(Hash) ? n.to_a.first : [n, {}] }]
        end

        includes.each do |association, opts|
          if records = obj.send(association)
            yield association, records, opts
          end
        end
      end

      private

      def execute_only_mrs
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
