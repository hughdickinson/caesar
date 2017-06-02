require 'spec_helper'

describe StreamEvents::ClassificationEvent do
  let(:data) { { "foo" => "bar" } }

  let(:sample_event){
    described_class.new(nil, {
      "data" => data,
      "linked" => {}
    })
  }

  describe '#notify_webhooks' do
    let(:sample_workflow){
      double("Workflow")
    }

    let(:sample_engine){
      double("Webhooks::Engine")
    }

    it 'does nothing when no webhooks are configured' do
      allow(sample_event).to receive(:linked_workflow).and_return( "nero_config" => { } )
      allow(Workflow).to receive(:find).and_return(sample_workflow)
      allow(sample_workflow).to receive(:webhooks).and_return(sample_engine)
      allow(sample_engine).to receive(:process).and_return(nil)

      expect(sample_engine).not_to receive(:process)

      sample_event.notify_webhooks(1234, data)
    end

    it 'notifies of new classifications when webhooks are configured' do
      allow(sample_event).to receive(:linked_workflow).and_return(
        "nero_config" => { "webhooks" => [ "anything at all" ] }
      )
      allow(Workflow).to receive(:find).and_return(sample_workflow)
      allow(sample_workflow).to receive(:webhooks).and_return(sample_engine)
      allow(sample_engine).to receive(:process).and_return(nil)

      expect(sample_engine).to receive(:process).once

      sample_event.notify_webhooks(1234, data)
    end
  end

  describe '#subscribers?' do
    it 'knows if there are any webhooks configured for this workflow' do
      allow(sample_event).to receive(:linked_workflow).and_return(
        "nero_config" => { "webhooks" => [ "anything at all" ] }
      )
      expect(sample_event.subscribers?).to be(true)
    end

    it 'knows if there are no webhooks configured for this workflow' do
      allow(sample_event).to receive(:linked_workflow).and_return( "nero_config" => { } )
      expect(sample_event.subscribers?).to be(false)
    end
  end

  describe '#enabled?' do
    it 'knows if this workflow has a nero_config' do
      allow(sample_event).to receive(:linked_workflow).and_return( "nero_config" => { } )
    end

    it 'knows if this workflow has no nero_config' do
      allow(sample_event).to receive(:linked_workflow).and_return( { } )
      expect(sample_event.send(:enabled?)).to be(false)
    end
  end

end
