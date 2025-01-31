# frozen_string_literal: true

# Display the embed iframe
class EmbeddedMiradorComponent < ViewComponent::Base
  def initialize(document:, block:)
    @document = document
    @block = block
    super
  end

  attr_reader :document, :block

  delegate :iiif_drag_n_drop, :choose_canvas_id, :choose_initial_viewer_config, to: :helpers

  def render?
    document.manifest_url.present?
  end

  def manifest_url
    @manifest_url ||= doc_manifest.starts_with?('/') ? root_url + doc_manifest.slice(1..-1) : doc_manifest
  end

  def parameters
    {
      url: manifest_url,
      canvas_id: choose_canvas_id(block) || params[:canvas_id],
      iiif_initial_viewer_config: choose_initial_viewer_config(block) || params[:iiif_initial_viewer_config]
    }
  end

  def iframe_src
    "#{Settings.iiif_embed.url}?#{parameters.to_query}"
  end

  def doc_manifest
    document.manifest_url
  end
end
