# frozen_string_literal: true

require "spec_helper"

# Guards the committed locale files rather than any one class: they are what the gem ships, and
# core renders whatever is here. bin/sync produces files that satisfy all of this.
RSpec.describe "Locales", type: :feature do
  using Refinements::Hash
  using Refinements::Pathname

  def flatten(path) = YAML.safe_load(path.read).fetch(path.name.to_s).flatten_keys

  Bundler.root.join("lib/trmnl/i18n/locales").directories.each do |component|
    context component.name.to_s do
      let(:english) { flatten component.join("en.yml") }
      let(:locales) { component.files "*.yml" }

      it "answers every English key in every locale" do
        missing = locales.to_h { |path| [path.name.to_s, english.keys - flatten(path).keys] }
                         .reject { |_, keys| keys.empty? }

        expect(missing).to eq({})
      end

      it "answers a value for every key, so nothing renders as nothing" do
        empty = locales.to_h do |path|
          blanks = flatten(path).select { |_, value| value.nil? || value.to_s.strip.empty? }
          [path.name.to_s, blanks.keys]
        end

        expect(empty.reject { |_, keys| keys.empty? }).to eq({})
      end
    end
  end

  it "answers a distinct name for each web UI locale, since the picker lists them" do
    web_ui = Bundler.root.join "lib/trmnl/i18n/locales/web_ui"
    names = web_ui.files("*.yml").map do |path|
      YAML.safe_load(path.read).fetch(path.name.to_s)["locale_name"]
    end

    expect(names.tally.select { |_, count| count > 1 }).to eq({})
  end
end
