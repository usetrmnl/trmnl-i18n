# frozen_string_literal: true

module TRMNL
  module I18n
    module Status
      # How many of a group of entries a locale has translated.
      Progress = Data.define :done, :total do
        def self.for(entries) = new(done: entries.count(&:translated?), total: entries.size)

        def left = total - done

        def percent = total.zero? ? 100.0 : (done * 100.0 / total)

        def label = format("%.1f%%", percent)

        def bar = ("█" * (percent / 10).floor).ljust 10, "░"
      end
    end
  end
end
