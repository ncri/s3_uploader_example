module UploadsHelper

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

end
