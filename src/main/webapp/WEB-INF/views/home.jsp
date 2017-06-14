<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page language="java" import="java.util.*" contentType="text/html;charset=utf-8"%>
<%@ page session="false"%>
<html>
<head>
<meta charset="UTF-8">
<title>Home</title>
</head>
<body>
	<h2>OSS web直传---在服务端java签名,浏览器直传</h2>
	<ol>
		<li>基于plupload封装</li>
		<li>支持html5,flash,silverlight,html4 等协议上传</li>
		<li>可以运行在PC浏览器，手机浏览器，微信</li>
		<li>签名在服务端(php)完成, 安全可靠, 推荐使用!</li>
		<li>显示上传进度条</li>
		<li>可以控制上传文件的大小,允许上传文件的类型,本例子设置了，只能上传jpg,png,gif结尾和zip文件，最大大小是10M</li>
		<li>最关键的是，让你10分钟之内就能移植到你的系统，实现以上牛逼的功能！</li>
		<li>注意一点:bucket必须设置了Cors(Post打勾）,不然没有办法上传</li>
		<li>注意一点:此例子默认是上传到user-dir目录下面，这个目录的设置是在php/get.php, $dir变量!</li>
		<li><a href="https://help.aliyun.com/document_detail/oss/practice/pc_web_upload/js_php_upload.html">点击查看详细文档</a></li>
	</ol>
	<br>
	<form name=theform>
		<input type="radio" name="myradio" value="local_name" checked=true /> 上传文件名字保持本地文件名字 <input type="radio" name="myradio" value="random_name" /> 上传文件名字是随机文件名, 后缀保留
	</form>

	<h4>您所选择的文件列表：</h4>
	<div id="ossfile">你的浏览器不支持flash,Silverlight或者HTML5！</div>

	<br />


	<div id="container">
		<a id="selectfiles" href="javascript:void(0);" class='btn'>选择文件</a> <a id="postfiles" href="javascript:void(0);" class='btn'>开始上传</a>
	</div>

	<pre id="console"></pre>

	<p>&nbsp;</p>
</body>
<script type="text/javascript" src="resources/js/lib/jquery-1.10.2.min.js" charset="UTF-8"></script>

<script type="text/javascript" src="resources/js/lib/plupload-2.3.1/plupload.full.min.js" charset="UTF-8"></script>

<script type="text/javascript">
	accessid = ''
	accesskey = ''
	host = ''
	policyBase64 = ''
	signature = ''
	callbackbody = ''
	filename = ''
	key = ''
	expire = 0
	g_object_name = ''
	g_object_name_type = ''
	now = timestamp = Date.parse(new Date()) / 1000;

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

	function check_object_radio() {
		var tt = document.getElementsByName('myradio');
		for (var i = 0; i < tt.length; i++) {
			if (tt[i].checked) {
				g_object_name_type = tt[i].value;
				break;
			}
		}
	}

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
		if (g_object_name_type == 'local_name') {
			g_object_name += "${filename}"
		} else if (g_object_name_type == 'random_name') {
			suffix = get_suffix(filename)
			g_object_name = key + random_string(10) + suffix
		}
		return ''
	}

	function get_uploaded_object_name(filename) {
		if (g_object_name_type == 'local_name') {
			tmp_name = g_object_name
			tmp_name = tmp_name.replace("${filename}", filename);
			return tmp_name
		} else if (g_object_name_type == 'random_name') {
			return g_object_name
		}
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
						check_object_radio();
						set_upload_param(up, file.name, true);
					},

					UploadProgress : function(up, file) {
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
