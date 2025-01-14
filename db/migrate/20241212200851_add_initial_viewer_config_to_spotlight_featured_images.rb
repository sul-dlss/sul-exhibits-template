class AddInitialViewerConfigToSpotlightFeaturedImages < ActiveRecord::Migration[7.2]
  def change
    add_column :spotlight_featured_images, :iiif_initial_viewer_config, :string
  end
end
