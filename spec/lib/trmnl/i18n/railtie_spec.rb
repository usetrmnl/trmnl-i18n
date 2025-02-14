# frozen_string_literal: true

require "spec_helper"

RSpec.describe TRMNL::I18n::Railtie do
  before { described_class.initializers.each(&:run) }

  describe ".initializer" do
    it "loads custom locales" do
      expect(I18n.load_path).to include(
        %r(.+locales/custom_plugins.+),
        %r(.+locales/plugin_renders.+),
        %r(.+locales/web_ui.+)
      )
    end
  end
end
