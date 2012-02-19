
class UploadsController < ApplicationController

  def index

    #uploader_html = render_to_string( partial: 'uploads/uploader',
    #                                  locals: { after_upload_url: url_for(controller: controller_name, action: create) } )
    #ensure_s3_connection!
    #AWS::S3::S3Object.store(
    #  'uploader/uploader.html',
    #  uploader_html,
    #  S3_CONFIG['bucket_name'],
    #  :access => :public_read
    #)


   # raise s3_signature(path: folder)

    folder = 'uploaded_files'
    @frame_params = (["key=#{s3_key(folder)}",
                       "AWSAccessKeyId=#{S3_CONFIG['access_key_id']}",
                       "policy=#{s3_policy(path: folder)}",
                       "signature=#{s3_signature(path: folder)}"].join('&')).gsub('=', '%3D')
  end


  def s3_bucket_url
    "http://#{S3_CONFIG['bucket_name']}.s3.amazonaws.com/"
  end


  def s3_key path
    "#{path}/${filename}"
  end


  def s3_policy options = {}
    options[:content_type] ||= ''
    options[:acl] ||= 'public-read'
    options[:max_file_size] ||= 20.megabyte
    options[:path] ||= ''

    Base64.encode64(
      "{'expiration': '#{10.hours.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')}',
        'conditions': [
          {'bucket': '#{S3_CONFIG['bucket_name']}'},
          ['starts-with', '$key', '#{options[:path]}'],
          {'acl': '#{options[:acl]}'},
          {'success_action_status': '201'},
          ['content-length-range', 0, #{options[:max_file_size]}],
          ['starts-with', '#{options[:content_type]}', '']
        ]
    }").gsub(/\n|\r/, '')
  end


  def s3_signature options = {}
    Base64.encode64(
      OpenSSL::HMAC.digest(
      OpenSSL::Digest::Digest.new('sha1'),
      S3_CONFIG['secret_access_key'], s3_policy(options))).gsub("\n","")
  end


  def create
    @upload = Upload.new(params[:upload])
    if @upload.save
      render text: 'Upload created!', status: 201
    end

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
