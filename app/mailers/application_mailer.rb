class ApplicationMailer < ActionMailer::Base
  default from: "\"PHPConf.Asia\" <admin@phpconf.asia>"
  layout 'mailer'

  before_action :insert_logo

  def insert_logo
    logo_path = File.join(Rails.root, 'app', 'assets', 'images', 'phpconfasia2016_logo_web.png')
    attachments.inline['phpconfasia2016_logo_web.png'] = File.read(logo_path)
  end
end
