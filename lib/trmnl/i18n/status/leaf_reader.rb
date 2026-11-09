# frozen_string_literal: true

require "psych"

module TRMNL
  module I18n
    module Status
      # Reads one locale file into dotted keys with their value and the line the key is on.
      class LeafReader
        # A value and the line its key is on.
        Leaf = Data.define :value, :line
        ABSENT = Leaf[value: nil, line: nil]

        def call path, locale
          return {} unless File.exist? path

          root = Psych.parse_file(path).root
          collect pairs(root).find(proc { [] }) { |key, _| key.value == locale }
                             .last
        end

        private

        def collect node, prefix = nil
          pairs(node).each_with_object({}) do |(key, value), leaves|
            leaves.merge! visit(value, [prefix, key.value].compact.join("."), key.start_line)
          end
        end

        def visit node, path, line
          case node
            when Psych::Nodes::Mapping then collect node, path
            when Psych::Nodes::Sequence
              node.children.each_with_index.reduce({}) do |leaves, (child, index)|
                leaves.merge visit(child, "#{path}.#{index}", child.start_line)
              end
            else {path => Leaf[value: node.value, line: line + 1]}
          end
        end

        # :reek:UtilityFunction
        def pairs(node) = node.is_a?(Psych::Nodes::Mapping) ? node.children.each_slice(2) : []
      end
    end
  end
end
