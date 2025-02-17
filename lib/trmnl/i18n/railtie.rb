# frozen_string_literal: true

require "rails/railtie"

module TRMNL
  module I18n
    # The Rails hook.
    class Railtie < Rails::Railtie
      initializer "trmnl-localizations.i18n" do
        Pathname(__dir__).join("locales")
                         .glob("**/*")
                         .select(&:file?)
                         .map(&:to_s)
                         .then { |paths| ::I18n.load_path.concat paths }
      end
    end
  end
end
