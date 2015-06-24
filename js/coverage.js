//
// Usage: coverage.logCallee();
//
var coverage = function(){

	function drawToScreen(fileName, funcName){
		var cDiv = document.getElementById("coverage_div");
		var fileID = fileName.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
		var funcID = funcName.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
		
		if(!cDiv){
			cDiv = document.createElement("div");
			cDiv.id = "coverage_div";
			$(cDiv).css({  'width' : '500px', 'position' : 'absolute', 
						   'top' : '0px', 'right' : '0px', 'background-color' : 'rgb(158, 225, 74)', 
						   'z-index' : '1000', 'opacity' : '0.93', 'padding' : '7px'
						});
			document.body.appendChild(cDiv);
			document.body.appendChild(document.createElement("hr")); 		  
		}

		if ($(cDiv).find( '#' + fileID).length == 0) {
			var fileDiv = document.createElement("p");
			fileDiv.id = fileID;
			fileDiv.innerHTML="<div style='font-weight:bold;'>" + fileName + "</div>";
			$(cDiv).append(fileDiv);
		}
		
		if ($(cDiv).find( '#' + fileID + ' #' + funcID).length == 0) {
			 $(cDiv).find( '#' + fileID).append("<div id='" + funcID + "'>" + funcName + ": <span id='count'>1</span> times.</div>");			 
		}
		else {
			var cSpan = $(cDiv).find( '#' + fileID + ' #' + funcID + ' #count');
			cSpan.text(parseInt(cSpan.text())+1);
		}
	}

 return {		
	logCallee: function logCallee() {
		var eArr = (new Error).stack.split("\n");
		var tempArr = eArr[2].replace("(", "").split(" ").slice(-2);
		var funcName = tempArr[0];
		var fileName = tempArr[1].split(":").slice(0,2).join(':').split('?')[0];		
		drawToScreen (fileName, funcName);	
	}		
 }
}();