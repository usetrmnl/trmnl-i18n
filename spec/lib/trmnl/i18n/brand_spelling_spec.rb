# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Brand spelling", type: :feature do
  using Refinements::Hash
  using Refinements::Pathname

  # Each brand, then the spellings to catch in any case. The exact brand spelling passes.
  let :brands do
    {
      "TRMNL" => %w[trmnl trml tmrnl termnl],
      "GitHub" => %w[github],
      "JavaScript" => %w[javascript],
      "Mazévo" => %w[mazevo mazévo],
      "ePaper" => %w[epaper e-paper e-ink eink],
      "Wi-Fi" => %w[wifi wi-fi]
    }
  end

  # Skips domains, hyphenated names and interpolations: trmnl.com, trmnl-booking, %{wifi}.
  let :patterns do
    brands.transform_values do |spellings|
      %r((?<![\w./@{-])(?:#{Regexp.union(spellings).source})(?![\w-]|\.\w))i
    end
  end

  Bundler.root.join("lib/trmnl/i18n/locales").files("**/*.yml").each do |path|
    it "spells brand names right in #{path.relative_path_from Bundler.root}" do
      misspellings = YAML.safe_load(path.read).flatten_keys.flat_map do |key, value|
        patterns.flat_map do |brand, pattern|
          value.to_s
               .scan(pattern)
               .reject { it == brand }
               .map { "#{key}: #{it} (write #{brand})" }
        end
      end

      expect(misspellings).to eq([])
    end
  end
end
