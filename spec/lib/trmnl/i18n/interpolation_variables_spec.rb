# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Interpolation variables", type: :feature do
  using Refinements::Hash

  # Rails variables, %{name}, and MessageFormat ones, {$name}. A translation may reorder or repeat
  # them, but not drop, add or rename one.
  let(:pattern) { /%\{\w+\}|(?<=\{)\$\w+/ }

  # A plural form for one number may spell it out or leave it out: "1 day", "%{count} day".
  let(:numbered) { /\.(zero|one|two)\z/ }
  let(:count) { /\A%\{count\}\z/ }

  # Strings whose variables already differed from English when this check arrived, by locale.
  # Drop a key once its string is fixed.
  let :known do
    {
      "gu" => %w[custom_plugins.simple_calendar.chinese_korean.leap_format_short],
      "hi" => %w[custom_plugins.simple_calendar.chinese_korean.leap_format_short],
      "ja" => %w[plugin_settings.form.linked_account_success],
      "zh-CN" => %w[
        custom_plugins.simple_calendar.chinese_korean.leap_format_short
        custom_plugins.simple_calendar.chinese_korean.ym_format
      ],
      "zh-HK" => %w[
        custom_plugins.simple_calendar.chinese_korean.leap_format_short
        custom_plugins.simple_calendar.chinese_korean.ym_format
      ]
    }
  end

  def strings path
    locale = path.basename(".yml").to_s
    YAML.safe_load(path.read).fetch(locale).flatten_keys(delimiter: ".").stringify_keys
  end

  def variables key, text
    names = text.to_s.scan(pattern).uniq.sort
    key.match?(numbered) ? names.grep_v(count) : names
  end

  Bundler.root.join("lib/trmnl/i18n/locales").glob("*/*.yml").sort.each do |path|
    next if %w[en.yml raw.yml].include? path.basename.to_s

    it "verifies #{path.parent.basename}/#{path.basename} keeps the variables English has" do
      english = strings path.parent.join("en.yml")
      contents = strings(path).except(*known.fetch(path.basename(".yml").to_s, []))

      changed = contents.filter_map do |key, value|
        # A plural form English lacks (few, many) answers to "other". Untranslated strings pass.
        source = english.fetch(key) { english[key.sub(/\w+\z/, "other")] }
        expected = variables key, source
        actual = variables key, value

        next if value == source || value.to_s.strip.empty? || expected == actual

        "#{key}: English has [#{expected.join ", "}], this locale has [#{actual.join ", "}]"
      end

      expect(changed).to eq([])
    end
  end
end
