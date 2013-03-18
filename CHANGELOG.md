# next release

* The admin interface now supports bookmarks for quickly creating drafts. Selected text on the page will be turned into Markdown. (#50)
* The 'markdown' filter now properly turns single quotes in Markdown into curly quotes. (#40)
* Add `archive_page` template flag set to true when processing archive pages. (#41)
* Make the `month` archive variable available to layouts as well as the archive template. (#41)
* Slop warnings on any `serif` command have been removed.
* List of posts for all archive data are correctly in reverse chronological order. (#48)

# v0.3.3

* Allow drag-and-drop to work on posts as well as drafts. (9ea3bebf)
* `serif new` no longer creates a sample published post (#37) and generates immediately. (#39)
* Pygments.rb is replaced with Rouge for code highlighting. (#34)

# v0.3.2

* Fix caching problems caused by #30, allowing the most recently published to appear in files that use `site.posts`. (#36)

# v0.3.1

* Be kinder about the space used by the private URL characters. (#32)
* The keyup event on any input or textarea now marks the page as having changed. Previously only on blur events. (e0df1375dd)
* Order the list of drafts by most-recently-modified first, clarify draft and post ordering above each list. (#33)
* Support custom layouts for posts as well as non-post files. (#35)
* Drag-and-drop image uploads no longer use exclusively `rw-------` permissions, now rely on umask. (605487d98)

# v0.3

* Add some caching to improve performance of post generation. (#29)
* Remove super-linear performance cost of file_digest, reducing site generation time by > 85% for 50+ posts. (#30 -- charts available in the issue)
* Make `site` available to both preview templates and archive templates. (c3e2f28)
* Intelligently add blank lines before the markdown image text strings. (#27)
* Add a `smarty` filter to do smarty processing without full Markdown. (#28)
* Fix broken URL renames for drafts in the admin interface. (#31)

# v0.2.3 

* Support drag-and-drop image uploading in the admin interface, with customisable paths. (#18)
* Generate private preview files for drafts, and generate the site on every draft change. (#19, #24)
* `serif dev` server serves 404s on missing files instead of 500 exceptions. (#22)
* Warn about _config.yml auth details after `serif new` skeleton (#23)
* Smarter onbeforeunload warnings that only fire if changes have been made. (#17)

# v0.2.2

* Make the previous and next posts available from individual post pages. (#3)

# v0.2.1

* A `file_digest` tag to compute hex digests of file contents, allowing URL fingerprinting. (#12)

# v0.2

* Support autopublishing drafts through "publish: now". (#9)

# v0.1.6

* Avoid exceptions/warnings when generating files that have no headers. (#10)
* Enable per-file non-post layouts based on the "layout" header. (#8)

# v0.1.5

* Require a confirmation before leaving an admin edit page. (#15)
* Prevent losing work when both editing a saved draft and marking it as published. (#14)

# v0.1.4

* Code with fenced blocks but no language specified no longer have an extra newline added at the end. (#4)

# v0.1.3

* Support archive pages with a configurable archive page format. (#2)
