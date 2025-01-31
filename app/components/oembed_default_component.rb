# frozen_string_literal: true

# Draws the oembed node
class OembedDefaultComponent < ViewComponent::Base
  def initialize(document:, canvas:, block:)
    @document = document
    @canvas_id = canvas
    @block = block
    super
  end

  ##
  #
  # @param [SolrDocument] document
  # @param [Integer] canvas_id
  def custom_render_oembed_tag_async
    url = helpers.context_specific_oembed_url(@document)

    content_tag :div, '', data: {
      embed_url: helpers.blacklight_oembed_engine.embed_url(
        url: url,
        canvas_id: @canvas_id,
        search: params[:search],
        maxheight: @block&.maxheight.presence || '600',
        suggested_search: (helpers.current_search_session&.query_params || {})['q']
      )
    }
  end
end
