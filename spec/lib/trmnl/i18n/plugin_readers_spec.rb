# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Plugin Renders", type: :feature do
  using Refinements::Hash
  using Refinements::Pathname

  let(:default) { YAML.safe_load(root.join("en.yml").read).fetch("en").flatten_keys.keys }
  let(:root) { Bundler.root.join "lib/trmnl/i18n/locales/plugin_renders" }

  Bundler.root.join("lib/trmnl/i18n/locales/plugin_renders").files("*.yml").each do |path|
    it "verifies #{path.name} has key parity with default locale" do
      current = YAML.safe_load(path.read).fetch(path.name.to_s).flatten_keys.keys
      expect((default - current)).to eq([])
    end
  end
end
