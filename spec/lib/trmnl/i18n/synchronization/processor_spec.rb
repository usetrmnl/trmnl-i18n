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

    it "copies values from the source locale to the destination locales" do
      expect(repo.load("fr")).to eq({"fr" => {"hello" => "Bonjour", "world" => "World"}})
    end

    it "generates values for the raw locale" do
      expect(repo.load("raw")).to eq({"raw" => {"hello" => "hello", "world" => "world"}})
    end

    it "logs information" do
      repo.load "fr"
      expect(logger.reread).to match(/.+🟢.+Syncing/m)
    end
  end
end
