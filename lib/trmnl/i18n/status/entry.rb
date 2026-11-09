# frozen_string_literal: true

module TRMNL
  module I18n
    module Status
      # One English string and what a locale has for it.
      Entry = Data.define :key, :english, :value, :line, :kept do
        def section = key.include?(".") ? key.split(".").first : "general"

        def missing? = value.to_s.strip.empty?

        def translated? = !missing? && (value != english || kept)
      end
    end
  end
end
