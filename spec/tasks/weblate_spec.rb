# frozen_string_literal: true

require "spec_helper"
require "tasks/weblate"

RSpec.describe Weblate do
  describe ".component_settings" do
    it "answers a component whose template is the English file in its own directory" do
      expect(described_class.component_settings("web_ui")).to eq(
        "name" => "Web ui",
        "slug" => "web_ui",
        "file_format" => "ruby-yaml",
        "filemask" => "lib/trmnl/i18n/locales/web_ui/*.yml",
        "template" => "lib/trmnl/i18n/locales/web_ui/en.yml",
        "screenshot_filemask" => "screenshots/web_ui/*.png",
        "language_regex" => "^(?!raw$).+$",
        "repo" => "https://github.com/usetrmnl/trmnl-i18n.git",
        "branch" => "main",
        "vcs" => "github",
        "push" => "https://github.com/usetrmnl/trmnl-i18n.git",
        "push_branch" => "weblate-translations",
        "license" => "MIT"
      )
    end

    it "names a push branch so translations arrive as a pull request, not a fork" do
      settings = described_class.component_settings "web_ui"
      expect(settings["push_branch"]).to eq("weblate-translations")
    end
  end

  describe ".update_settings" do
    subject(:settings) { described_class.update_settings "web_ui" }

    it "omits the repository fields a linked component rejects" do
      expect(settings.keys).not_to include("slug", "repo", "branch", "vcs", "push", "push_branch")
    end

    it "keeps the file layout so a moved locale directory still lands" do
      expect(settings["filemask"]).to eq("lib/trmnl/i18n/locales/web_ui/*.yml")
    end
  end

  describe ".ensure_project" do
    let(:client) { instance_double Weblate::Client }

    context "when the project is absent" do
      before { allow(client).to receive(:get).and_return({"results" => []}) }

      it "creates it" do
        allow(client).to receive(:post)
        described_class.ensure_project client

        expect(client).to have_received(:post).with("projects/", described_class::PROJECT_SETTINGS)
      end
    end

    context "when the project already exists" do
      before { allow(client).to receive(:get).and_return({"results" => [{"slug" => "trmnl"}]}) }

      it "leaves it alone" do
        allow(client).to receive(:post)
        described_class.ensure_project client

        expect(client).not_to have_received(:post)
      end
    end
  end

  describe Weblate::Client do
    subject(:client) { described_class.new url: "https://translate.trmnl.com", token: "secret" }

    let(:components_url) { "https://translate.trmnl.com/api/projects/trmnl/components/" }

    describe "#get" do
      before do
        stub_request(:get, components_url).with(headers: {"Authorization" => "Token secret"})
                                          .to_return body: {results: [{slug: "web_ui"}]}.to_json
      end

      it "answers the parsed results" do
        expect(client.get("projects/trmnl/components/")["results"]).to eq([{"slug" => "web_ui"}])
      end
    end

    describe "#post" do
      let(:failure) { {slug: ["exists"]}.to_json }

      before { stub_request(:post, components_url).to_return status: 400, body: failure }

      it "raises with the body so a failure is diagnosable" do
        expectation = proc { client.post "projects/trmnl/components/", {} }
        expect(&expectation).to raise_error(described_class::Error, /exists/)
      end
    end

    describe "#patch" do
      let(:component_url) { "https://translate.trmnl.com/api/components/trmnl/web_ui/" }

      before do
        stub_request(:patch, component_url).with(
          body: {"branch" => "main"}.to_json,
          headers: {"Content-Type" => "application/json"}
        ).to_return status: 204, body: ""
      end

      it "answers an empty hash when the response carries no body" do
        expect(client.patch("components/trmnl/web_ui/", {"branch" => "main"})).to eq({})
      end
    end
  end
end
