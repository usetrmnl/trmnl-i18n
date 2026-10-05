# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/synchronization/processor"
require "trmnl/i18n/synchronization/repo"

RSpec.describe TRMNL::I18n::Synchronization::Processor do
  subject(:processor) { described_class.new repo, logger: }

  let(:repo) { TRMNL::I18n::Synchronization::Repo.new temp_dir }
  let(:logger) { Cogger.new io: StringIO.new }

  include_context "with temporary directory"

  describe "#call" do
    let(:fixture_directory) { SPEC_ROOT.join "fixtures/repo" }

    before do
      FileUtils.cp_r "#{fixture_directory}/.", temp_dir
      processor.call
    end

    it "adds keys the destination locale is missing, defaulted to English" do
      expect(repo.load("fr")).to eq(
        {
          "fr" => {
            "hello" => "Bonjour",
            "world" => "World",
            "stems" => %w[Bois Bois],
            "greetings" => {"morning" => "Bonjour", "evening" => "Good evening"}
          }
        }
      )
    end

    it "keeps an existing translation rather than overwriting it with English" do
      expect(repo.load("fr").fetch("fr").fetch("hello")).to eq("Bonjour")
    end

    it "adds a missing nested key and keeps its translated sibling" do
      expect(repo.load("fr").dig("fr", "greetings")).to eq(
        "morning" => "Bonjour",
        "evening" => "Good evening"
      )
    end

    it "keeps a translated list as it is, as callers read it by index" do
      expect(repo.load("fr").fetch("fr").fetch("stems")).to eq(%w[Bois Bois])
    end

    it "leaves the source locale alone" do
      expect(repo.load("en")).to eq(
        {
          "en" => {
            "hello" => "Hello",
            "world" => "World",
            "stems" => %w[Wood Wood],
            "greetings" => {"morning" => "Good morning", "evening" => "Good evening"}
          }
        }
      )
    end

    it "generates values for the raw locale" do
      expect(repo.load("raw")).to eq(
        {
          "raw" => {
            "hello" => "hello",
            "world" => "world",
            "stems" => %w[stems[0] stems[1]],
            "greetings" => {"morning" => "greetings.morning", "evening" => "greetings.evening"}
          }
        }
      )
    end

    it "logs information" do
      repo.load "fr"
      expect(logger.reread).to match(/.+🟢.+Syncing/m)
    end
  end
end
