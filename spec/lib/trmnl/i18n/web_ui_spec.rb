# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Web UI", type: :feature do
  using Refinements::Hash
  using Refinements::Pathname

  let(:default) { YAML.safe_load(root.join("en.yml").read).fetch("en").flatten_keys.keys }
  let(:root) { Bundler.root.join "lib/trmnl/i18n/locales/web_ui" }

  Bundler.root.join("lib/trmnl/i18n/locales/web_ui").files("*.yml").each do |path|
    it "verifies #{path.name} has key parity with default locale" do
      locale = path.name.to_s.then { |key| key == "en.raw" ? "raw" : key }
      current = YAML.safe_load(path.read).fetch(locale).flatten_keys.keys

      expect((default - current)).to eq([])
    end
  end
end
