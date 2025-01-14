# frozen_string_literal: true

# An extension of Spotlight::AttachmentUploader with a specific CarrierWave size range
class ExhibitsAttachmentUploader < Spotlight::AttachmentUploader
  def size_range
    1..(10.megabytes)
  end
end
