# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/status/kept"

RSpec.describe TRMNL::I18n::Status::Kept do
  subject(:kept) { described_class.new words:, root: SPEC_ROOT.join("fixtures/kept_keys") }

  let(:words) { TRMNL::I18n::Status::KeptWords.new path: SPEC_ROOT.join("fixtures/status/kept_words.yml") }

  describe "#cover?" do
    it "covers text made of kept words" do
      expect(kept.cover?("de", "brand", "Google")).to be(true)
    end

    it "covers a key the locale lists" do
      expect(kept.cover?("fr", "devices.edit.presentation", "Presentation")).to be(true)
    end

    it "covers every key under a listed wildcard" do
      expect(kept.cover?("fr", "stems.0", "Wood")).to be(true)
    end

    it "does not cover a key the locale does not list" do
      expect(kept.cover?("fr", "devices.edit.theme", "Theme")).to be(false)
    end

    it "does not cover a key for a locale with an empty list" do
      expect(kept.cover?("de", "devices.edit.presentation", "Presentation")).to be(false)
    end

    it "does not cover a key for a locale with no list" do
      expect(kept.cover?("it", "devices.edit.presentation", "Presentation")).to be(false)
    end
  end
end
