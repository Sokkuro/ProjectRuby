ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"
# bootsnap disabled on Windows paths with non-ASCII characters (e.g. OneDrive/Документы)
# require "bootsnap/setup"