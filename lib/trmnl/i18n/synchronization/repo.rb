# frozen_string_literal: true

require "refinements"
require "yaml"

module TRMNL
  module I18n
    module Synchronization
      # Represents a directory containing YAML files named "{locale}.yml"
      class Repo
        using Refinements::Pathname

        def self.all
          Pathname(__dir__).join("../locales")
                           .directories
                           .map { |directory| new directory }
        end

        def initialize directory
          @directory = Pathname directory
        end

        def name = directory.name.to_s

        def load(locale) = YAML.load_file locale_path(locale)

        def save(locale, data) = locale_path(locale).write data.to_yaml

        def locales = directory.files("*.yml").map { |path| path.name.to_s }

        private

        attr_reader :directory

        def locale_path(locale) = directory.join "#{locale}.yml"
      end
    end
  end
end
