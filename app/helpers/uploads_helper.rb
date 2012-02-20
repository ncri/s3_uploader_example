module UploadsHelper


  def s3_uploader options = {}
    options[:uploader_path] ||= 'uploader/uploader.html'
    options[:uploaded_files_path] ||= "#{controller_name}/:uuid"
    options[:create_resource_url] ||= url_for(only_path: false)
    options[:resource_name] ||= controller_name.singularize

    upload_params = { key: s3_key(options[:uploaded_files_path]),
                      AWSAccessKeyId: S3_CONFIG['access_key_id'],
                      _policy: s3_policy(path: options[:uploaded_files_path]),
                      _signature: s3_signature(path: options[:uploaded_files_path]) }.to_query

    content_tag :iframe, '',
                src: "http://#{S3_CONFIG['bucket_name']}.s3.amazonaws.com/#{options[:uploader_path]}?#{upload_params}",
                frameborder: 0,
                height: options[:iframe_height] || 60,
                width: options[:iframe_width] || 500,
                data: { create_resource_url: options[:create_resource_url] }
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
      S3_CONFIG['secret_access_key'], s3_policy(options))).gsub("\n","")
  end


end
