# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DorHarvester do
  subject(:harvester) { described_class.create druid_list: druid, exhibit: exhibit }

  let(:exhibit) { create(:exhibit) }
  let(:druid) { 'xf680rd3068' }
  let(:blacklight_solr) { double }

  before do
    allow(harvester).to receive(:exhibit).and_return(exhibit)
  end

  describe '.instance' do
    subject { described_class.instance(exhibit) }

    before { subject.save! }

    it 'behaves like a singleton' do
      expect(described_class.instance(exhibit)).to eq subject
    end
  end

  describe '#druids' do
    context 'with a single item' do
      subject { described_class.new druid_list: 'xf680rd3068' }

      it 'extracts an array of DRUIDs from the list of druids' do
        expect(subject.druids).to match_array 'xf680rd3068'
      end
    end

    context 'with multiple items' do
      subject { described_class.new druid_list: "xf680rd3068\nxf680rd3069" }

      it 'extracts an array of DRUIDs from the list of druids' do
        expect(subject.druids).to match_array %w(xf680rd3068 xf680rd3069)
      end
    end

    context 'with crazy whitespace' do
      subject { described_class.new druid_list: "\t xf680rd3068\t\r\nxf680rd3067\t\t" }

      it 'extracts an array of DRUIDs from the list of druids' do
        expect(subject.druids).to match_array %w(xf680rd3068 xf680rd3067)
      end
    end
  end

  context 'hooks' do
    before { ActiveJob::Base.queue_adapter = :test }

    let(:resource) { instance_double(Purl, bare_druid: druid) }

    # rubocop:disable Layout/LineLength
    describe '#on_success' do
      it 'records a successful index for a druid' do
        expect { subject.on_success(resource) }.to have_enqueued_job(RecordIndexStatusJob).with(harvester, druid, ok: true)
      end

      it 'does not enqueue IndexRelatedContentJob unless enabled for exhibit' do
        expect { subject.on_success(resource) }.not_to have_enqueued_job(IndexRelatedContentJob)
      end

      context 'when index_related_content is enabled for an exhibit' do
        subject(:harvester) { described_class.create druid_list: druid, exhibit: exhibit }

        let(:exhibit) { create(:exhibit, slug: 'test-flag-exhibit-slug') }

        it 'enqueues IndexRelatedContentJob' do
          expect { subject.on_success(resource) }.to have_enqueued_job(IndexRelatedContentJob).with(harvester, druid)
        end
      end
    end

    describe '#on_error' do
      it 'records an indexing error for a druid' do
        expect { subject.on_error(resource, 'error message') }.to have_enqueued_job(RecordIndexStatusJob).with(harvester, druid, ok: false, message: 'error message')
      end

      it 'records an indexing exception for a druid' do
        expect { subject.on_error(resource, RuntimeError.new('error message')) }.to have_enqueued_job(RecordIndexStatusJob).with(harvester, druid, ok: false, message: '#<RuntimeError: error message>')
      end

      it 'records an indexing exception for a druid even if very large' do
        e = RuntimeError.new('error' * 1.megabyte)
        inspected = e.inspect.truncate(1.megabyte)
        expect { subject.on_error(resource, e) }.to have_enqueued_job(RecordIndexStatusJob).with(harvester, druid, ok: false, message: inspected)
      end
    end
    # rubocop:enable Layout/LineLength
  end

  def sidecar
    Spotlight::SolrDocumentSidecar.find_or_initialize_by(document_id: druid, document_type: 'SolrDocument')
  end

  describe '#update_collection_metadata!' do
    let(:resource) do
      instance_double(Purl, bare_druid: druid,
                            exists?: true,
                            collection?: true,
                            items: [1, 2, 3])
    end

    before do
      allow(Purl).to receive(:new).with(druid).and_return(resource)
    end

    it 'retrieves collection metadata' do
      subject.update_collection_metadata!
      expect(subject.collections[druid]).to eq 'size' => 3
    end
  end

  describe '#resources' do
    let(:resource) { subject.resources.first }

    it 'is a Purl resource' do
      expect(resource).to be_a_kind_of Purl
    end

    it 'has the correct druid' do
      expect(resource.druid).to eq 'xf680rd3068'
    end
  end

  describe '#indexable_resources' do
    subject { harvester.indexable_resources.to_a }

    let(:items) { [] }
    let(:resource) do
      instance_double(Purl, exists?: true, bare_druid: druid, items: items)
    end

    before do
      allow(Purl).to receive(:new).with(druid).and_return(resource)
    end

    context 'with a published druid' do
      it 'includes resources' do
        expect(subject.size).to eq 1
        expect(subject.first.bare_druid).to eq druid
      end
    end

    context 'with a collection' do
      let(:items) { [child].each } # `#each` converts the array to an enumerable
      let(:child) { instance_double(PurlFetcher::Client::PublicXmlRecord, druid: druid) }

      it 'includes child resources' do
        expect(subject.size).to eq 2
        expect(subject.first.bare_druid).to eq resource.bare_druid
        expect(subject.last.bare_druid).to eq druid
      end
    end
  end
end
