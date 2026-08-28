# frozen_string_literal: true

module TRMNL
  module I18n
    module Synchronization
      # Reduces a nested structure to the same shape with every value emptied.
      UntranslatedReducer = lambda do |initial_value|
        return unless initial_value.is_a? Hash

        initial_value.transform_values { |value| UntranslatedReducer.call value }
      end
    end
  end
end
