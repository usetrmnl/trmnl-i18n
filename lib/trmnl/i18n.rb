# frozen_string_literal: true

require_relative "i18n/railtie"

module TRMNL
  # Main namespace.
  module I18n
    def self.load_locales
      Pathname(__dir__).join("i18n", "locales")
                       .glob("**/*")
                       .select(&:file?)
                       .map(&:to_s)
                       .then { |paths| ::I18n.load_path.concat paths }
    end
  end
end
