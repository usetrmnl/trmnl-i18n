# frozen_string_literal: true

require "yaml"
require_relative "kept_words"

module TRMNL
  module I18n
    module Status
      # Answers whether a locale shows an English string on purpose: by its words, or by its key in
      # kept_keys/<locale>.yml.
      class Kept
        ROOT = Pathname(__dir__).join("kept_keys").freeze

        def initialize words: KeptWords.new, root: ROOT
          @words = words
          @root = Pathname root
          @keys = Hash.new { |all, locale| all[locale] = load locale }
        end

        def cover? locale, key, text
          words.cover?(locale, text) || keys[locale].any? { |pattern| File.fnmatch? pattern, key }
        end

        private

        attr_reader :words, :root, :keys

        def load locale
          path = root.join "#{locale}.yml"
          path.exist? ? YAML.load_file(path) || [] : []
        end
      end
    end
  end
end
