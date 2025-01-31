# frozen_string_literal: true

# Override the default spotlight viewer to pick between mirador 3, an oembed viewer, or the default OSD viewer
# depending on the document.
class CustomViewerComponent < Blacklight::Component
  attr_reader :document, :presenter, :view_config, :classes, :block_context

  def initialize(document:, presenter:, view_config: nil, block_context: nil, **kwargs)
    super

    @document = document
    @presenter = presenter
    @view_config = view_config
    @block_context = block_context
  end

  def required_viewer
    helpers.current_exhibit.required_viewer
  end

  ##
  # Renders a viewer for an object with understanding of the context. In the
  # context of spotlight/catalog render the configured viewer. In other contexts
  # (feature page) render the default viewer. Now passes through a "block" from
  # SirTrevor, used for rendering viewers in specific ways (canvas index).
  # @param [SolrDocument] document
  # @param [SirTrevorRails::Blocks::SolrDocumentsEmbedBlock] block
  def render_viewer_in_context
    canvas = choose_canvas_id
    partial = if params[:controller] == 'spotlight/catalog'
                required_viewer.to_partial_path
              else
                required_viewer.default_viewer_path
              end

    render partial:, locals: { document:, block: block_context, canvas:, oembed_url: }
  end

  ##
  # This method sends the message of which IIIF canvas should be selected by the sul-embed viewer.
  # @param [SirTrevorRails::Blocks::SolrDocumentsEmbedBlock] block
  # @return [String] Selected canvas URI
  def choose_canvas_id
    block_context&.items&.dig(0, 'iiif_canvas_id') if block_context.respond_to? :items
  end

  def oembed_url
    @oembed_url ||= helpers.context_specific_oembed_url(document)
  end
end
