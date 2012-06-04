jQuery(document).ready(function(){
	
	// Load preview images
	show_video_preview();
	
	// Show first video as default
	select_video_by_position(0);
	
	$("#welcome_controller .inner_space .menu .list .video_entry").click(function(){
		select_video_by_id($(this).attr('id'));
	});
})


function show_video_preview(){
	videos = $("#welcome_controller .inner_space .menu .list .video_entry");
	for(i=0; i<videos.length; i++){
		video = videos.eq(i);
		preview = video.children('.preview');
		id = video.children('.youtube_video_id').html();
		video.attr('id',id);
		preview.html("<img src='http://img.youtube.com/vi/"+id+"/3.jpg'>");
	}
}

function select_video_by_id(video_id){ 
	video = $("#"+video_id+".video_entry");
	id = video.children('.youtube_video_id').html();
	frame = $("#video_frame");
	video_url = "http://www.youtube.com/embed/"+id+"?showinfo=0&controls=0";
	frame.attr("src", video_url);
	description_space = $("#welcome_controller .inner_space .content .description");
	description_space.children('.title').html(video.children('.title').html());
	description_space.children('.details').html(video.children('.description').html());
}

function select_video_by_position(video_position){
	videos = $("#welcome_controller .inner_space .menu .list .video_entry");
	video = videos.eq(video_position);
	id = video.children('.youtube_video_id').html();
	frame = $("#video_frame");
	video_url = "http://www.youtube.com/embed/"+id+"?showinfo=0&controls=0";
	frame.attr("src", video_url);
	description_space = $("#welcome_controller .inner_space .content .description");
	description_space.children('.title').html(video.children('.title').html());
	description_space.children('.details').html(video.children('.description').html());
}