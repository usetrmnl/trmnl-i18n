# frozen_string_literal: true

require "erb"
require_relative "progress"
require_relative "section"

module TRMNL
  module I18n
    module Status
      # Writes a report as linked Markdown pages (all locales, one locale, one section) and a chart.
      class Pages
        BLOB_URL = "https://github.com/usetrmnl/trmnl-i18n/blob/main/lib/trmnl/i18n"
        TEMPLATES = Pathname(__dir__).join("templates").freeze

        def initialize directory, blob_url: BLOB_URL
          @directory = Pathname directory
          @blob_url = blob_url
        end

        def call report
          write_summary report
          report.each { |locale, areas| write_locale locale, Section.all(areas) }
        end

        private

        attr_reader :directory, :blob_url

        def write_summary report
          progress = report.transform_values { |areas| Progress.for areas.values.flatten }
          write "README.md", render("summary.md", report:, progress:, blob_url:)
          write "summary.svg", render("summary.svg", progress:)
        end

        def write_locale locale, sections
          total = Progress.for sections.flat_map(&:entries)
          write "#{locale}/README.md", render("locale.md", locale:, sections:, total:)
          sections.each do |section|
            next if section.left.empty?

            write "#{locale}/#{section.path}", render("section.md", locale:, section:, blob_url:)
          end
        end

        # :reek:UtilityFunction
        def render name, **locals
          ERB.new(TEMPLATES.join("#{name}.erb").read, trim_mode: "-").result_with_hash(locals)
        end

        def write path, content
          directory.join(path).tap { |file| file.dirname.mkpath }
                   .write content
        end
      end
    end
  end
end
