# frozen_string_literal: true

require "spec_helper"

RSpec.describe TRMNL::I18n::Railtie do
  using Refinements::Pathname

  before { described_class.initializers.each(&:run) }

  describe ".initializer" do
    it "loads locales" do
      expect(I18n.load_path).to include(
        %r(.+locales/custom_plugins.+),
        %r(.+locales/plugin_renders.+),
        %r(.+locales/web_ui.+)
      )
    end

    it "answers available locales" do
      proof = Bundler.root
                     .join("lib/trmnl/i18n/locales/web_ui")
                     .files("*.yml")
                     .map { |path| path.name.to_s.to_sym }
                     .sort

      expect(I18n.available_locales.sort).to eq(proof)
    end
  end
end
