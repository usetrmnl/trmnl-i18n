# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Link markers", type: :feature do
  using Refinements::Hash

  # The app turns __text__ into a link. A translation may reword the linked text, but it needs the
  # same number of links English has, or a link disappears or a stray one appears.
  let(:pattern) { /__(?=\S)(.+?)(?<=\S)__/ }

  # Strings whose links already differed from English when this check arrived, by locale.
  # Drop a key once its string is fixed.
  # The developer perks hint still links an add-on that English no longer mentions.
  let :known do
    %w[da fr he hu id is ja nl no pt-BR ru sk sv].to_h do |locale|
      [locale, %w[devices.edit.developer_perks_hint]]
    end
  end

  def strings path
    locale = path.basename(".yml").to_s
    YAML.safe_load(path.read).fetch(locale).flatten_keys(delimiter: ".").stringify_keys
  end

  def links(text) = text.to_s.scan(pattern).size

  Bundler.root.join("lib/trmnl/i18n/locales").glob("*/*.yml").sort.each do |path|
    next if %w[en.yml raw.yml].include? path.basename.to_s

    it "verifies #{path.parent.basename}/#{path.basename} keeps the links English has" do
      english = strings path.parent.join("en.yml")
      contents = strings(path).except(*known.fetch(path.basename(".yml").to_s, []))

      changed = contents.filter_map do |key, value|
        # A plural form English lacks (few, many) answers to "other". Untranslated strings pass.
        source = english.fetch(key) { english[key.sub(/\w+\z/, "other")] }

        next if value == source || value.to_s.strip.empty? || links(source) == links(value)

        "#{key}: English has #{links source} link(s), this locale has #{links value}"
      end

      expect(changed).to eq([])
    end
  end
end
