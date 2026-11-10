# frozen_string_literal: true

require "spec_helper"
require "trmnl/i18n/status/pages"
require "trmnl/i18n/status/report"

RSpec.describe TRMNL::I18n::Status::Pages do
  subject(:pages) { described_class.new temp_dir, blob_url: "https://example.test" }

  include_context "with temporary directory"

  let(:fixtures) { SPEC_ROOT.join "fixtures/status" }
  let(:kept_words) { TRMNL::I18n::Status::KeptWords.new path: fixtures.join("kept_words.yml") }
  let(:kept) { TRMNL::I18n::Status::Kept.new words: kept_words, root: fixtures.join("no_kept_keys") }
  let(:report) { TRMNL::I18n::Status::Report.new(root: fixtures, kept:).call }

  def written(path) = temp_dir.join(path).read

  before { pages.call report }

  describe "#call" do
    it "lists every locale with its percent per area" do
      expect(written("README.md")).to include(
        "| [`fr`](fr/README.md) | ███████░░░ 71.4% | 2 | 100.0% | 66.7% |"
      )
    end

    it "links the kept words file" do
      expect(written("README.md")).to include("(https://example.test/status/kept_words.yml)")
    end

    it "draws a bar per locale sized by its percent" do
      expect(written("summary.svg")).to include(%(width="214" height="12" rx="3" fill="#2da44e"))
    end

    it "links each section with strings left from the locale page" do
      expect(written("fr/README.md")).to include(
        "| web_ui | [`devices`](web_ui/devices.md) | ░░░░░░░░░░ 0.0% | 2 |"
      )
    end

    it "names a finished section without a link" do
      expect(written("fr/README.md")).to include("| plugin_renders | `renders` |")
    end

    it "links each string left to its line" do
      expect(written("fr/web_ui/devices.md")).to include(
        "| `devices.edit.presentation` | Presentation | English | " \
        "[line 5](https://example.test/locales/web_ui/fr.yml#L5) |"
      )
    end

    it "marks an empty value" do
      expect(written("fr/web_ui/devices.md")).to include("| `devices.edit.theme` | Theme | empty |")
    end

    it "writes no page for a finished section" do
      expect(temp_dir.join("fr/plugin_renders/renders.md").exist?).to be(false)
    end
  end

  context "with a long English string the locale file lacks" do
    let :report do
      entry = TRMNL::I18n::Status::Entry[
        key: "a.b", english: "Long | text " * 10, value: nil, line: nil, kept: false
      ]
      {"fr" => {"web_ui" => [entry]}}
    end

    it "escapes the table separator, cuts the text and says the key is not in the file" do
      expect(written("fr/web_ui/a.md")).to include("| `a.b` | Long \\| text Long \\| text")
        .and include("… | empty | not in file |")
    end
  end
end
