require "test_helper"

class MailerTest < ActionMailer::TestCase
  test "application mailer class exists" do
    assert ApplicationMailer
  end

  test "application mailer has default from" do
    assert ApplicationMailer.default[:from]
  end
end
