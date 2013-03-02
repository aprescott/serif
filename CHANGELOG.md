# next release

* Be kinder about the space used by the private URL characters. (#32)
* The keyup event on any input or textarea now marks the page as having changed. Previously only on blur events. (e0df1375dd)

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
