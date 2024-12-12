# app/uploaders/backup_uploader.rb
class BackupUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "backup/"
  end

  def public_resource?
    true
  end

end