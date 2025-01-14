Rails.application.config.to_prepare do
  Spotlight::FeaturedImage.class_eval do
    mount_uploader :image, ExhibitsAttachmentUploader
  end
end
