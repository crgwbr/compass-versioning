# ===============================================
#
# Compass Configuration File
#
# Creates archived versions of compiled CSS based
# on their MD5 file hash
#
# ===============================================

require 'yaml'
require 'logger'


# Constants
BASE = File.absolute_path(".")
OUTPUT = "_combinedfiles"
MANIFEST = "#{BASE}/sass.yml"


# Compass Config
environment = :production
output_style = :compressed
relative_assets = true

project_path = BASE
sass_dir = "sass"
css_dir = OUTPUT
images_dir = "images"
generated_images_dir = "#{OUTPUT}/img/"
javascripts_dir = "js"


# Return the locations of the CSS file archive
# archivePath, archiveURL
def get_archive_locations(fullPath)
   fileHash = get_file_hash(fullPath)
   extension = File.extname(fullPath)
   archiveURL = "#{OUTPUT}/#{fileHash}#{extension}"
   archivePath = "#{BASE}/#{archiveURL}"
   return archivePath, archiveURL
end


# Return the MD5 hash of the given file
def get_file_hash(fullPath)
   contents = File.read(fullPath)
   fileHash = Digest::MD5.hexdigest(contents)
   return fileHash
end


# Get an instance of Logger
def get_logger()
   # Set up logging
   log = ::Logger.new(STDOUT)
   log.level = ::Logger::INFO
   return log
end


# Read and return the CSS file manifest
def read_manifest()
   if not File.exists?(MANIFEST)
      return {}
   end

   f = File.new(MANIFEST, "r")
   f.rewind()
   yml = f.read()
   f.close()
   return YAML.load(yml)
end


# Update the CSS file manifest
def write_manifest(fullPath, archiveURL)
   manifest = read_manifest()

   name = File.basename(fullPath)
   manifest[name] = archiveURL

   f = File.new(MANIFEST, "w")
   yml = manifest.to_yaml()
   f.write(yml)
   f.close()
end


# Create CSS version archives upon compile
# Sass calls this whenever a CSS compilation occurs
on_stylesheet_saved do |fullPath|
   # Calculate archive locations
   archivePath, archiveURL = get_archive_locations(fullPath)

   # Move File into archive path
   File.rename(fullPath, archivePath)

   # Write yml file documenting which css file to use
   write_manifest(fullPath, archiveURL)

   # Log success message
   log = get_logger()
   log.info("Compiled to #{archivePath}")
end


# Log Sass Syntax Errors
# Sass call this when a compilation error is encountered
on_stylesheet_error do |fullPath, message|
   log = get_logger()
   log.error("Error compiling #{fullPath}. Message: #{message}")
end
