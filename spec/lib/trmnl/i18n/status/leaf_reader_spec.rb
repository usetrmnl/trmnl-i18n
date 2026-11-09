# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/status/leaf_reader"

RSpec.describe TRMNL::I18n::Status::LeafReader do
  subject(:reader) { described_class.new }

  let(:leaves) { reader.call SPEC_ROOT.join("fixtures/status/web_ui/fr.yml"), "fr" }

  describe "#call" do
    it "answers nested keys as dotted paths with their line" do
      expect(leaves["devices.edit.presentation"]).to eq(
        described_class::Leaf[value: "Presentation",
                              line: 5]
      )
    end

    it "answers each list item under its index" do
      expect(leaves["stems.1"]).to eq(described_class::Leaf[value: "Metal", line: 10])
    end

    it "answers empty values as they are" do
      expect(leaves["devices.edit.theme"].value).to eq("")
    end

    it "answers nothing for a locale the file does not hold" do
      expect(reader.call(SPEC_ROOT.join("fixtures/status/web_ui/fr.yml"), "de")).to eq({})
    end

    it "answers nothing for a missing file" do
      expect(reader.call(SPEC_ROOT.join("fixtures/status/web_ui/xx.yml"), "xx")).to eq({})
    end
  end
end
