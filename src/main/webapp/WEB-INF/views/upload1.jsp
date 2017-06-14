<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<link type="text/css" rel="stylesheet" href="resources/css/jquery/themes/humanity/jquery-ui.css" />
</head>
<body>
	<h4>您所选择的文件列表：</h4>
	<div id="ossfile">你的浏览器不支持flash,Silverlight或者HTML5！</div>

	<br />

	<div id="container">
		<a id="selectfiles" href="javascript:void(0);" class='btn'>选择文件</a> <a id="postfiles" href="javascript:void(0);" class='btn'>开始上传</a>
	</div>

	<pre id="console"></pre>
	<div id="progressbar" style="width: 100px; height: 5px;"></div>
	<p>&nbsp;</p>
</body>

<script type="text/javascript" src="resources/js/lib/jquery-1.10.2.min.js" charset="UTF-8"></script>
<script type="text/javascript" src="resources/js/lib/jquery/jquery-ui.js" charset="UTF-8"></script>
<script type="text/javascript" src="resources/js/lib/plupload-2.3.1/plupload.full.min.js" charset="UTF-8"></script>
<script type="text/javascript">
	$(function() {
		$("#progressbar").progressbar({
			value : 5
		});
	});

	var accessid = '';
	var accesskey = '';
	var host = '';
	var policyBase64 = '';
	var signature = '';
	var callbackbody = '';
	var filename = '';
	var key = '';
	var expire = 0;
	var g_object_name = '';
	var now = timestamp = Date.parse(new Date()) / 1000;

	var progressbar = $("#progressbar");

	function send_request() {
		var xmlhttp = null;
		if (window.XMLHttpRequest) {
			xmlhttp = new XMLHttpRequest();
		} else if (window.ActiveXObject) {
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
		}

		if (xmlhttp != null) {
			serverUrl = 'uploadKey'
			xmlhttp.open("GET", serverUrl, false);
			xmlhttp.send(null);
			return xmlhttp.responseText
		} else {
			alert("Your browser does not support XMLHTTP.");
		}
	};

	function get_signature() {
		//可以判断当前expire是否超过了当前时间,如果超过了当前时间,就重新取一下.3s 做为缓冲
		now = timestamp = Date.parse(new Date()) / 1000;
		if (expire < now + 3) {
			body = send_request()
			var obj = eval("(" + body + ")");
			host = obj['host']
			policyBase64 = obj['policy']
			accessid = obj['accessid']
			signature = obj['signature']
			expire = parseInt(obj['expire'])
			callbackbody = obj['callback']
			key = obj['dir']
			return true;
		}
		return false;
	};

	function random_string(len) {
		len = len || 32;
		var chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678';
		var maxPos = chars.length;
		var pwd = '';
		for (i = 0; i < len; i++) {
			pwd += chars.charAt(Math.floor(Math.random() * maxPos));
		}
		return pwd;
	}

	function get_suffix(filename) {
		pos = filename.lastIndexOf('.')
		suffix = ''
		if (pos != -1) {
			suffix = filename.substring(pos)
		}
		return suffix;
	}

	function calculate_object_name(filename) {

		suffix = get_suffix(filename)
		g_object_name = key + random_string(10) + suffix

	}

	function get_uploaded_object_name(filename) {
		return g_object_name;
	}

	function set_upload_param(up, filename, ret) {
		if (ret == false) {
			ret = get_signature()
		}
		g_object_name = key;
		if (filename != '') {
			suffix = get_suffix(filename)
			calculate_object_name(filename)
		}
		new_multipart_params = {
			'key' : g_object_name,
			'policy' : policyBase64,
			'OSSAccessKeyId' : accessid,
			'success_action_status' : '200', //让服务端返回200,不然，默认会返回204
			'callback' : callbackbody,
			'signature' : signature,
		};

		up.setOption({
			'url' : host,
			'multipart_params' : new_multipart_params
		});

		up.start();
	}

	var uploader = new plupload.Uploader(
			{
				runtimes : 'html5,flash,silverlight,html4',
				browse_button : 'selectfiles',
				//multi_selection: false,
				container : document.getElementById('container'),
				flash_swf_url : 'resources/js/lib/plupload-2.3.1/Moxie.swf',
				silverlight_xap_url : 'resources/js/lib/plupload-2.3.1/Moxie.xap',
				url : 'http://oss.aliyuncs.com',

				filters : {
					mime_types : [ //只允许上传图片和zip,rar文件
					{
						title : "Image files",
						extensions : "jpg,gif,png,bmp"
					}, {
						title : "Zip files",
						extensions : "zip,rar"
					} ],
					max_file_size : '10mb', //最大只能上传10mb的文件
					prevent_duplicates : true
				//不允许选取重复文件
				},

				init : {
					PostInit : function() {
						document.getElementById('ossfile').innerHTML = '';
						document.getElementById('postfiles').onclick = function() {
							set_upload_param(uploader, '', false);
							return false;
						};
					},

					FilesAdded : function(up, files) {
						plupload
								.each(
										files,
										function(file) {
											document.getElementById('ossfile').innerHTML += '<div id="' + file.id + '">'
													+ file.name
													+ ' ('
													+ plupload
															.formatSize(file.size)
													+ ')<b></b>'
													+ '<div class="progress"><div class="progress-bar" style="width: 0%"></div></div>'
													+ '</div>';
										});
					},

					BeforeUpload : function(up, file) {
						set_upload_param(up, file.name, true);
					},

					UploadProgress : function(up, file) {
						progressbar.progressbar("value", file.percent);
						var d = document.getElementById(file.id);

						d.getElementsByTagName('b')[0].innerHTML = '<span>'
								+ file.percent + "%</span>";
						var prog = d.getElementsByTagName('div')[0];
						var progBar = prog.getElementsByTagName('div')[0]
						progBar.style.width = 2 * file.percent + 'px';
						progBar.setAttribute('aria-valuenow', file.percent);
					},

					FileUploaded : function(up, file, info) {
						if (info.status == 200) {
							console.log(info.response);
							document.getElementById(file.id)
									.getElementsByTagName('b')[0].innerHTML = 'upload to oss success, object name:'
									+ get_uploaded_object_name(file.name);
						} else {
							document.getElementById(file.id)
									.getElementsByTagName('b')[0].innerHTML = info.response;
						}
					},

					Error : function(up, err) {
						if (err.code == -600) {
							document
									.getElementById('console')
									.appendChild(
											document
													.createTextNode("\n选择的文件太大了,可以根据应用情况，在upload.js 设置一下上传的最大大小"));
						} else if (err.code == -601) {
							document
									.getElementById('console')
									.appendChild(
											document
													.createTextNode("\n选择的文件后缀不对,可以根据应用情况，在upload.js进行设置可允许的上传文件类型"));
						} else if (err.code == -602) {
							document.getElementById('console').appendChild(
									document.createTextNode("\n这个文件已经上传过一遍了"));
						} else {
							document.getElementById('console').appendChild(
									document.createTextNode("\nError xml:"
											+ err.response));
						}
					}
				}
			});

	uploader.init();
</script>
</html>