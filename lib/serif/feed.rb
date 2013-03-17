module Serif
  module Feed
    TEMPLATE = <<END_FEED_TEMPLATE
<?xml version="1.0" encoding="utf-8"?>

<feed xmlns="http://www.w3.org/2005/Atom">
  <title>{{ feed_title }}</title>
  <link rel="self" type="application/atom+xml" href="{{ feed_url }}"/>
  <link rel="alternate" type="text/html" href="{{ feed_alternate }}"/>
  <id>tag:{{ feed_tag_domain }},{{ feed_global_unique_permanent_id }}</id>
  <updated>{{ site.latest_update_time | xmlschema }}</updated>
  <author>
    <name>{{ feed_author_name }}</name>
    <uri>{{ feed_author_url }}</uri>
  </author>
  {% for post in site.posts limit:10 %}
  <entry>
    <id>tag:{{ feed_tag_domain }},{{ post.created | date: "%Y-%m-%d" }}:{{ post.slug | strip }}</id>
    <title type="html">{{ post.title | smarty | replace:"&","&amp;" | replace:"<","&lt;" | replace:">","&gt;" }}</title>
    <updated>{{ post.updated | xmlschema }}</updated>
    <published>{{ post.created | xmlschema }}</published>
    <link href="{{ post.url }}" rel="alternate" type="text/html"/>
    <content type="html">{{ post.content | markdown | escape }}</content>
  </entry>
  {% endfor %}
</feed>
END_FEED_TEMPLATE

    def self.generate(site)
      return nil if !site.config.feed["enabled"] || site.posts.empty?

      template = Liquid::Template.parse(TEMPLATE)
      feed_path = site.config.feed["path"] || "/feed"

      variables = {
        "feed_url"                        => site.base_url + feed_path,
        "feed_title"                      => site.config.feed["title"],
        "feed_alternate"                  => site.base_url,
        "feed_global_unique_permanent_id" => site.config.feed["permanent_unique_id"],
        "feed_author_name"                => site.config.feed["author_name"],
        "feed_author_url"                 => site.base_url,
        "feed_tag_domain"                 => site.config.feed["domain"]
      }

      variables.merge!({
        "site" => site
      })

      file_path = site.site_path(feed_path + ".xml")
      content = template.render!(variables)

      File.open(file_path, "w") do |f|
        f.puts(content)
      end
    end
  end
end