# frozen_string_literal: true

require_relative "entry"
require_relative "kept"
require_relative "leaf_reader"

module TRMNL
  module I18n
    module Status
      # Pairs every English string with each locale's value, per area (web_ui, plugin_renders...).
      class Report
        ROOT = Pathname(__dir__).join("../locales").freeze
        ENGLISH_OR_DEBUG_LOCALE = /\A(en(-\w+)?|raw)\z/

        def initialize root: ROOT, reader: LeafReader.new, kept: Kept.new
          @root = Pathname root
          @reader = reader
          @kept = kept
        end

        # :reek:NestedIterators
        def call
          locales.to_h do |locale|
            [locale, areas.to_h { |area| [area.basename.to_s, entries(area, locale)] }]
          end
        end

        private

        attr_reader :root, :reader, :kept

        def areas = root.children.select(&:directory?).sort

        # :reek:NestedIterators
        def locales
          areas.flat_map { |area| area.glob("*.yml").map { |path| path.basename(".yml").to_s } }
               .uniq
               .grep_v(ENGLISH_OR_DEBUG_LOCALE)
               .sort
        end

        def entries area, locale
          values = reader.call area.join("#{locale}.yml"), locale

          english(area).map do |key, leaf|
            text = leaf.value
            current = values.fetch key, LeafReader::ABSENT
            Entry[key:,
                  english: text,
                  value: current.value,
                  line: current.line,
                  kept: kept.cover?(locale, key, text.to_s)]
          end
        end

        def english area
          reader.call(area.join("en.yml"), "en").reject { |_, leaf| leaf.value.to_s.strip.empty? }
        end
      end
    end
  end
end
