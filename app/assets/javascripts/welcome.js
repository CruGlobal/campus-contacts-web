jQuery(document).ready(function(){
  current_time = new Date()
  $.cookie('timezone', current_time.getTimezoneOffset(), { path: '/', expires: 10 })
	
	// Load preview images
	show_video_preview();
	
	// Show first video as default
	select_video_by_position(0);
	
	// Make videos in the list a link
	$("#welcome_controller .inner_space .menu .list .video_entry").click(function(){
		select_video_by_id($(this));
	});
	
	click_url();
	hide_loader();
})

function show_loader(){
  $('#global_loader').show()
}

function hide_loader(){
  $('#global_loader').hide()
}

function show_video_preview(){
	$("#welcome_controller .video_entry").each(function(){
		id = $(this).children('.youtube_video_id').html();
		$(this).children('.preview').html("<img src='http://img.youtube.com/vi/"+id+"/3.jpg'>");
	});
}

function select_video_by_id(video_div){ 
	id = video_div.children('.youtube_video_id').html();
	info = $("#welcome_controller .inner_space .content .description");
	info.children('.title').html(video_div.children('.title').html());
	info.children('.details').html(video_div.children('.description').html());
	$("#video_frame").attr("src", "http://www.youtube.com/embed/"+id+"?showinfo=0&autohide=1&autoplay=1");
}

function select_video_by_position(video_position){
	video = $("#welcome_controller .video_entry").eq(video_position);
	id = video.children('.youtube_video_id').html();
	info = $("#welcome_controller .inner_space .content .description");
	info.children('.title').html(video.children('.title').html());
	info.children('.details').html(video.children('.description').html());
	$("#video_frame").attr("src", "http://www.youtube.com/embed/"+id+"?showinfo=0&autohide=1");
}

function click_url(){
  click_id = $.url(window.location.href).param("click")
  if(click_id){
    $('#'+click_id).click()
  }
}

function send_message_guide_more(){
  custom_buttons = {}
  custom_buttons[t('dashboard.close')] = function(){
    $(this).dialog('destroy')
  }
  $('#send_message_guide').dialog({
    height: 530,
    buttons: custom_buttons
  })
  $('#send_message_guide').dialog({position: 'center'})
  $('#send_message_guide_video').fadeIn()
}