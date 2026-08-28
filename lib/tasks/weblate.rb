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

  # Weblate shares one checkout across components in a project, and a linked component
  # rejects any repository field outright instead of ignoring it.
  SHARED_REPOSITORY_KEYS = %w[slug repo branch vcs].freeze

  COMPONENT_DEFAULTS = {
    "file_format" => "ruby-yaml",
    # raw.yml holds dotted key paths for debugging, not a translation, and "raw" is not a
    # language. Weblate applies this only while discovering languages, so a component that
    # imported raw once has to be deleted and recreated, not patched.
    "language_regex" => "^(?!raw$).+$",
    "repo" => REPOSITORY,
    "branch" => "main",
    "vcs" => "git",
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

  def self.ensure_project client
    return if client.get("projects/").fetch("results").any? { it["slug"] == PROJECT }

    client.post "projects/", PROJECT_SETTINGS
  end
end
