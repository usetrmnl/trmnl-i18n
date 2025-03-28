# frozen_string_literal: true

module TRMNL
  module I18n
    module Synchronization
      # Reduces a nested structure into key/value pairs with flattened values.
      ValueReducer = lambda do |initial_value, path = ""|
        case initial_value
          when Array
            initial_value.map.with_index do |item, index|
              ValueReducer.call item, "#{path}[#{index}]"
            end
          when Hash
            initial_value.each.with_object({}) do |(key, value), result|
              next_path = path.empty? ? key : "#{path}.#{key}"
              result[key] = ValueReducer.call value, next_path
            end
          else path
        end
      end
    end
  end
end
