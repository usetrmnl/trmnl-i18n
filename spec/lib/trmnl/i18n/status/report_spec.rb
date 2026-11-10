# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/status/report"

RSpec.describe TRMNL::I18n::Status::Report do
  subject :report do
    described_class.new(root: SPEC_ROOT.join("fixtures/status"), kept:).call
  end

  let(:kept_words) { TRMNL::I18n::Status::KeptWords.new path: SPEC_ROOT.join("fixtures/status/kept_words.yml") }
  let(:kept) { TRMNL::I18n::Status::Kept.new words: kept_words, root: SPEC_ROOT.join("fixtures/kept_keys") }
  let(:web_ui) { report.dig("fr", "web_ui").to_h { |entry| [entry.key, entry] } }

  describe "#call" do
    it "leaves out regional locales and the debug locale" do
      expect(report.keys).to eq(%w[fr])
    end

    it "answers every area" do
      expect(report["fr"].keys).to eq(%w[plugin_renders web_ui])
    end

    it "leaves out keys English has no text for" do
      expect(web_ui).not_to have_key("blank")
    end

    it "pairs the English text with the locale's value and line" do
      expect(web_ui["devices.edit.presentation"]).to have_attributes(
        english: "Presentation",
        value: "Presentation",
        line: 5
      )
    end

    it "marks words the locale keeps" do
      expect(web_ui.values_at("brand", "stems.1").map(&:kept)).to eq([true, true])
    end

    it "marks keys the locale keeps" do
      expect(web_ui["devices.edit.presentation"].kept).to be(true)
    end

    it "counts English copies and empty values as untranslated" do
      expect(web_ui.values.reject(&:translated?).map(&:key)).to eq(%w[devices.edit.theme])
    end

    it "reads the shipped locales by default" do
      expect(described_class.new.call).to include("pl")
    end
  end
end
