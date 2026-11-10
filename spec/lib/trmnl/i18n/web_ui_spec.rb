# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Web UI", type: :feature do
  using Refinements::Hash
  using Refinements::Pathname

  let(:default) { YAML.safe_load(root.join("en.yml").read).fetch("en").flatten_keys.keys }
  let(:root) { Bundler.root.join "lib/trmnl/i18n/locales/web_ui" }
  let(:locales) { root.files "*.yml" }

  Bundler.root.join("lib/trmnl/i18n/locales/web_ui").files("*.yml").each do |path|
    it "verifies #{path.name} has the keys English has, or only those when regional" do
      locale = path.name.to_s
      current = YAML.safe_load(path.read).fetch(locale).flatten_keys.keys
      regional = path.parent.join("#{locale[/\A(\w+)-/, 1]}.yml").exist?

      expect(regional ? current - default : default - current).to eq([])
    end
  end

  it "verifies locales have unique locale_name" do
    locale_names = locales.map do |path|
      YAML.safe_load(path.read).fetch(path.name.to_s)["locale_name"]
    end
    expect(locale_names.uniq.count).to eql locales.count
  end
end
