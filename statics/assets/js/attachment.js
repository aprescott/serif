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

	if (/:slug/.test(s) && !(Serif.variables["currentSlug"] && Serif.variables["currentSlug"])) {
		alert("Your image upload path is set to use a slug, but no such slug exists yet.");
		return null;
	}

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

	// for some reason this is necessary to avoid the following
	// giving an undefined result:
	//
	//   1. load a new draft page with an empty textarea
	//   2. at this point element.value is undefined.
	//   3. drag an image, calling insertAtCaret
	//   4. element.value (3) in this method is still undefined (confusing!)
	//   5. in the browser console, $("[data-attachify]").get(0).value
	//      is correct. (confusing!)
	//   6. on a _second drag_, element.value is undefined (very confusing)
	//   7. in the same second drag event, $(element).get(0).value is
	//      correct, hence this "reloading" to allow element.value
	//      below to not be undefined.
	element = $(element).get(0);

	if (typeof element.value != "undefined") {
		var pos    = element.selectionStart;
		var text   = element.value;
		var before = text.slice(0, pos);
		var after  = text.slice(pos);

		// if there is only a single newline, add one more for a blank
		// line.
		if (/[^\n]\n$/.test(before)) {
			absText = "\n" + absText;
		// if there aren't two new lines, add a full two
		} else if (! /\n\n$/.test(before)) {
			absText = "\n\n" + absText;
		}

	}

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
