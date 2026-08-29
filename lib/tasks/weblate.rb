# frozen_string_literal: true

require "json"
require "net/http"

# Weblate instance configuration, driven through the REST API so the instance can be
# rebuilt rather than remembered. Repository tooling, loaded by lib/tasks/weblate.rake.
# :reek:TooManyConstants - the constants are the configuration; that is the point of it.
module Weblate
  COMPONENTS = %w[web_ui plugin_renders custom_plugins].freeze
  PROJECT = "trmnl"
  PROJECT_SETTINGS = {"name" => "TRMNL", "slug" => PROJECT, "web" => "https://trmnl.com/"}.freeze
  REPOSITORY = "https://github.com/usetrmnl/trmnl-i18n.git"

  # A component sharing another's checkout inherits these and answers 400 for them rather than
  # ignoring them. Which component Weblate treats as the borrower is not visible over the API —
  # is_repo_link reads null for all of them — so the update tries everything, then retries
  # without them when Weblate says so.
  INHERITED_BY_LINKED_COMPONENT = "Option is not available for linked repositories"
  INHERITED_KEYS = %w[branch push].freeze
  SHARED_REPOSITORY_KEYS = %w[slug].freeze

  COMPONENT_DEFAULTS = {
    "file_format" => "ruby-yaml",
    # raw.yml holds dotted key paths for debugging, not a translation, and "raw" is not a
    # language. Weblate applies this only while discovering languages, so a component that
    # imported raw once has to be deleted and recreated, not patched.
    "language_regex" => "^(?!raw$).+$",
    "repo" => REPOSITORY,
    "branch" => "main",
    # The github backend opens a pull request instead of pushing to the branch people
    # read. Naming a push branch is what keeps the work in this repository: Weblate
    # only forks when the push branch is absent or equal to the translated branch.
    "vcs" => "github",
    "push" => REPOSITORY,
    "push_branch" => "weblate-translations",
    "license" => "MIT"
  }.freeze

  # Thin wrapper over the Weblate REST API.
  # :reek:DataClump
  class Client
    # Raised when Weblate answers with anything other than success.
    class Error < StandardError
    end

    def initialize url:, token:
      @url = URI.parse "#{url.chomp "/"}/api/"
      @token = token
    end

    def get(path) = request Net::HTTP::Get, path

    def post(path, body) = request Net::HTTP::Post, path, body

    def patch(path, body) = request Net::HTTP::Patch, path, body

    private

    attr_reader :url, :token

    # Raises with the response body, because a Weblate validation failure says exactly
    # which field is wrong and swallowing it turns a five second fix into a guessing game.
    # :reek:FeatureEnvy
    # :reek:TooManyStatements
    def request request_class, path, body = nil
      uri = URI.join url, path
      response = send_message uri, build_message(request_class, uri, body)
      code = response.code
      payload = response.body.to_s

      fail Error, "#{request_class} #{uri}: #{code} #{payload}" unless code.start_with? "2"

      payload.empty? ? {} : JSON.parse(payload)
    end

    # :reek:FeatureEnvy
    def build_message request_class, uri, body
      request_class.new(uri).tap do |message|
        message["Authorization"] = "Token #{token}"
        next unless body

        message["Content-Type"] = "application/json"
        message.body = JSON.generate body
      end
    end

    # :reek:UtilityFunction
    def send_message uri, message
      Net::HTTP.start uri.host, uri.port, use_ssl: uri.scheme == "https" do |connection|
        connection.request message
      end
    end
  end

  def self.component_settings name
    COMPONENT_DEFAULTS.merge "name" => name.tr("_", " ").capitalize,
                             "slug" => name,
                             "filemask" => "lib/trmnl/i18n/locales/#{name}/*.yml",
                             "template" => "lib/trmnl/i18n/locales/#{name}/en.yml",
                             "screenshot_filemask" => "screenshots/#{name}/*.png"
  end

  def self.update_settings(name) = component_settings(name).except(*SHARED_REPOSITORY_KEYS)

  # Answers the settings that applied. Sent as one patch so Weblate validates them together:
  # vcs github is refused on its own because it reads push_branch as still empty.
  # :reek:TooManyStatements - one patch and a guarded retry; splitting it hides the guard.
  def self.update_component client, name
    path = "components/#{PROJECT}/#{name}/"
    settings = update_settings name
    client.patch path, settings
    settings
  rescue Client::Error => error
    raise unless error.message.include? INHERITED_BY_LINKED_COMPONENT

    settings.except(*INHERITED_KEYS).tap { client.patch path, it }
  end

  # screenshots/plugin_renders/weather.png names the strings it shows. Weblate separates
  # nested keys with -> rather than a dot, so a dotted prefix matches nothing.
  def self.key_prefix_for filename
    parts = filename.split "/"
    return unless parts.length == 3 && parts.first == "screenshots"

    "renders->#{File.basename parts.last, ".png"}->"
  end

  # Only the English units accept a screenshot link; the rest are its translations.
  # :reek:TooManyStatements - paging is a loop with a cursor; splitting it hides the cursor.
  def self.source_units client, component
    page = 1
    [].tap do |units|
      loop do
        answer = client.get "units/?q=component:#{component}&page=#{page}&page_size=200"
        units.concat(answer.fetch("results").select { it["translation"].end_with? "/en/" })
        break unless answer["next"]

        page += 1
      end
    end
  end

  # Answers a line per screenshot describing what it did, so the task itself stays a caller.
  def self.link_screenshots client, component
    units = source_units client, component
    listing = client.get "components/#{PROJECT}/#{component}/screenshots/"

    listing.fetch("results").map { link_screenshot client, it, units }
  end

  # :reek:TooManyStatements - three refusals and the link, each worth reporting separately.
  def self.link_screenshot client, screenshot, units
    name = screenshot.fetch "name"
    prefix = key_prefix_for name
    return "skipped #{name}: no key prefix" unless prefix
    return "#{name}: already linked" if screenshot.fetch("units").any?

    matching = units.select { it.fetch("context").start_with? prefix }
    matching.each do |unit|
      client.post "screenshots/#{screenshot.fetch "id"}/units/", {"unit_id" => unit.fetch("id")}
    end
    "#{name}: linked #{matching.count}"
  end

  def self.ensure_project client
    return if client.get("projects/").fetch("results").any? { it["slug"] == PROJECT }

    client.post "projects/", PROJECT_SETTINGS
  end
end
