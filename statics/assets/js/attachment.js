// Derived by Adam Prescott from a code snippet used
// with implied permission:
//
// http://blog.alexmaccaw.com/svbtle-image-uploading

var createAttachment = function(file, element) {
	var data = new FormData();

	var d = new Date();
	var uid = d.getTime();

	var month = d.getMonth().toString();
	if (month.length < 2) { month = "0" + month; }

	var day = d.getDate().toString();
	if (day.length < 2) { day = "0" + day; }

	var processedName = file.name.replace(/[^a-zA-Z0-9_]/g, "_").replace(/__+/g, "_");

	var s = Serif.variables["imageUploadPattern"];
	var placeholderValues = {
		":slug": Serif.variables["currentSlug"],
		":timestamp": uid.toString(),
		":year": d.getFullYear().toString(),
		":month": month,
		":day": day,
		":name": processedName
	};

	$.each(placeholderValues, function(placeholder, value) {
		s = s.replace(placeholder, value);
	});
	
	var extension = file.name.substring(file.name.lastIndexOf('.') + 1);

	var finalName = s;

	// if it doesn't already have the extension in the name, add it,
	// otherwise, correct the, e.g., _png, to .png.
	//
	// this just avoids _png.png noise
	if (finalName.substring(finalName.length - extension.length - 1) == ("_" + extension)) {
		finalName = finalName.replace(new RegExp("_" + extension + "$"), "." + extension);
	} else {
		finalName = finalName + "." + extension;
	}

	data.append('attachment[file]', file);
	data.append('attachment[uid]',  uid);
	data.append('attachment[final_name]', finalName);

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

	var absText = '![' + file.name + '](' + finalName + ')';
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
