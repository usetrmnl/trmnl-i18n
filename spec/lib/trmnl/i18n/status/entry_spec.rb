# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/status/entry"

RSpec.describe TRMNL::I18n::Status::Entry do
  subject :entry do
    described_class[key: "devices.edit.theme", english: "Theme", value:, line: 3, kept:]
  end

  let(:value) { "Motyw" }
  let(:kept) { false }

  describe "#section" do
    it "answers the first part of the key" do
      expect(entry.section).to eq("devices")
    end

    it "answers general for a top level key" do
      expect(entry.with(key: "about").section).to eq("general")
    end
  end

  describe "#translated?" do
    it "answers true when the value differs from English" do
      expect(entry.translated?).to be(true)
    end

    context "with an English copy" do
      let(:value) { "Theme" }

      it "answers false" do
        expect(entry.translated?).to be(false)
      end

      it "answers true when the locale keeps the words" do
        expect(entry.with(kept: true).translated?).to be(true)
      end
    end

    [nil, "", "  "].each do |blank|
      context "with #{blank.inspect}" do
        let(:value) { blank }
        let(:kept) { true }

        it "answers false" do
          expect(entry.translated?).to be(false)
        end
      end
    end
  end
end
