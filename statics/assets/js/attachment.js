// Derived by Adam Prescott from a code snippet used
// with implied permission:
//
// http://blog.alexmaccaw.com/svbtle-image-uploading

var createAttachment = function(file, element) {
	var uid  = (new Date).getTime();

	var data = new FormData();

	data.append('attachment[name]', file.name);
	data.append('attachment[file]', file);
	data.append('attachment[uid]',  uid);

	$.ajax({
		url: '/admin/attachment',
		data: data,
		cache: false,
		contentType: false,
		processData: false,
		type: 'POST',
	}).error(function() {
		console.log("error uploading image");
	});

	var absText = '![' + file.name + '](/images/' + uid + file.name.substr(file.name.lastIndexOf('.')) + ')';
	$(element).insertAtCaret(absText);
};

$(function() {
	if ($("[data-attachify]").length > 0) {
		$(document).dropArea();

		$(document).bind("drop", function(e) {
			e.preventDefault();
			e = e.originalEvent;

			var files = e.dataTransfer.files;

			for (var i=0; i < files.length; i++) {
				// Only upload images
				if (/image/.test(files[i].type)) {
					createAttachment(files[i], $("[data-attachify]").first());
				}
			};
		});
	}
});
