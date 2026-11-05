# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Locale files", type: :feature do
  using Refinements::Pathname

  Bundler.root.join("lib/trmnl/i18n/locales").glob("*/*.yml").each do |path|
    it "verifies #{path.parent.basename}/#{path.basename} root key is its file name" do
      roots = YAML.safe_load(path.read).keys

      expect(roots).to eq([path.name.to_s]),
                       "expected root key #{path.name.to_s.inspect}, got #{roots.inspect}. " \
                       "Quote it: YAML reads an unquoted no, yes, on or off as a boolean."
    end
  end
end
