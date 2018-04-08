CarrierWave.configure do |config|
  if ENV["CARRIERWAVE_STORAGE"] == 'file'
    config.storage :file
  elsif ENV["CARRIERWAVE_STORAGE"] == 'dropbox'
    config.storage :dropbox
    config.dropbox_access_token = ENV["DROPBOX_ACCESS_TOKEN"]
  end
end
