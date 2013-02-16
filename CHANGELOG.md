# next release

* Generate private preview files for drafts, and generate the site on every draft change. (#19, #24)
* `serif dev` server serves 404s on missing files instead of 500 exceptions. (#22)
* Warn about _config.yml auth details after `serif new` skeleton (#23)

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
