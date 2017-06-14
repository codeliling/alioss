<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<link type="text/css" rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/themes/smoothness/jquery-ui.min.css" media="screen" />
<link type="text/css" rel="stylesheet" href="resources/js/lib/plupload-2.3.1/jquery.ui.plupload/css/jquery.ui.plupload.css" />
</head>
<body>
<div id="uploader">
    <p>Your browser doesn't have Flash, Silverlight or HTML5 support.</p>
</div>
</body>
<script type="text/javascript" src="resources/js/lib/jquery-1.10.2.min.js" charset="UTF-8"></script>
<script type="text/javascript" src="resources/js/lib/plupload-2.3.1/plupload.full.min.js" charset="UTF-8"></script>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js" charset="UTF-8"></script>
<script type="text/javascript" src="resources/js/lib/plupload-2.3.1/jquery.ui.plupload/jquery.ui.plupload.min.js" charset="UTF-8"></script>


<script type="text/javascript">
// Initialize the widget when the DOM is ready
$(function() {
    $("#uploader").plupload({
        // General settings
        runtimes : 'html5,flash,silverlight,html4',
        url : "/examples/upload",
 
        // Maximum file size
        max_file_size : '2mb',
 
        chunk_size: '1mb',
 
        // Resize images on clientside if we can
        resize : {
            width : 200,
            height : 200,
            quality : 90,
            crop: true // crop to exact dimensions
        },
 
        // Specify what files to browse for
        filters : [
            {title : "Image files", extensions : "jpg,gif,png"},
            {title : "Zip files", extensions : "zip,avi"}
        ],
 
        // Rename files by clicking on their titles
        rename: true,
         
        // Sort files
        sortable: true,
 
        // Enable ability to drag'n'drop files onto the widget (currently only HTML5 supports that)
        dragdrop: true,
 
        // Views to activate
        views: {
            list: true,
            thumbs: true, // Show thumbs
            active: 'thumbs'
        },
 
        flash_swf_url : 'resources/js/lib/plupload-2.3.1/Moxie.swf',
		silverlight_xap_url : 'resources/js/lib/plupload-2.3.1/Moxie.xap',
    });
});
</script>
</html>