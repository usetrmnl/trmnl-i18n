# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/synchronization/pruner"

RSpec.describe "Orphan keys", type: :feature do
  using Refinements::Hash

  Bundler.root.join("lib/trmnl/i18n/locales").glob("*/*.yml").sort.each do |path|
    next if path.basename.to_s == "en.yml"

    it "verifies #{path.parent.basename}/#{path.basename} has no key English lacks" do
      locale = path.basename(".yml").to_s
      english = YAML.safe_load(path.parent.join("en.yml").read).fetch "en"
      contents = YAML.safe_load(path.read).fetch locale
      pruned = TRMNL::I18n::Synchronization::Pruner.new.call contents, english

      expect(contents.flatten_keys.keys - pruned.flatten_keys.keys).to eq([])
    end
  end
end
