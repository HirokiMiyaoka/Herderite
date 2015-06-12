var SteelBlue;
(function (SteelBlue) {
	var FileUploader = (function () {
		function FileUploader() {
			this.httpobj = null;
			this.reader = null;
			this.callback = null;
			if (FileUploader.boundary == "") {
				FileUploader.boundary = "----SDDUploaderFormBoundary" + this.RandomString(20);
			}
			FileUploader.self = this;
		}
		FileUploader.prototype.SetCallback = function (cbfunc) {
			this.callback = cbfunc;
		};

		FileUploader.prototype.UploadFile = function (address, path, file) {
			this.httpobj = this.HttpCreate();
			this.httpobj.open("post", address, false);
			if (this.httpobj == null) {
				return null;
			}

			this.file = file;

			this.reader = new FileReader();
			this.reader.onload = function (event) {
				FileUploader.self.FileLoader(event, path);
			};
			this.reader.readAsBinaryString(file);
			return this.httpobj;
		};

		FileUploader.prototype.FileLoader = function (event, path) {
			var data = "";

			// Multipart header.
			this.MultipartHeader();

			// File data.
			data += this.MultipartFile('upfile', this.file);

			// Path data.
			data += this.MultipartData('path', path);

			// Multipart footer.
			data += this.MultipartFooter();

			// Send data.
			this.httpobj.sendAsBinary(data);

			// Result.
			if (this.callback != null) {
				this.callback(this.httpobj.responseText);
			}
		};

		FileUploader.prototype.HttpCreate = function () {
			if (window.navigator.userAgent.toLowerCase().indexOf("chrome") > -1) {
				XMLHttpRequest.prototype.sendAsBinary = function (datastr) {
					function byteValue(x) {
						return x.charCodeAt(0) & 0xff;
					}
					var ords = Array.prototype.map.call(datastr, byteValue);
					var ui8a = new Uint8Array(ords);
					try  {
						this.send(ui8a);
					} catch (error) {
						this.send(ui8a.buffer);
					}
				};
			}

			try  {
				this.httpobj = new XMLHttpRequest();
			} catch (e) {
				this.httpobj = null;
			}

			return this.httpobj;
		};

		FileUploader.prototype.MultipartHeader = function () {
			this.httpobj.setRequestHeader("content-type", "multipart/form-data; boundary=" + FileUploader.boundary);
		};

		FileUploader.prototype.MultipartFooter = function () {
			return "--" + FileUploader.boundary + "--";
		};

		FileUploader.prototype.MultipartData = function (name, data) {
			var str = "--" + FileUploader.boundary + "\r\n";
			str += "Content-Disposition: form-data; name=\"" + name + "\"\r\n";
			str += "\r\n";
			str += data + "\r\n";
			return str;
		};

		FileUploader.prototype.MultipartFile = function (name, file) {
			var str = "--" + FileUploader.boundary + "\r\n";

			str += "Content-Disposition: form-data; name=\"" + name + "\"; filename=\"" + encodeURIComponent(file.name) + "\"\r\n";
			str += "Content-Type: " + file.type + "\r\n";
			str += "\r\n";
			str += this.reader.result + "\r\n";

			return str;
		};
		FileUploader.prototype.RandomString = function (n) {
			var a = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-!_#$'.split('');
			var s = '';
			for (var i = 0; i < n; i++) {
				s += a[Math.floor(Math.random() * a.length)];
			}
			return s;
		};
		FileUploader.boundary = "";
		return FileUploader;
	})();
	SteelBlue.FileUploader = FileUploader;

	var FileUploaderManagement = (function () {
		function FileUploaderManagement(id_area, id_loader, id_path) {
			this.darea = document.getElementById(id_area);
			this.larea = document.getElementById(id_loader);
			this.parea = document.getElementById(id_path);
			FileUploaderManagement.self = this;
			if (this.darea.addEventListener) {
				this.darea.addEventListener('dragover', function (event) {
					FileUploaderManagement.self.DragOver(event);
				}, false);
				this.darea.addEventListener('drop', function (event) {
					FileUploaderManagement.self.Drop(event);
				}, false);
			} else if (this.darea.attachEvent) {
				this.darea.attachEvent('ondragover', function (event) {
					FileUploaderManagement.self.DragOver(event);
				});
				this.darea.attachEvent('ondrop', function (event) {
					FileUploaderManagement.self.Drop(event);
				});
			}
			this.UPLOADED = 0;
			this.UPLOADMAX = 0;
		}
		FileUploaderManagement.prototype.DragOver = function (event) {
			event.preventDefault();
		};

		FileUploaderManagement.prototype.Drop = function (event) {
			event.preventDefault();

			this.files = event.dataTransfer.files;

			if (this.darea.addEventListener) {
				this.darea.addEventListener('dragover', null, false);
				this.darea.addEventListener('drop', null, false);
			} else if (this.darea.attachEvent) {
				this.darea.attachEvent('ondragover', null);
				this.darea.attachEvent('ondrop', null);
			}

			this.path = this.parea.value;

			this.larea.innerHTML = '<div id="loader" style="background-color:rgba(0,0,0,0.5);height:1em;"></div>';

			this.UPLOADED = 0;
			this.UPLOADMAX = this.files.length;

			var uf = new FileUploader();
			uf.UploadFile("./uploader.cgi", this.path, this.files[this.UPLOADED]);
			uf.SetCallback(function (msg) {
				FileUploaderManagement.self.NextUpload(msg);
			});
		};

		FileUploaderManagement.prototype.NextUpload = function (msg) {
			var result = JSON.parse(msg);

			// Update progress bar.
			var loader = document.getElementById('loader');

			var failid = '';
			if (result.result != 'success') {
				failid = ' class="error"';
			}

			loader.innerHTML += '<div style="width:' + (100 / this.UPLOADMAX) + '%;"' + failid + '></div>';

			++this.UPLOADED;

			if (this.UPLOADED < this.UPLOADMAX) {
				var uf = new FileUploader();
				uf.UploadFile("./uploader.cgi", this.path, this.files[this.UPLOADED]);
				uf.SetCallback(function (msg) {
					FileUploaderManagement.self.NextUpload(msg);
				});
			} else {
				//window.location.reload();
				this.larea.innerHTML = "Drag upload";
				var xhr = new XMLHttpRequest();
				xhr.open("GET", "/file.cgi?path=" + this.parea.value, true);
				xhr.onload = function (e) {
					if ( xhr.readyState === 4 && xhr.status === 200 ) {
						document.getElementById("filelist").innerHTML = xhr.responseText;
					}
				};
				xhr.send(null);
			}
		};
		return FileUploaderManagement;
	})();
	SteelBlue.FileUploaderManagement = FileUploaderManagement;
})(SteelBlue || (SteelBlue = {}));

function Init() {
	new SteelBlue.FileUploaderManagement('dragupload', 'dragupload', 'path');
}
