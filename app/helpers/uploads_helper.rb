module UploadsHelper


  def s3_uploader options = {}
    options[:uploader_path] ||= 'uploader/uploader.html'
    options[:uploaded_files_path] ||= "#{controller_name}/:uuid"
    options[:create_resource_url] ||= url_for(only_path: false)
    options[:resource_name] ||= controller_name.singularize

    upload_params = { key: s3_key(options[:uploaded_files_path]),
                      AWSAccessKeyId: ENV['S3_UPLOADER_ACCESS_KEY'],
                      bucket: s3_bucket_url,
                      _policy: s3_policy(path: options[:uploaded_files_path]),
                      _signature: s3_signature(path: options[:uploaded_files_path]) }.to_query

    content_tag :iframe, '',
                src: "http://s3.amazonaws.com/#{ENV['S3_UPLOADER_BUCKET']}/#{options[:uploader_path]}?#{upload_params}",
                frameborder: 0,
                height: options[:iframe_height] || 60,
                width: options[:iframe_width] || 500,
                data: { create_resource_url: options[:create_resource_url] }
  end


  def s3_bucket_url
    "http://s3.amazonaws.com/#{ENV['S3_UPLOADER_BUCKET']}/"
  end


  def s3_key path
    "#{path}/${filename}"
  end


  def s3_policy options = {}
    options[:content_type] ||= ''
    options[:acl] ||= 'public-read'
    options[:max_file_size] ||= 5.megabyte
    options[:path] ||= ''

    Base64.encode64(
      "{'expiration': '#{10.hours.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z')}',
        'conditions': [
          {'bucket': '#{ENV['S3_UPLOADER_BUCKET']}'},
          ['starts-with', '$key', ''],
          {'acl': '#{options[:acl]}'},
          {'success_action_status': '201'},
          ['content-length-range', 0, #{options[:max_file_size]}],
          ['starts-with','$Content-Type','']
        ]
    }").gsub(/\n|\r/, '')
  end


  def s3_signature options = {}
    Base64.encode64(
      OpenSSL::HMAC.digest(
      OpenSSL::Digest::Digest.new('sha1'),
      ENV['S3_UPLOADER_SECRET_ACCESS_KEY'], s3_policy(options))).gsub("\n","")
  end


end
