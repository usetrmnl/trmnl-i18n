# frozen_string_literal: true

require "yaml"

module TRMNL
  module I18n
    module Status
      # Answers whether a locale may show an English string as is: product names, units and codes.
      class KeptWords
        PATH = Pathname(__dir__).join("kept_words.yml").freeze
        PLACEHOLDER = /%\{\w+\}|%[A-Za-z]/
        WORD = /[\p{L}\p{M}\p{No}]+/
        PROSE = /\p{Lower}{2}/

        def initialize path: PATH
          @words = YAML.load_file path
        end

        def cover? locale, text
          allowed = words.fetch("all", []) + words.fetch(locale, [])
          text.gsub(PLACEHOLDER, "").scan(WORD).all? do |word|
            allowed.include?(word) || !word.match?(PROSE)
          end
        end

        private

        attr_reader :words
      end
    end
  end
end
