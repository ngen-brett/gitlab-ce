# frozen_string_literal: true

shared_examples :usage_data_counter_page_event do |event|
  describe ".count(#{event})" do
    it "increments the page #{event} counter by 1" do
      expect do
        described_class.count(event)
      end.to change { described_class.read(event) }.by 1
    end
  end

  describe ".read(#{event})" do
    event_count = 5

    it "returns the total number of #{event} events" do
      event_count.times do
        described_class.count(event)
      end

      expect(described_class.read(event)).to eq(event_count)
    end
  end
end
