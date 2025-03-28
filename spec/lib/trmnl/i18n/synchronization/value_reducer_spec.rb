# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/synchronization/value_reducer"

RSpec.describe TRMNL::I18n::Synchronization::ValueReducer do
  subject(:generator) { described_class }

  describe "#call" do
    it "answers array of indexed positions when using default path" do
      result = generator.call %w[value_1 value_2]
      expect(result).to eq(%w[[0] [1]])
    end

    it "answers array with initial path" do
      result = generator.call %w[value_1 value_2], "parent.path"
      expect(result).to eq(%w[parent.path[0] parent.path[1]])
    end

    it "answers array with key/values including initial path plus indexed value" do
      result = generator.call [{"key_1" => "value_1"}, {"key_2" => "value_2"}], "parent.path"

      expect(result).to eq(
        [
          {"key_1" => "parent.path[0].key_1"},
          {"key_2" => "parent.path[1].key_2"}
        ]
      )
    end

    it "answers hash with original keys for simple key/value pairs" do
      result = generator.call({"key_1" => "value_1", "key_2" => "value_2"})
      expect(result).to eq("key_1" => "key_1", "key_2" => "key_2")
    end

    it "answers hash with flattened value for nested hash" do
      result = generator.call({"key_1" => {"key_2" => "value_2"}})
      expect(result).to eq("key_1" => {"key_2" => "key_1.key_2"})
    end

    it "answers hash with flattened value including original path" do
      result = generator.call({"key_1" => {"key_2" => "value_2"}}, "parent")
      expect(result).to eq("key_1" => {"key_2" => "parent.key_1.key_2"})
    end

    it "answers path for simple value" do
      expect(generator.call("test", "parent.path")).to eq("parent.path")
    end

    it "answers empty string nil and default value" do
      expect(generator.call(nil)).to eq("")
    end

    it "answers empty string for any value and default value" do
      expect(generator.call(13)).to eq("")
    end
  end
end
