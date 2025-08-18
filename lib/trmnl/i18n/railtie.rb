# frozen_string_literal: true

require "rails/railtie"

module TRMNL
  module I18n
    # The Rails hook.
    class Railtie < Rails::Railtie
      initializer "trmnl-localizations.i18n" do
        TRMNL::I18n.load_locales
      end
    end
  end
end
