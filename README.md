# Serif

[![Build Status](https://travis-ci.org/aprescott/serif.png?branch=master)](https://travis-ci.org/aprescott/serif)

Serif is a file-based blogging engine intended for simple sites. It compiles Markdown content to static files, and there is a web interface for editing and publishing ([simple video demo](https://docs.google.com/open?id=0BxPQpxGSOOyKS1J4MmlnM3JIaXM)), because managing everything with `ssh` and `git` can be a pain, compared to having a more universally accessible editing interface.

Having problems with Serif? [Open an issue on GitHub](https://github.com/aprescott/serif/issues), or use the [Serif Google Group](https://groups.google.com/forum/#!forum/serif-rb)

# Changes and what's new

## Latest release (v0.3.1 and v0.3.2)

* Be kinder about the space used by the private URL characters. (#32)
* The keyup event on any input or textarea now marks the page as having changed. Previously only on blur events. (e0df1375dd)
* Order the list of drafts by most-recently-modified first, clarify draft and post ordering above each list. (#33)
* Support custom layouts for posts as well as non-post files. (#35)
* Drag-and-drop image uploads no longer use exclusively `rw-------` permissions, now rely on umask. (605487d98)
* (v0.3.2) Fix caching problems caused by #30, allowing the most recently published to appear in files that use `site.posts`. (#36)

## v0.3

* Add some caching to improve performance of post generation. (#29)
* Remove super-linear performance cost of file_digest, reducing site generation time by > 85% for 50+ posts. (#30 -- charts available in the issue)
* Make `site` available to both preview templates and archive templates. (c3e2f28)
* Intelligently add blank lines before the markdown image text strings. (#27)
* Add a `smarty` filter to do smarty processing without full Markdown. (#28)
* Fix broken URL renames for drafts in the admin interface. (#31)

See `CHANGELOG` for more.

# Contents of this README

* [Intro](#intro)
* [License and contributing](#license-and-contributing)
* [Basic usage](#basics)
* [Content and site structure](#content-and-site-structure)
* [Publishing drafts](#publishing-drafts)
* [Archive pages](#archive-pages)
* [Configuration](#configuration)
* [Deploying](#deploying)
* [Customising the admin interface](#customising-the-admin-interface)
* [Custom tags](#custom-tags)
* [Template variables](#template-variables)
* [Developing Serif](#developing-serif)
* [Planned features](#planned-features)

# Intro

Serif is a lot like Jekyll with a few extra moving parts. Its main aim is to provide two things:

1. Simplicity: the source and generated content are just files that can be served by any web server.
2. Ease of publishing, wherever you are.

Serif is sort of a blend between Jekyll, [Second Crack](https://github.com/marcoarment/secondcrack) and ideas from [Svbtle](http://dcurt.is/codename-svbtle). There should be flexibility with writing content, such as using the web interface, `rsync`ing from a remote machine, or editing a draft file on the remote server and having everything happen for you.

# License and contributing

Serif is released under the MIT license. See LICENSE for details.

Any contributions will be assumed by default to be under the same terms.

The quickest way to get changes contributed:

1. Visit the [GitHub repository for Serif](https://github.com/aprescott/serif).
2. [Fork the repository](https://help.github.com/articles/fork-a-repo).
3. Check out a branch on the latest master for your change: `git checkout -b master new-feature` --- do not make changes on `master`! Make sure that anything added or changed has a test in the `test/` directory. Use the existing files as examples. All tests for new/changed behaviour should pass.
4. [Send a pull request on GitHub](https://help.github.com/articles/fork-a-repo), including a description of what you've changed. (Note: your contribution will be assumed to be under the same terms of the project by default.)

For more info on development, see the section at the bottom of this README.

# Basics

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

## Installing

Installation is via [RubyGems](https://rubygems.org/). If you don't have Ruby installed, I recommend using [RVM](https://rvm.io/).

```bash
$ gem install serif
```

## Generating the site

```bash
$ cd path/to/site/directory
$ serif generate
```

## Starting the admin server

```bash
$ cd path/to/site/directory
$ ENV=production serif admin
```

Once this is run, visit <http://localhost:4567/admin> and log in with whatever is in `_config.yml` as auth credentials.

Drop the `ENV=production` part if you're running it locally.

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

All files in these directories are assumed to be written in Markdown, with simple HTTP-style headers. The Markdown renderer is [Redcarpet](https://github.com/vmg/redcarpet) (with fenced code blocks enabled), with Smarty for punctuation tweaks, and Pygments to allow syntax highlighting (although you'll need your own CSS).

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

The headers are similar to Jekyll's YAML front matter, but here there are no formatting requirements beyond `Key: value` pairs. Header names are case-insensitive (so `title` is the same as `Title`), but values are not.

(The headers `created` and `updated` must be a string that Ruby's standard Time library can parse, but this will mostly be handled for you.)

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
admin:
  username: username
  password: password
permalink: /blog/:year/:month/:title
image_upload_path: /images/:timestamp_:name
```

If a permalink setting is not given in the configuration, the default is `/:title`. There are the following options available for permalinks:

Placeholder | Value
----------- |:-----
`:title`    | URL "slug", e.g., "your-post-title"
`:year`     | Year as given in the filename, e.g., "2012"
`:month`    | Month as given in the filename, e.g., "01"
`:day`      | Day as given in the filename, e.g., "28"

### Admin drag-and-drop upload path

The `image_upload_path` configuration setting is an _absolute path_ and will be relative to the base directory of your site, used in the admin interface to control where files are sent. The default value is `/images/:timestamp_:name`. Similar to permalinks, the following placeholders are available:

Placeholder | Value
----------- |:-----
`:slug`     | URL "slug" at the time of upload, e.g., "your-post-title"
`:year`     | Year at the time of upload, e.g., "2013"
`:month`    | Month at the time of upload, e.g., "02"
`:day`      | Day at the time of upload, e.g., "16"
`:name`     | Original filename string of the image being uploaded
`:timestamp`| Unix timestamp, e.g., "1361057832685"

Any slashes in `image_upload_path` are converted to directories.

## Other files

Any other file in the directory's root will be copied over exactly as-is, with two caveats.

First, `images/` (by default) is used for the drag-and-drop file uploads from the admin interface. Files are named with `<timestamp>_ <name>.<extension>`. This is configurable, see the section on configuration.

Second, for any file ending in `.html` or `.xml`:

1. These files are assumed to contain [Liquid markup](http://liquidmarkup.org/) and will be processed as such.
2. Any header data will not be included in the processed output.

For example, this would work as an `about.html`:

```html
<h1>All about me</h1>
<p>Where do I begin? {{ 'Well...' }}</p>
```

And so would this:

```html
title: My about page

<h1>All about me</h1>
<p>Where do I begin? Well...</p>
```

In both cases, the output is, of course:

```html
<h1>All about me</h1>
<p>Where do I begin? Well...</p>
```

If you have a file like `feed.xml` that you wish to _not_ be contained within a layout, specify `layout: none` in the header for the file.

# Publishing drafts

To publish a draft, either do so through the admin interface available with `serif admin`, or add a `publish: now` header to the draft:

```
title: A draft that will be published
publish: now

This is a draft that will be published now.
```

On the next site generation (`serif generate`) this draft will be automatically published, using the current time as the creation timestamp.

# Archive pages

By default, archive pages are made available at `/archive/:year/month`, e.g., `/archive/2012/11`. Individual archive pages can be customised by editing the `_templates/archive_page.html` file, which is used for each month.

Within the `archive_page.html` template, you have access to the variables `month`, which is a Ruby Date instance, and `posts` for the posts within that month.

To disable archive pages, or configure the URL format, see the section on configuration.

## Linking to archive pages

To link to archive pages, there is a `site.archive` template variable available in all pages. The structure of `site.archive` is a nested map starting at years:

```
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

```
admin:
  username: myusername
  password: mypassword
permalink: /posts/:title
archive:
  enabled: yes
  url_format: /archive/:year/:month
```

`admin` contains the credentials used when accessing the admin interface. This information is private, of course.

`permalink` is the URL format for individual post pages. The default permalink value is `/:title`. For an explanation of the format of permalinks, see above.

`archive` contains configuration options concerning archive pages. `enabled` can be used to toggle whether archive pages are generated. If set to `no` or `false`, no archive pages will be generated. By default, this value is `yes`.

The `archive` `url_format` configuration option is the format used for archive pages. The default value is `/archive/:year/:month`. **This must include both year and month.** Visiting, e.g., `/archive/2012/11` would render posts made in November 2012. See the section on archive pages above for more details.

# Deploying

To serve the site, set any web server to use `/path/to/site/directory/_site` as its root. *NOTE:* URLs generated in the site do not contain `.html` "extensions" by default, so you will need a rewrite rule. Here's an example rewrite for nginx:

```
error_page 404 @not_found_page;

location / {
	index  index.html index.htm;

	try_files $uri.html $uri $uri/ 404;
}

location @not_found_page {
	rewrite .* /404.html last;
}
```

## Generating the site

Use `ENV=production serif generate` to regenerate the site for production.

## Admin interface

The admin server can be started on the live server the same way it's started locally (with `ENV=production`). To access it from anywhere on the web, you will need to proxy/forward `/admin` HTTP requests to port 4567 to let the admin web server handle it. As an alternative, you could forward a local port with SSH --- you might use this if you didn't want to rely on just HTTP basic auth, which isn't very secure over non-HTTPS connections.

# Customising the admin interface

The admin interface is intended to be a minimal place to focus on writing content. You are free to customise the admin interface by creating a stylesheet at `$your_site_directory/css/admin/admin.css`. As an example, if your main site's stylesheet is `/css/style.css`, you can use an `@import` rule to inherit the look-and-feel of your main site editing content and looking at rendered previews.


```css
/* Import the main site's CSS to provide a similar look-and-feel for the admin interface */

@import url("/css/style.css");

/* more customisation below */
```

# Custom tags and filters

These tags can be used in templates, in addition to the [standard Liquid filters and tags](https://github.com/Shopify/liquid/wiki/Liquid-for-Designers). For example:

```
{{ post.title | smarty }}

{{ post.content | markdown }}

{% file_digest foo.css prefix:- %}
```

## List of filters

* `date` with `'now'`
  
  This is a standard filter, but there is a [workaround](https://github.com/Shopify/liquid/pull/117) for
  `{{ 'now' | date: "%Y" }}` to work, so you can use this in templates.

* `markdown`
  
  e.g., `{{ post.content | markdown }}`.

  This runs the given input through a Markdown + SmartyPants renderer, with fenced codeblocks enabled.

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

## Variables available within post templates

These are available on individual post pages, in `_template/post.html`.

Variable    | Value
----------- |:----
`post`      | The post being processed. See above for what values (`post.url`, ...) are available.
`prev_post` | The post published chronologically before `post`.
`next_post` | The post published chronologically after `post`.

# Developing Serif

## Broad outline

* `./bin/serif {dev,admin,generate}` to run Serif commands.
* `rake test` to run the tests.
* Unit tests are written in RSpec.

## Directory structure

* `lib/serif/` is generally where files go.
* `test/` contains the test files. Any new files should have `require "test_helper"` at the top of the, which pulls in `test/test_helper.rb`.

# Planned features

Some things I'm hoping to implement one day:

1. Custom hooks to fire after particular events, such as minifying CSS after publish, or committing changes and pushing to a git repository.
2. Simple Markdown pages instead of plain HTML for non-post content.
3. Automatically detecting file changes and regenerating the site.
4. Adding custom Liquid filters and tags.