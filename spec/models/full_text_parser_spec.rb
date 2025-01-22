# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FullTextParser do
  subject(:parser) { described_class.new(purl_object) }

  let(:purl_object) { double('PurlObject', bare_druid: 'cc842mn9348', public_xml: public_xml) }
  let(:public_xml) { Nokogiri::XML.parse(File.read(File.join(FIXTURES_PATH, 'cc842mn9348.xml'))) }

  describe '#ocr_files' do
    it 'is an array of nokogiri elements for the appropriate files' do
      ocr_files = parser.ocr_files
      expect(ocr_files.length).to eq 1
      expect(ocr_files.first['mimetype']).to eq 'application/xml'
    end
  end

  describe '#to_text' do
    before do
      fixture_file = File.read(File.join(FIXTURES_PATH, 'cc842mn9348_ocr_1.xml'))
      file_name = 'EastTimor_CE-SPSC_Final_Decisions_2001_04b-2001_Sabino_Gouveia_Leite_Judgment_0001.xml'
      stub_request(
        :get,
        "https://stacks.stanford.edu/file/cc842mn9348/#{file_name}"
      ).to_return(status: 200, body: fixture_file)
    end

    it 'is an array of text parsed of the OCR files' do
      ocr_text = parser.to_text
      expect(ocr_text.length).to eq 1
      expect(ocr_text.first).to start_with 'INTRODUCTION 1 The trial of'
      expect(ocr_text.first).to end_with 'with the rendering of the decision.'
    end
  end

  context 'with an hOCR transcription' do
    let(:purl_object) { double('PurlObject', bare_druid: 'hocrexample', public_xml: public_xml) }
    let(:public_xml) { Nokogiri::XML.parse(File.read(File.join(FIXTURES_PATH, 'hocrexample.xml'))) }
    let(:text) do
      <<-FIXTURE
        <html>
          <body>
            <div class='ocr_page'><p class='ocr_par'><span class='ocrx_word'>asdf</span></p></div>
          </body>
        </html>
      FIXTURE
    end

    before do
      stub_request(
        :get,
        %r{^https://stacks.stanford.edu/file/hocrexample/.*\.html$}
      ).to_return(status: 200, body: text)
    end

    describe '#to_text' do
      it 'is an array of text parsed from the hOCR text' do
        ocr_text = parser.to_text
        expect(ocr_text.length).to eq 15
        expect(ocr_text.first).to eq 'asdf'
      end
    end
  end

  context 'with a plain-text transcription' do
    let(:purl_object) { double('PurlObject', bare_druid: 'xt162pg0437', public_xml: public_xml) }
    let(:public_xml) { Nokogiri::XML.parse(File.read(File.join(FIXTURES_PATH, 'xt162pg0437.xml'))) }

    before do
      stub_request(
        :get,
        %r{^https://stacks.stanford.edu/file/xt162pg0437/.*\.txt$}
      ).to_return(status: 200, body: 'asdf')
    end

    describe '#to_text' do
      it 'is an array of text parsed from the plain text fields' do
        ocr_text = parser.to_text
        expect(ocr_text.length).to eq 15
        expect(ocr_text.first).to eq 'asdf'
      end
    end
  end

  context 'when Stacks is down' do
    before do
      allow(Faraday).to receive(:get).and_raise(
        Faraday::ConnectionFailed.new('Connection refused - connect(2) for "stacks.stanford.edu" port 443')
      )
    end

    describe '#to_text' do
      it 'is an empty array' do
        ocr_text = parser.to_text.flatten
        expect(ocr_text).to eq []
      end
    end
  end
end
