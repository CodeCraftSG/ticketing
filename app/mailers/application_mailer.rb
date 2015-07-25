class ApplicationMailer < ActionMailer::Base
  default from: "admin@phpconf.asia"
  layout 'mailer'

  before_action :insert_logo

  def insert_logo
    logo_path = File.join(Rails.root, 'app', 'assets', 'images', 'phpconfasia_logo_web.png')
    attachments.inline['phpconfasia_logo_web.png'] = File.read(logo_path)
  end
end
