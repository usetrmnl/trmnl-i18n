# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/status/progress"

RSpec.describe TRMNL::I18n::Status::Progress do
  subject(:progress) { described_class[done: 2, total: 3] }

  describe ".for" do
    it "counts translated entries" do
      entries = [
        instance_double(TRMNL::I18n::Status::Entry, translated?: true),
        instance_double(TRMNL::I18n::Status::Entry, translated?: false)
      ]

      expect(described_class.for(entries)).to eq(described_class[done: 1, total: 2])
    end
  end

  describe "#left" do
    it "answers what is still to translate" do
      expect(progress.left).to eq(1)
    end
  end

  describe "#label" do
    it "answers the percent with one decimal" do
      expect(progress.label).to eq("66.7%")
    end

    it "answers 100% when there is nothing to translate" do
      expect(described_class[done: 0, total: 0].label).to eq("100.0%")
    end
  end

  describe "#bar" do
    it "fills one block per ten percent" do
      expect(progress.bar).to eq("██████░░░░")
    end
  end
end
