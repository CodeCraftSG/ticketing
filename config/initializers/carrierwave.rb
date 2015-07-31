CarrierWave.configure do |config|
  if ENV["CARRIERWAVE_STORAGE"] == 'file'
    config.storage :file
  elsif ENV["CARRIERWAVE_STORAGE"] == 'dropbox'
    config.storage :dropbox
    config.dropbox_app_key = ENV["DROPBOX_APP_KEY"]
    config.dropbox_app_secret = ENV["DROPBOX_APP_SECRET"]
    config.dropbox_access_token = ENV["DROPBOX_ACCESS_TOKEN"]
    config.dropbox_access_token_secret = ENV["DROPBOX_ACCESS_TOKEN_SECRET"]
    config.dropbox_user_id = ENV["DROPBOX_USER_ID"]
    config.dropbox_access_type = "dropbox"
  end
end
