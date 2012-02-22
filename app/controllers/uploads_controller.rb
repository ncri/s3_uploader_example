
class UploadsController < ApplicationController

  def index
  end

  def create
    @upload = Upload.new(params[:upload] || params.delete_if{ |p| !Upload.attribute_names.include?(p) })
    render nothing: true if @upload.save
  end

end
