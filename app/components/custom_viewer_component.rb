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
    @block_context = correct_block(block_context)
  end

  def correct_block(block_context)
    block_context&.item&.select { |_key, value| value['id'] == @document.id }
  end
end
