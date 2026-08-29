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

  describe ".key_prefix_for" do
    it "derives the key prefix from the screenshot filename" do
      expect(described_class.key_prefix_for("screenshots/plugin_renders/weather.png"))
        .to eq("renders->weather->")
    end

    it "answers nil for a path that names no component" do
      expect(described_class.key_prefix_for("weather.png")).to be(nil)
    end
  end

  describe ".source_units" do
    subject(:units) { described_class.source_units client, "plugin_renders" }

    let(:client) { instance_double Weblate::Client }
    let :first do
      {
        "next" => "page2",
        "results" => [
          {"id" => 1, "translation" => "https://x/api/translations/trmnl/plugin_renders/en/"},
          {"id" => 2, "translation" => "https://x/api/translations/trmnl/plugin_renders/de/"}
        ]
      }
    end
    let :second do
      {
        "next" => nil,
        "results" => [{"id" => 3, "translation" => "https://x/api/translations/trmnl/plugin_renders/en/"}]
      }
    end

    before { allow(client).to receive(:get).and_return(first, second) }

    it "follows every page" do
      expect(units.map { it["id"] }).to eq([1, 3])
    end

    it "keeps only the English source units" do
      expect(units.map { it["translation"] }).to all(end_with("/en/"))
    end
  end

  describe ".link_screenshots" do
    subject(:outcomes) { described_class.link_screenshots client, "plugin_renders" }

    let(:client) { instance_double Weblate::Client, post: {} }
    let :listing do
      {
        "next" => nil,
        "results" => [
          {
            "id" => 9,
            "name" => "screenshots/plugin_renders/weather.png",
            "units" => []
          }
        ]
      }
    end
    let :page do
      {
        "next" => nil,
        "results" => [
          {
            "id" => 1,
            "context" => "renders->weather->title",
            "translation" => "https://x/api/translations/trmnl/plugin_renders/en/"
          }
        ]
      }
    end

    before { allow(client).to receive(:get).and_return(page, listing) }

    it "answers a line for each screenshot" do
      expect(outcomes).to eq(["screenshots/plugin_renders/weather.png: linked 1"])
    end
  end

  describe ".link_screenshot" do
    subject(:outcome) { described_class.link_screenshot client, screenshot, units }

    let(:client) { instance_double Weblate::Client, post: {} }
    let(:weather) { "screenshots/plugin_renders/weather.png" }
    let :units do
      [
        {"id" => 1, "context" => "renders->weather->title"},
        {"id" => 2, "context" => "renders->parcel->status"}
      ]
    end

    context "when the screenshot has no links yet" do
      let(:screenshot) { {"id" => 9, "name" => weather, "units" => []} }

      it "links only the strings that screenshot shows" do
        outcome
        expect(client).to have_received(:post).with("screenshots/9/units/", {"unit_id" => 1}).once
      end

      it "reports what it linked" do
        expect(outcome).to eq("#{weather}: linked 1")
      end
    end

    context "when the screenshot is already linked" do
      let(:screenshot) { {"id" => 9, "name" => weather, "units" => [1]} }

      it "leaves it alone" do
        outcome
        expect(client).not_to have_received(:post)
      end
    end

    context "when the filename names no component" do
      let(:screenshot) { {"id" => 9, "name" => "weather.png", "units" => []} }

      it "says why it skipped" do
        expect(outcome).to eq("skipped weather.png: no key prefix")
      end
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
