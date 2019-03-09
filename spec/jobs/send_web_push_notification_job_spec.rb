require 'rails_helper'

describe SendWebPushNotificationJob do
  include ActiveJob::TestHelper
  include Factories::Base

  before :all do
    @notification = create_web_push_notification
  end

  subject(:job) { described_class.perform_later(args) }

  let(:args){ @notification.id }

  it 'queues the job' do
    expect { job }.to have_enqueued_job(described_class)
    .with(args)
    .on_queue("default")
  end

  describe "#perform" do
    it "should call #push on the WebPushNotification" do
      allow(WebPushNotification).to receive(:find).and_return(@notification)
      expect(@notification).to receive(:push)
      SendWebPushNotificationJob.perform_now(@notification.id)
    end
  end
end
