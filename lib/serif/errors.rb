module Serif
  # General error class. Allows capturing general errors
  # applicable only to Serif.
  class Error < RuntimeError; end

  # Represents a conflict between published posts and drafts.
  # This should be used whenever two posts would occupy the same
  # URL / file path.
  class PostConflictError < Error; end
end