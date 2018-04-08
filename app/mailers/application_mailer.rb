class ApplicationMailer < ActionMailer::Base
  default from: '"PHPConf.Asia" <admin@phpconf.asia>'
  layout 'mailer'

  before_action :insert_logo

  def insert_logo
    logo_path = File.join(Rails.root, 'app', 'assets', 'images', 'event_banner.png')
    attachments.inline['event_banner.png'] = File.read(logo_path)
  end
end
