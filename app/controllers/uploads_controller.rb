
class UploadsController < ApplicationController

  def index
  end

  def create
    @upload = Upload.new(params[:upload] || params.delete_if{ |p| !Upload.attribute_names.include?(p) })
    @upload.save ? render(json: @upload.id) : render(nothing: true)
  end

end
