# frozen_string_literal: true

require "tasks/weblate"

namespace :weblate do
  desc "Create or update the trmnl-i18n components in Weblate"
  task :components do
    client = Weblate::Client.new url: ENV.fetch("WEBLATE_URL"), token: ENV.fetch("WEBLATE_TOKEN")
    Weblate.ensure_project client
    existing = client.get("projects/#{Weblate::PROJECT}/components/")
                     .fetch("results")
                     .to_h { [it["slug"], it] }

    Weblate::COMPONENTS.each do |name|
      if existing.key? name
        client.patch "components/#{Weblate::PROJECT}/#{name}/", Weblate.update_settings(name)
        puts "updated #{name}"
      else
        client.post "projects/#{Weblate::PROJECT}/components/", Weblate.component_settings(name)
        puts "created #{name}"
      end
    end
  end
end
