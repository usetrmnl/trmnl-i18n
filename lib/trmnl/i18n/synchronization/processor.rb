# frozen_string_literal: true

require "cogger"
require "refinements"
require "yaml"

require_relative "untranslated_reducer"
require_relative "value_reducer"

module TRMNL
  module I18n
    module Synchronization
      # Copies new key/value pairs from the source locale (typically 'en') to destination locales.
      class Processor
        using Refinements::Hash

        def initialize repository, reducer: ValueReducer, logger: Cogger.new(id: "trmnl-i18n")
          @repository = repository
          @reducer = reducer
          @logger = logger
        end

        def call source_locale = "en"
          repository.locales.each do |destination_locale|
            log_info "Syncing #{repository.name}/#{destination_locale}..."

            destination_root = repository.load destination_locale
            result = add_missing_contents source_locale, destination_locale, destination_root

            repository.save destination_locale, result
          end
        end

        private

        attr_reader :repository, :reducer, :logger

        def log_info(message) = logger.info { message }

        # :reek:FeatureEnvy
        def add_missing_contents source_locale, destination_locale, destination_root
          destination_contents = destination_root[destination_locale]
          contents_to_merge = reduce source_locale, destination_locale
          destination_root[destination_locale] = contents_to_merge.deep_merge destination_contents
          destination_root
        end

        # A new key arrives empty rather than as English, so an untranslated string is not
        # mistaken for a finished one by anything reading these files.
        # :reek:ControlParameter
        def reduce source_locale, destination_locale
          repository.load(source_locale)[source_locale].then do |contents|
            case destination_locale
              when "raw" then reducer.call contents
              when source_locale then contents
              else UntranslatedReducer.call contents
            end
          end
        end
      end
    end
  end
end
