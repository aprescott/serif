# Serif

[![Build Status](https://travis-ci.org/aprescott/serif.png?branch=master)](https://travis-ci.org/aprescott/serif) [![Code Climate](https://codeclimate.com/github/aprescott/serif.png)](https://codeclimate.com/github/aprescott/serif) [![Coverage Status](https://coveralls.io/repos/aprescott/serif/badge.png?branch=master)](https://coveralls.io/r/aprescott/serif)

Serif is a static site generator and blogging system powered by markdown files.

## First time use

To get started with Serif based on a site skeleton:

```bash
gem install serif     # install serif
cd path/to/some/place # go to where you'll be creating your site directory
serif new             # create an initial site skeleton

# ... edit your files how you want them ...

serif generate        # generate the site based on the source files
serif dev             # serve up the site for local testing purposes
```

Now visit <http://localhost:8000/> to view the site.

# Contents of this README

* [Basic usage](#basics)
* [Content and site structure](#content-and-site-structure)
* [Publishing drafts](#publishing-drafts)
* [Updating posts](#updating-posts)
* [Archive pages](#archive-pages)
* [Configuration](#configuration)
* [Deploying](#deploying)
* [Custom tags and filters](#custom-tags-and-filters)
* [Template variables](#template-variables)
* [License and contributing](#license-and-contributing)
* [Developing Serif](#developing-serif)
* [Changes and what's new](#changes-and-whats-new)

# Basics

## Installing

Installation is via [RubyGems](https://rubygems.org/). If you don't have Ruby installed and are new to Ruby, I recommend using [RVM](https://rvm.io/).

```bash
$ gem install serif
```

## Generating the site

```bash
$ cd path/to/site/directory
$ serif generate
```

## Serving up the site for development

This runs a very simple web server that is mainly designed to test what the site will look like and let you make changes to stuff like CSS files without having to regenerate everything. Changes to post content will not be detected (yet).

```bash
$ cd path/to/site/directory
$ serif dev
```

Once this is run, visit <http://localhost:8000>.

## Generate a skeleton application

You can generate a skeletal directory to get you going, using the `new` command.

```bash
$ cd path/to/site/directory
$ serif new
```

# Content and site structure

The structure of a Serif site is something like this:

```
.
├── _site
├── _layouts
│   └── default.html
├── _drafts
│   ├── some-draft
│   └── another-unfinished-post
├── _posts
│   ├── 2012-01-01-a-post-you-have-written
│   ├── 2012-02-28-another-post
│   └── 2012-03-30-and-a-third
├── _templates
│   ├─── post.html
│   └─── archive_page.html
├── _trash
├── _config.yml
├── css
│   └── ...
├── js
│   └── ...
├── images
│   └── ...
├── 404.html
├── favicon.ico
├── feed.xml
└── index.html
```

## `_site`

This is where generated content gets saved. You should serve files out of here, be it with Nginx or Apache. You should assume everything in this directory will get erased at some point in future. Don't keep anything in it!

## `_layouts`

This is where layouts for the site go. The file `default.html` is used by default, and individual files can override this by setting a `Layout: foo` header, which will use `_layouts/foo.html` instead.

## `_drafts` and `_posts`

Drafts go in `_drafts`, posts go in `_posts`. Simple enough.

Posts must have filenames in the format of `YYYY-MM-DD-your-post`. Drafts do not have a date part, since they're drafts and not published.

All files in these directories are assumed to be written in Markdown, with simple HTTP-style headers. The Markdown renderer is [Kramdown](http://kramdown.gettalong.org/), with Smarty for punctuation tweaks, and Pygments to get syntax highlighting for [GitHub-flavoured fenced code blocks](https://help.github.com/articles/github-flavored-markdown#syntax-highlighting) (although you'll need your own CSS).

Here's an example post:

```
Title: A title of a post
Created: 2012-01-01T14:30:00+00:00

Something something.

1. A list
2. Of some stuff
3. Goes here

End of the post
```

### Headers

The headers are similar to Jekyll's YAML front matter, but here there are no formatting requirements beyond `Key: value` pairs. Header names are case-insensitive (so `title` is the same as `Title`), but values are not.

File headers like `Title: Some title` can contain any header, but certain headers have special meaning in Serif.

Header name | Meaning
----------- |:-------
`Created`   | For a post, timestamp for when it was first published. Must be a string that Ruby's `Time` class can parse. Means nothing for drafts.
`Updated`   | For a post, timestamp for when it was last updated. Must be a string that Ruby's `Time` class can parse. Means nothing for drafts.
`Title`     | Title for the draft or post.
`Update`    | For a post, When given the value of `now` (i.e., `Update: now`), the `Updated` timestamp will be updated on the next site generation. Means nothing for drafts.
`Publish`   | For a draft, when given the value of `now` (i.e., `Publish: now`), the draft will be published on the next site generation (and the `Created` set appropriately). Means nothing for a post.
`Permalink` | For a post, overrides the default permalink value defined in `_config.yml`. **Note that this is interpolated**, so `:title` in the permalink value will be replaced according to regular permalink rules. Means nothing for a draft.

Note that while it is possible for you to manually handle timestamp values, it is recommended that you rely on using the value of `now` for `Update` and `Publish`.

If you change the `permalink` value for a published post, you will break any inbound URLs as well as, e.g., any feeds that rely on the URL as a unique persistent ID.

## `_templates`

Two templates are available:

* `post.html`, which will be used to render individual post pages.
* `archive_page.html`, which will be used to render individual archive pages.

Both must be valid Liquid templates.

## `_trash`

Deleted drafts go in here just in case you want them back.

## `_config.yml`

Used for configuration settings.

Here's a sample configuration:

```yaml
permalink: /blog/:title
archive:
  enabled: yes
  url_format: /blog/:year/:month
```

If a permalink setting is not given in the configuration, the default is `/:title`. There are the following options available for permalinks:

Placeholder | Value
----------- |:-----
`:title`    | URL "slug", e.g., "your-post-title"
`:year`     | Year as given in the filename, e.g., "2012"
`:month`    | Month as given in the filename, e.g., "01"
`:day`      | Day as given in the filename, e.g., "28"

<b>NOTE</b>: if you change the permalink value, you will break existing URLs for published posts, in addition to, e.g., any feed ID values that depend on the post URL never changing.

## Other files

Any other file in the directory's root will mostly be copied over exactly as-is.

An exception is any file ending in `.html` or `.xml`. These files are assumed to contain [Liquid markup](http://liquidmarkup.org/) and will be processed as such. Header values will be available on `page`.

For example, this would work as an `about.html`:

```html
<h1>All about me</h1>
<p>Where do I begin? {{ 'Well...' }}</p>
```

And so would this:

```html
x: y

<h1>All about me</h1>
<p>Where do I begin? Well... First, x is {{ page.x }}.</p>
```

If you have a file like `feed.xml` that you wish to _not_ be contained within a layout, specify `layout: none` in the header for the file:

```html
layout: none

<?xml version="1.0" encoding="utf-8"?>
<!-- ... -->
```

# Publishing drafts

To automatically publish a draft, add a `publish: now` header to the draft:

```
title: A draft that will be published
publish: now

This is a draft that will be published now.
```

On the next site generation (`serif generate`) this draft will be automatically published, using the current time as the creation timestamp.

# Updating posts

When you update a post, you need to remember to change the updated time. As luck would have it, Serif takes care of timestamps for you! Just use a header of `update: now` at the top of your published post after making your changes:

```
title: My blog post
Created: 2013-01-01T12:01:30+00:00
update: now
```

Now the next time the site is generated, the timestamp will be updated:

```
title: My blog post
Created: 2013-01-01T12:01:30+00:00
Updated: 2013-03-18T19:03:30+00:00
```

# Archive pages

By default, archive pages are made available at `/archive/:year/month`, e.g., `/archive/2012/11`. Individual archive pages can be customised by editing the `_templates/archive_page.html` file, which is used for each month.

Within the `archive_page.html` template, you have access to the variables `month`, which is a Ruby Date instance, and `posts` for the posts within that month.

To disable archive pages, or configure the URL format, see the section on configuration.

## Linking to archive pages

To link to archive pages, there is a `site.archive` template variable available in all pages. The structure of `site.archive` is a nested map starting at years:

```ruby
{
  "posts" => [...],
  "years" => [
    {
      "date" => Date.new(2012),
      "posts" => [...],
      "months" => [
        { "date" => Date.new(2012, 12), "archive_url" => "/archive/2012/12", "posts" => [...] },
        { "date" => Date.new(2012, 11), "archive_url" => "/archive/2012/11", "posts" => [...] },
        ...
      ]
    }
  ]
}
```

Using `site.archive`, you can iterate over `years`, then iterate over `months` and use `archive_url` to link to the archive page for that given month within the year.

# Configuration

Configuration goes in `_config.yml` and must be valid YAML. Here's a sample configuration with available options:

```yaml
permalink: /posts/:title
archive:
  enabled: yes
  url_format: /archive/:year/:month
```

`permalink` is the URL format for individual post pages. The default permalink value is `/:title`. For an explanation of the format of permalinks, see above.

`archive` contains configuration options concerning archive pages. `enabled` can be used to toggle whether archive pages are generated. If set to `no` or `false`, no archive pages will be generated. By default, this value is `yes`.

The `archive` `url_format` configuration option is the format used for archive pages. The default value is `/archive/:year/:month`. **This must include both year and month.** Visiting, e.g., `/archive/2012/11` would render posts made in November 2012. See the section on archive pages above for more details.

# Deploying

To serve the site, set any web server to use `/path/to/site/directory/_site` as its root. *NOTE:* URLs generated in the site do not contain `.html` "extensions" by default, so you will need a rewrite rule. Here's an example rewrite for nginx:

```
error_page 404 @not_found_page;

location / {
	index  index.html index.htm;

	try_files $uri.html $uri $uri/ =404;
}

location @not_found_page {
	rewrite .* /404.html last;
}
```

## Generating the site

Use `ENV=production serif generate` to regenerate the site for production.

# Custom tags and filters

These tags can be used in templates, in addition to the [standard Liquid filters and tags](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers). For example:

```
{{ post.title | smarty }}

{{ post.content | markdown }}

{% file_digest foo.css prefix:- %}
```

## List of filters

* `markdown`

  e.g., `{{ post.content | markdown }}`.

  This runs the given input through a Markdown + SmartyPants renderer, with fenced codeblocks enabled.

* `smarty`

  e.g., `{{ post.title | smarty }}`.

  This runs the given input through a SmartyPants processor, so quotes, dashes and ellipses come out better. Note that the **`markdown` filter already does SmartyPants** processing.

* `strip`

  Strips trailing and leading whitespace.

  e.g., `{{ " hello " | strip }}` will render as `hello`.

* `xmlschema`

  e.g., `{{ post.created | xmlschema }}`.

  Takes a Time value and returns an ISO8601-format string, as per Ruby's `Time#xmlschema` definition.

  Example output: 2013-02-16T23:55:22+01:00

  If the time value is in UTC: 2013-02-16T22:55:22Z

* `encode_uri_component`

  e.g., `example.com/foo?url=http://mysite.com{{ post.url | encode_uri_component }}`

  Intended to provide the functionality of JavaScript's `encode_uri_component()` function. Essentially:
  encodes the entire input so it is usable as a query string parameter.

## List of tags

* `file_digest <path> [prefix:<prefix>]`

  (Note: For this tag to return anything, `ENV=production` must be set as an environment variable.)

  Computes a hex digest of the contents of `<path>`, optionally prefixed with `<prefix>`. `<path>` is delimited by whitespace.

  Useful for URL fingerprinting for long-lived caching.

# Template variables

In addition to those mentioned above, such as the archive page variables, there are others. *This may not be an exhaustive list.*

## General template variables

These should be available in any template:

* `{{ site }}` --- a container for the site itself, containing:
    * `{{ site.posts }}` --- the published posts of the site
    * `{{ site.latest_update_time }}` --- a [Ruby `Time`](http://ruby-doc.org/core/Time.html) instance for the latest time that any post was updated. Useful for RSS/Atom feeds.
    * `{{ site.archives }}` --- a nested hash structure that groups posts by month. See above for how to use it.
* `{{ draft_preview }}` -- Set to true if this is part of generating a draft preview.
* `{{ post_page }}` -- Set to true if this is part of generating a regular published post.

## Post variables

A published post has variables like `post.url` and `post.title`. Here's a list of what's available wherever `{{ post }}` is available. If the variable is, e.g., `post.url`, use as `{{ post.url }}`.

Name           | Value
------------   |:-----
`post.title`   | Title of the post
`post.url`     | Permalink to the post based on the config or any `permalink` header on the post
`post.slug`    | URL slug of the post. A filename like `2013-06-02-my-post` will correspond to a `{{ post.slug }}` value of `my-post`
`post.created` | A [Ruby `Time`](http://ruby-doc.org/core/Time.html) instance for the time the post was first published.
`post.updated` | A [Ruby `Time`](http://ruby-doc.org/core/Time.html) instance for the time the post was last updated.
`post.content` | The raw post content. Example use: `{{ post.content | markdown }}`.
`post.foo`     | The value of the `Foo` header, e.g., if `Foo: my special header` is in the source file, `post.foo` is `my special header`. All headers are merged into the `{{ post }}` variable for you to use in templates.

## Variables available within post templates

These are available on individual post pages, in `_template/post.html`.

Variable    | Value
----------- |:----
`post`      | The post being processed. See above for what values (`post.url`, ...) are available.
`prev_post` | The post published chronologically before `post`.
`next_post` | The post published chronologically after `post`.

## Archive page variables

These are set when processing archive pages.

Variable       | Value
-------------- |:-----
`month`        | The month for the archive page being rendered. This is a Ruby `Date` instance.
`posts`        | The list of posts for the month. Ordered by most-recently-published-first.
`archive_page` | A flag set to `true`.

# License and contributing

Serif is released under the MIT license. See LICENSE for details.

The quickest way to get changes contributed:

1. Visit the [GitHub repository for Serif](https://github.com/aprescott/serif).
2. [Fork the repository](https://help.github.com/articles/fork-a-repo).
3. Check out a branch on the latest master for your change: `git checkout -b master new-feature` --- do not make changes on `master`! Make sure that anything added or changed has a test in the `spec/` directory. Use the existing files as examples. All tests for new/changed behaviour should pass.
4. [Send a pull request on GitHub](https://help.github.com/articles/fork-a-repo), including a description of what you've changed.

# Developing Serif

## Broad outline

* `./bin/serif {dev,generate}` to run Serif commands.
* `rspec` to run the tests.
* `rake docs` will generate HTML documentation in `docs/`. Open `docs/index.html` in a browser to start.

## Directory structure

* `lib/serif/` is generally where files go.
* `spec/` contains the test files.

# Changes and what's new

See `CHANGELOG`.
