# config/initializers/load_sqlite_from_gcs.rb
require "google/cloud/storage"

# Retrieve configuration from environment
bucket_name = ENV["GCS_BUCKET_NAME"]
project_id  = ENV["GCS_PROJECT_ID"]
# GOOGLE_APPLICATION_CREDENTIALS is used automatically if set

sqlite_path = Rails.root.join("db", "production.sqlite3")

begin
  storage = Google::Cloud::Storage.new(project_id: project_id)
  bucket = storage.bucket(bucket_name)

  if bucket.nil?
    Rails.logger.error "Bucket #{bucket_name} not found in project #{project_id}."
  else
    file = bucket.file("production.sqlite3")
    if file
      Rails.logger.info "Downloading SQLite file from GCS..."
      file.download(sqlite_path.to_s)
    else
      Rails.logger.info "No existing SQLite file in GCS; a new database will be created."
    end
  end
rescue StandardError => e
  Rails.logger.error "Error accessing GCS: #{e.message}"
end

# At exit, upload the SQLite file back to GCS.
at_exit do
  begin
    if File.exist?(sqlite_path)
      Rails.logger.info "Uploading SQLite file to GCS..."
      bucket = storage.bucket(bucket_name)
      # Overwrite the file in GCS with the local version.
      bucket.create_file(sqlite_path.to_s, "production.sqlite3", acl: "publicRead")
    end
  rescue StandardError => e
    Rails.logger.error "Error uploading SQLite file to GCS: #{e.message}"
  end
end
