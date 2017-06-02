module StreamEvents
  class ClassificationEvent
    attr_reader :stream

    def initialize(stream, hash)
      @stream = stream
      @data = hash.fetch("data")
      @linked = StreamEvents.linked_to_hash(hash.fetch("linked"))
    end

    def process
      return unless enabled?

      cache_linked_models!

      notify_webhooks(linked_workflow["id"], @data)

      stream.queue.add(ExtractWorker, classification.workflow_id, @data.to_unsafe_h)
    end

    def cache_linked_models!
      Workflow.update_cache(linked_workflow)

      linked_subjects.each do |linked_subject|
        Subject.update_cache(linked_subject)
      end
    end

    def notify_webhooks(id, data)
      if subscribers?
        wf = Workflow.find(id)
        wf.webhooks.process :new_classification, [data]
      end
    end

    def subscribers?
      return linked_workflow["nero_config"].keys.include? "webhooks"
    end

    private

    def enabled?
      return false unless linked_workflow.key?("nero_config")
      linked_workflow.fetch("nero_config").present?
    end

    def classification
      @classification ||= Classification.new(@data)
    end

    def linked_workflow
      id = @data.fetch("links").fetch("workflow")
      @linked.fetch("workflows").fetch(id)
    end

    def linked_subjects
      @linked.fetch("subjects").values
    end
  end
end
