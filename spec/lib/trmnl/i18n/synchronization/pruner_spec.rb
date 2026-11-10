# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/synchronization/pruner"

RSpec.describe TRMNL::I18n::Synchronization::Pruner do
  subject(:pruner) { described_class.new }

  let :source do
    {
      "hello" => "Hello",
      "greetings" => {"morning" => "Morning"},
      "items" => {"one" => "1 item", "other" => "Many items"}
    }
  end

  describe "#call" do
    it "keeps keys the source has" do
      destination = {"hello" => "Bonjour", "greetings" => {"morning" => "Matin"}}
      expect(pruner.call(destination, source)).to eq(destination)
    end

    it "drops a key the source no longer has" do
      destination = {"hello" => "Bonjour", "gone" => "Parti"}
      expect(pruner.call(destination, source)).to eq("hello" => "Bonjour")
    end

    it "drops a nested key the source no longer has" do
      destination = {"greetings" => {"morning" => "Matin", "night" => "Nuit"}}
      expect(pruner.call(destination, source)).to eq("greetings" => {"morning" => "Matin"})
    end

    it "keeps extra plural forms of a source plural" do
      destination = {"items" => {"one" => "1", "few" => "2-4", "many" => "5+", "other" => "n"}}
      expect(pruner.call(destination, source)).to eq(destination)
    end

    it "drops plural forms of a key the source no longer has" do
      expect(pruner.call({"gone" => {"two" => "2", "few" => "3"}}, source)).to eq({})
    end

    it "keeps date names the source takes from Rails" do
      destination = {"date" => {"day_names" => %w[søndag mandag]}}
      expect(pruner.call(destination, source)).to eq(destination)
    end

    it "keeps date names when the source has date formats of its own" do
      destination = {"date" => {"formats" => {"short" => "day"}, "day_names" => %w[søndag]}}
      english = source.merge "date" => {"formats" => {"short" => "day"}}

      expect(pruner.call(destination, english)).to eq(destination)
    end
  end
end
