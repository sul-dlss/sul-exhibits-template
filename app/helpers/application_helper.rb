# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  # Collection titles are indexed as a compound druid + title; we need to
  # unmangle it for display.
  def collection_title(value, separator: '-|-')
    value.split(separator).last
  end

  def document_collection_title(value:, **)
    Array(value).map { |v| collection_title(v) }.to_sentence
  end

  def document_leaflet_map(document:, **)
    render_document_partial(document, 'show_leaflet_map_wrapper')
  end

  ##
  # @param [String] manifest
  def iiif_drag_n_drop(manifest, width: '30', document: nil)
    link_url = format Settings.iiif_dnd_base_url, query: { manifest: manifest }.to_query
    link_to link_url, class: 'iiif-dnd float-end', data: { turbolinks: false },
                      aria: { label: "IIIF Drag-n-drop: #{document['title_display']}" } do
      image_tag 'iiif-drag-n-drop.svg', class: 'border-0', width: width, alt: ''
    end
  end

  def context_specific_oembed_url(document)
    if feature_flags.uat_embed? && document['druid'].present?
      format(Settings.purl.uat_url, druid: document['druid'])
    else
      document.first(blacklight_config.show.oembed_field)
    end
  end

  ##
  # Splits an array of strings on internal whitespace breaks
  def split_on_white_space(values)
    values.map { |v| v.gsub('&#10;', "\n").split("\n") }.flatten.compact
  end
end
