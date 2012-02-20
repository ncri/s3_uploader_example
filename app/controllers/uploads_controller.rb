
class UploadsController < ApplicationController

  def index
    uploader_html = render_to_string( partial: 'uploads/uploader' )
    ensure_s3_connection!
    AWS::S3::S3Object.store(
      'uploader/uploader.html',
      uploader_html,
      S3_CONFIG['bucket_name'],
      :access => :public_read
    )
  end


  def create
    @upload = Upload.new(params[:upload] || params.delete_if{ |p| !Upload.attribute_names.include?(p) })
    render nothing: true if @upload.save
  end


  private

  def ensure_s3_connection!
    unless @connected
      AWS::S3::Base.establish_connection!(
        :access_key_id     => S3_CONFIG['access_key_id'],
        :secret_access_key => S3_CONFIG['secret_access_key']
      )
      @connected = true
    end
  end

end
