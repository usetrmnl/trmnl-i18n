# frozen_string_literal: true

module TRMNL
  module I18n
    module Synchronization
      # Drops keys the source locale no longer has. Keeps a locale's extra plural forms and the date
      # names English takes from Rails.
      class Pruner
        PLURAL_FORMS = %w[zero one two few many other].freeze
        RAILS_DATA = %w[date].freeze

        def call destination, source
          destination.each_with_object({}) do |(key, value), kept|
            kept[key] = prune key, value, source[key] if keep? key, source
          end
        end

        private

        def prune key, value, english
          return value if RAILS_DATA.include?(key) || !(value.is_a?(Hash) && english.is_a?(Hash))

          call value, english
        end

        # :reek:UtilityFunction
        def keep? key, source
          source.key?(key) || RAILS_DATA.include?(key) ||
            (PLURAL_FORMS.include?(key) && source.key?("other"))
        end
      end
    end
  end
end
