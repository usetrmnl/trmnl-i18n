# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/status/kept_words"

RSpec.describe TRMNL::I18n::Status::KeptWords do
  subject :kept_words do
    described_class.new path: SPEC_ROOT.join("fixtures/status/kept_words.yml")
  end

  describe "#cover?" do
    it "covers a word every locale keeps" do
      expect(kept_words.cover?("fr", "Google")).to be(true)
    end

    it "covers a word only its own locale keeps" do
      expect(kept_words.cover?("fr", "Metal")).to be(true)
    end

    it "does not cover another locale's word" do
      expect(kept_words.cover?("de", "Metal")).to be(false)
    end

    it "covers codes and placeholders" do
      expect(kept_words.cover?("de", "%{count} UV, %B 15")).to be(true) # rubocop:todo Style/FormatStringToken
    end

    it "does not cover a sentence that mentions a kept word" do
      expect(kept_words.cover?("fr", "Connect Google")).to be(false)
    end

    it "loads the shipped list by default" do
      expect(described_class.new.cover?("de", "TRMNL")).to be(true)
    end
  end
end
