# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/synchronization/untranslated_reducer"

RSpec.describe TRMNL::I18n::Synchronization::UntranslatedReducer do
  subject(:generator) { described_class }

  describe "#call" do
    it "answers nil for a simple value" do
      expect(generator.call("Hello")).to be(nil)
    end

    it "answers hash with emptied values" do
      result = generator.call({"key_1" => "value_1", "key_2" => "value_2"})
      expect(result).to eq("key_1" => nil, "key_2" => nil)
    end

    it "answers nested hash with emptied values" do
      result = generator.call({"key_1" => {"key_2" => "value_2"}})
      expect(result).to eq("key_1" => {"key_2" => nil})
    end

    it "answers nil for an array" do
      expect(generator.call(%w[value_1 value_2])).to be(nil)
    end

    it "answers nil for a value that is already nil" do
      expect(generator.call(nil)).to be(nil)
    end

    it "keeps every key of the original structure" do
      result = generator.call({"key_1" => {"key_2" => "value_2", "key_3" => %w[a b]}})
      expect(result["key_1"].keys).to eq(%w[key_2 key_3])
    end
  end
end
