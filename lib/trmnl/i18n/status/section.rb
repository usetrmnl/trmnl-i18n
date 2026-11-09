# frozen_string_literal: true

require_relative "progress"

module TRMNL
  module I18n
    module Status
      # The strings under one top level key of one area, such as web_ui's "devices".
      Section = Data.define :area, :name, :entries do
        # :reek:NestedIterators
        def self.all areas
          areas.flat_map do |area, entries|
            entries.group_by(&:section).map { |name, grouped| new area:, name:, entries: grouped }
          end
        end

        def progress = Progress.for(entries)

        def left = entries.reject(&:translated?)

        def path = "#{area}/#{name}.md"
      end
    end
  end
end
