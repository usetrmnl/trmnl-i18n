# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/synchronization/repo"

RSpec.describe TRMNL::I18n::Synchronization::Repo do
  subject(:repo) { described_class.new repo_directory }

  let(:fixtures_directory) { SPEC_ROOT.join "fixtures" }
  let(:repo_directory) { fixtures_directory.join "repo" }

  describe ".all" do
    it "returns an array of Repo instances" do
      repos = described_class.all
      expect(repos).to all(be_a(described_class))
    end

    it "returns a Repo instance for every locale in the directory" do
      repos = described_class.all
      expect(repos.map(&:name)).to eq(%w[custom_plugins plugin_renders web_ui])
    end
  end

  describe "#name" do
    it "returns the name of the repo" do
      expect(repo.name).to eq("repo")
    end
  end

  describe "#locales" do
    it "returns every locale in the repo" do
      expect(repo.locales).to eq(%w[en fr raw])
    end
  end

  describe "#load" do
    it "returns a hash for the specified locale" do
      result = repo.load "en"
      expect(result).to eq("en" => {"hello" => "Hello", "world" => "World"})
    end
  end

  describe "#save" do
    include_context "with temporary directory"

    let(:repo) { described_class.new temp_dir }

    before { FileUtils.cp_r repo_directory, temp_dir }

    it "saves the changes to the locale" do
      repo.save "fr", "fr" => {"hello" => "Bonjour", "world" => "Monde"}
      result = repo.load "fr"
      expect(result).to eq("fr" => {"hello" => "Bonjour", "world" => "Monde"})
    end
  end
end
