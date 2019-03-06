require 'rails_helper'

describe SendSmsJob do
  include ActiveJob::TestHelper
  include Factories::Base

  before :all do
    @sms_notification = create_sms_notification
  end

  subject(:job) { described_class.perform_later(args) }

  let(:args){ @sms_notification.id }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class)
    .with(args)
    .on_queue("default")
  end

  describe "#perform" do
    it "should call #deliver on the SmsNotification" do
      allow(SmsNotification).to receive(:find).and_return(@sms_notification)
      expect(@sms_notification).to receive(:deliver)
      SendSmsJob.perform_now(@sms_notification.id)
    end
  end
end
