jQuery(function() {

  var host = 'http://localhost:3000';

  var params = decodeURIComponent(location.href).split('?')[1].split('&');
  var s3BucketUrl;
  var jqXHR = new Array();

  for (x in params){
    key = params[x].split('=')[0]
    val = params[x].substring(params[x].search('=')+1);
    if( key == 'bucket' )
      s3BucketUrl = val;
    else
      $('#file_upload input[name=' + key.replace(/^_/,'') + ']').val(val);
   }

  // Opera doesn't handle multiple files properly so use single file selection there
  if (navigator.appName == 'Opera') {
    $('#file_upload').find('input:file').each(function () {
      $(this).removeAttr('multiple')
        // Fix for Opera, which ignores just removing the multiple attribute:
        .replaceWith($(this).clone(true));
    });
  }

  function randomString(length) {
    var chars = '0123456789abcdefghiklmnopqrstuvwxyz';
    var sRnd = '';
    for (var i=0; i<length; i++){
        var randomPoz = Math.floor(Math.random() * chars.length);
        sRnd += chars.substring(randomPoz,randomPoz+1);
    }
    return sRnd;
  }

  window.addEventListener("message", function (e) {
    if (e.origin !== host)
      return;
    jqXHR[e.data.uuid].abort();
  });

  $('#file_upload').fileupload({

    url: s3BucketUrl,

    formData: function (form) {
      data = form.serializeArray();
      if ('type' in this.files[0])
        data.push({ name: 'Content-Type', value: this.files[0].type })
      data[0].value = data[0].value.replace(':uuid', this.context)
      return data;
    },

    add: function (e, data) {
      postData = { eventType: 'add upload' }
      postData.uuidInKey = $('#file_upload input[name=key]').val().search(':uuid') != -1;
      postData.file_name = data.files[0].name
      postData.uuid = randomString(20);

      window.parent.postMessage(postData, host);

      data.context = postData.uuid;
      jqXHR[postData.uuid] = data.submit();
    },

    progress: function (e, data) {
      window.parent.postMessage({ eventType: 'upload progress',
                                  uuid: data.context,
                                  progress: parseInt(data.loaded / data.total * 100, 10) },
                                  host);
    },

    done: function (e, data) {
      var file = data.files[0];
      var postData = { eventType: 'upload done', uuid: data.context };
      postData.file_name = file.name;
      postData.s3_key = $('#file_upload input[name=key]').val().replace('/${filename}', '').replace(':uuid', data.context);
      if( 'size' in file ) postData.file_size = file.size;
      if( 'type' in file ) postData.file_type = file.type;
      window.parent.postMessage(postData, host);
    },
  });
});