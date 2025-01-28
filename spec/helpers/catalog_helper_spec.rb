# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogHelper do
  describe '#has_thumbnail?' do
    context 'for references' do
      let(:document) { SolrDocument.new(format_main_ssim: ['Reference']) }

      it 'is true' do
        expect(has_thumbnail?(document)).to be true
      end
    end

    context 'for canvases' do
      let(:document) { SolrDocument.new(format_main_ssim: ['Page details']) }

      it { expect(has_thumbnail?(document)).to be true }
    end
  end

  describe '#exhibits_default_thumbnail' do
    before do
      expect(helper).to receive_messages(
        blacklight_config: CatalogController.blacklight_config,
        document_index_view_type: :list
      )
    end

    context 'for references' do
      let(:document) { SolrDocument.new(id: 'abc123', format_main_ssim: ['Reference']) }

      it 'renders a default thumbnail' do
        img = Capybara.string(helper.exhibits_default_thumbnail(document, {}))
        expect(img.find('img')['src']).to include 'default-square-thumbnail-book'
      end
    end

    context 'for canvases' do
      let(:document) { SolrDocument.new(id: 'abc123', format_main_ssim: ['Page details']) }

      it 'renders a default thumbnail' do
        img = Capybara.string(helper.exhibits_default_thumbnail(document, {}))
        expect(img.find('img')['src']).to include 'default-square-thumbnail-annotation'
      end
    end
  end

  describe '#notes_wrap' do
    let(:output) { '<ul class="general-notes"><li>a</li><li><p>b</p><p>c</p></li><li>d</li></ul>' }

    it 'permits embedded HTML and handles multivalued notes as an unordered list' do
      expect(helper.notes_wrap(value: %w(a <p>b</p><p>c</p> d))).to eq output
    end

    context 'single note' do
      it 'returns the note' do
        expect(helper.notes_wrap(value: %w(<p>stuff</p>))).to eq '<p>stuff</p>'
      end
    end
  end

  describe '#paragraph_joined_content' do
    subject(:content) { helper.paragraph_joined_content(value: value) }

    context 'single description' do
      let(:value) { %w(<p>stuff</p>) }

      it 'returns a description' do
        expect(content).to eq '<p>stuff</p>'
        expect(content).to be_html_safe
      end
    end

    context 'multiple descriptions' do
      let(:value) { %W[<p>stuff</p> hello\nworld] }

      it 'returns the descriptions joined by paragraphs' do
        expect(content).to eq '<p><p>stuff</p></p><p>hello</p><p>world</p>'
        expect(content).to be_html_safe
      end
    end
  end

  describe '#table_of_contents_separator' do
    context 'single value' do
      let(:input) { { document: SolrDocument.new(id: 'cf386wt1778'), value: ['Homiliae'] } }

      it 'presents content inline' do
        expect(helper.table_of_contents_separator(input)).to eq 'Homiliae'
        expect(helper.table_of_contents_separator(input)).not_to match(/data-bs-toggle='collapse'/)
      end
    end

    context 'multi-valued' do
      let(:input) { { document: SolrDocument.new(id: 'cf386wt1778'), value: ['Homiliae--euangelia'] } }

      it 'separates MODS table of contents' do
        expect(helper.table_of_contents_separator(input)).to match(%r{<li>Homiliae</li><li>euangelia</li>})
      end

      it 'collapses content' do
        expect(helper.table_of_contents_separator(input)).to match(/data-bs-toggle='collapse'/)
      end
    end

    context 'json format' do
      let(:input) { { document: SolrDocument.new(id: 'cf386wt1778'), value: ['Homiliae--euangelia'] } }

      it 'separates MODS table of contents' do
        allow(helper.request.format).to receive(:json?).and_return(true)
        expect(helper.table_of_contents_separator(input)).to eq(%w(Homiliae euangelia))
      end
    end
  end

  describe '#manuscript_link' do
    let(:druid) { 'bg021sq9590' }
    let(:input) { { value: [druid], document: document } }
    let(:show_page) { "/test-flag-exhibit-slug/catalog/#{druid}" }

    before do
      helper.extend(Module.new do
        def current_exhibit
          FactoryBot.create(:exhibit, slug: 'test-flag-exhibit-slug')
        end
      end)
    end

    context 'page details' do
      let(:title) { 'Baldwin of Ford OCist, De sacramento altaris' }
      let(:document) do
        SolrDocument.new(
          title_display: "p. 3:#{title}",
          manuscript_number_tesim: ['MS 198'],
          format_main_ssim: ['Page details']
        )
      end

      it 'removes page prefix if present' do
        expect(helper.manuscript_link(input)).to have_link(text: title, href: show_page)
      end
    end

    context 'bibilography resource' do
      let(:document) do
        SolrDocument.new(
          title_display: 'A Zotero reference',
          format_main_ssim: ['Bibliography']
        )
      end

      it 'displays druid for Bibliography resources' do
        expect(helper.manuscript_link(input)).to have_link(text: druid, href: show_page)
      end
    end
  end

  describe '#render_fulltext_highlight' do
    let(:document) { SolrDocument.new(druid: 'abc123') }

    before do
      expect(document).to receive_messages(full_text_highlights: highlights)
    end

    context 'when there is a matching highlight for the given document' do
      let(:highlights) do
        ['The first <em>Value1</em>', 'The <em>Value2</em> second']
      end

      it 'wraps each highlight value in a paragraph tag' do
        ps = helper.render_fulltext_highlight(document: document)
        expect(ps).to eq '<p>The first <em>Value1</em></p><p>The <em>Value2</em> second</p>'
      end
    end

    context 'when there are more than the configured amount of highlight snippets returned' do
      let(:highlights) do
        %w(Value1 Value2 Value3 Value4 Value5 Value6 Value7 Value8)
      end

      it 'only renders the configured amount of snippets' do
        ps = helper.render_fulltext_highlight(document: document)
        expect(ps.scan('<p>').count).to eq Settings.full_text_highlight.snippet_count
      end
    end

    context 'when there is a q param' do
      let(:highlights) do
        %w(Value1 Value2 Value3 Value4 Value5 Value6 Value7 Value8)
      end

      it 'offers a link to go the record view w/ a search initiated' do
        expect(helper).to receive_messages(current_exhibit: {}, params: { q: 'The search term' })

        link = Capybara.string(helper.render_fulltext_highlight(document: document)).find('a')
        expect(link.text).to eq('Search for "The search term" in document text')
        expect(link['href']).to match(/abc123\?search=The\+search\+term/)
      end
    end

    context 'when the response does not include highlighting for the given document' do
      let(:highlights) { [] }

      it 'is nil' do
        ps = helper.render_fulltext_highlight(document: document)
        expect(ps).to be_blank
      end
    end
  end
end
