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
    headers['Access-Control-Allow-Origin'] = 'http://do2-media.s3.amazonaws.com'
    headers['Access-Control-Allow-Methods'] = '*'

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
