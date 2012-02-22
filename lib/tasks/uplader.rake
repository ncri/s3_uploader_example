namespace :uploader do

  task deploy: :environment do
    av = ActionView::Base.new(Rails.root.join('app', 'views'))
    uploader_html = av.render 'uploads/uploader'
    ensure_s3_connection!
    AWS::S3::S3Object.store(
      'uploader/uploader.html',
      uploader_html,
      ENV['S3_UPLOADER_BUCKET'],
      :access => :public_read )

    ['jquery.fileupload.js', 'jquery.iframe-transport.js', 's3_uploader.js'].each do |js_file|
      AWS::S3::S3Object.store(
            "uploader/js/#{js_file}",
            open("#{Rails.root}/app/assets/javascripts/s3_uploader/#{js_file}"),
            ENV['S3_UPLOADER_BUCKET'],
            :access => :public_read )
    end
    puts 'Uploader deployed.'
  end


  private


  def ensure_s3_connection!
    unless @connected
      AWS::S3::Base.establish_connection!(
        :access_key_id     => ENV['S3_UPLOADER_ACCESS_KEY'],
        :secret_access_key => ENV['S3_UPLOADER_SECRET_ACCESS_KEY']
      )
      @connected = true
    end
  end

end