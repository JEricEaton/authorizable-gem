class BaseMailer < ActionMailer::Base
  EMAIL_SUBJECT_PREFIX = '[Dummy]'

  default from: 'dummy@dummy.dev'

  private
  def prefix(text)
    "#{EMAIL_SUBJECT_PREFIX} #{text}"
  end

  def mail_to_user_with_subject(subject)
    mail :to => @user.email, :subject => prefix(subject)
  end
end
