function fileQueueError(fileObj, error_code, message) {
	try {
		var error_name = "";
		switch(error_code) {
			case SWFUpload.ERROR_CODE_QUEUE_LIMIT_EXCEEDED:
				error_name = "You have attempted to queue too many files.";
				break;
			case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
				error_name = "Can not upload 0 byte file.";
				break;
			case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
				error_name = "File size too big.";
				break;
			case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
			case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
			default:
				error_name = message
				break;
		}

		if (error_name !== "") {
			alert(error_name);
			return;
		}

	} catch (ex) { this.debug(ex); }

}

function fileDialogComplete(num_files_queued) {
	try {
		if (num_files_queued > 0) {
			this.startUpload();
		}
	} catch (ex) { this.debug(ex); }
}

function uploadProgress(fileObj, bytesLoaded) {

	try {
		var percent = Math.ceil((bytesLoaded / fileObj.size) * 100)

		var progress = new FileProgress(fileObj,  this.customSettings.upload_target);
		progress.SetProgress(percent);
		if (percent === 100) {
			progress.SetStatus("Creating thumbnail...");
			progress.ToggleCancel(false);
			progress.ToggleCancel(true, this, fileObj.id);
		} else {
			progress.SetStatus("Uploading...");
			progress.ToggleCancel(true, this, fileObj.id);
		}
	} catch (ex) { this.debug(ex); }
}

function uploadSuccess(fileObj, server_data) {
	try {
		var progress = new FileProgress(fileObj,  this.customSettings.upload_target);
		progress.SetStatus("Thumbnail Created.");
		progress.ToggleCancel(false);
	} catch (ex) { this.debug(ex); }
}

function uploadComplete(fileObj) {
	try {
		/*  I want the next upload to continue automatically so I'll call startUpload here */
		if (this.getStats().files_queued > 0) {
			this.startUpload();
		} else {
			var progress = new FileProgress(fileObj,  this.customSettings.upload_target);
			progress.SetComplete();
			progress.SetStatus(this.getStats()["successful_uploads"] + " images received.");
			progress.ToggleCancel(false);
		}
	} catch (ex) { this.debug(ex); }
}

function uploadError(fileObj, error_code, message) {
	try {
		switch(error_code) {
			case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
				try {
					var progress = new FileProgress(fileObj,  this.customSettings.upload_target);
					progress.SetCancelled();
					progress.SetStatus("Stopped");
					progress.ToggleCancel(true, this, fileObj.id);
				}
				catch (ex) { this.debug(ex); }
			case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
				alert("Upload limit exceeded.");
			break;
			default:
				alert(message);
			break;
		}
	} catch (ex) { this.debug(ex); }
}


/* ******************************************
 *	FileProgress Object
 *	Control object for displaying file info
 * ****************************************** */

function FileProgress(fileObj, target_id) {
	this.file_progress_id = "divFileProgress";

	this.fileProgressWrapper = document.getElementById(this.file_progress_id);
	if (!this.fileProgressWrapper) {
		this.fileProgressWrapper = document.createElement("div");
		this.fileProgressWrapper.className = "progressWrapper";
		this.fileProgressWrapper.id = this.file_progress_id;

		this.fileProgressElement = document.createElement("div");
		this.fileProgressElement.className = "progressContainer";

		var progressCancel = document.createElement("a");
		progressCancel.className = "progressCancel";
		progressCancel.href = "#";
		progressCancel.style.visibility = "hidden";
		progressCancel.appendChild(document.createTextNode(" "));

		var progressText = document.createElement("div");
		progressText.className = "progressName";
		progressText.appendChild(document.createTextNode(fileObj.name));

		var progressBar = document.createElement("div");
		progressBar.className = "progressBarInProgress";

		var progressStatus = document.createElement("div");
		progressStatus.className = "progressBarStatus";
		progressStatus.innerHTML = "&nbsp;";

		this.fileProgressElement.appendChild(progressCancel);
		this.fileProgressElement.appendChild(progressText);
		this.fileProgressElement.appendChild(progressStatus);
		this.fileProgressElement.appendChild(progressBar);

		this.fileProgressWrapper.appendChild(this.fileProgressElement);

		document.getElementById(target_id).appendChild(this.fileProgressWrapper);
		FadeIn(this.fileProgressWrapper, 0);

	} else {
		this.fileProgressElement = this.fileProgressWrapper.firstChild;
		this.fileProgressElement.childNodes[1].firstChild.nodeValue = fileObj.name;
	}

	this.height = this.fileProgressWrapper.offsetHeight;

}
FileProgress.prototype.SetProgress = function(percentage) {
	this.fileProgressElement.className = "progressContainer green";
	this.fileProgressElement.childNodes[3].className = "progressBarInProgress";
	this.fileProgressElement.childNodes[3].style.width = percentage + "%";
}
FileProgress.prototype.SetComplete = function() {
	this.fileProgressElement.className = "progressContainer blue";
	this.fileProgressElement.childNodes[3].className = "progressBarComplete";
	this.fileProgressElement.childNodes[3].style.width = "";

}
FileProgress.prototype.SetError = function() {
	this.fileProgressElement.className = "progressContainer red";
	this.fileProgressElement.childNodes[3].className = "progressBarError";
	this.fileProgressElement.childNodes[3].style.width = "";

}
FileProgress.prototype.SetCancelled = function() {
	this.fileProgressElement.className = "progressContainer";
	this.fileProgressElement.childNodes[3].className = "progressBarError";
	this.fileProgressElement.childNodes[3].style.width = "";

}
FileProgress.prototype.SetStatus = function(status) {
	this.fileProgressElement.childNodes[2].innerHTML = status;
}

FileProgress.prototype.ToggleCancel = function(show, upload_obj, file_id) {
	this.fileProgressElement.childNodes[0].style.visibility = show ? "visible" : "hidden";
	if (upload_obj) {
		this.fileProgressElement.childNodes[0].onclick = function() { upload_obj.cancelUpload(); return false; };
	}
}

function FadeIn(element, opacity) {
	var reduce_opacity_by = 15;
	var rate = 30;	// 15 fps


	if (opacity < 100) {
		opacity += reduce_opacity_by;
		if (opacity > 100) opacity = 100;

		if (element.filters) {
			try {
				element.filters.item("DXImageTransform.Microsoft.Alpha").opacity = opacity;
			} catch (e) {
				// If it is not set initially, the browser will throw an error.  This will set it if it is not set yet.
				element.style.filter = 'progid:DXImageTransform.Microsoft.Alpha(opacity=' + opacity + ')';
			}
		} else {
			element.style.opacity = opacity / 100;
		}
	}

	if (opacity < 100) {
		setTimeout(function() { FadeIn(element, opacity); }, rate);
	}
}