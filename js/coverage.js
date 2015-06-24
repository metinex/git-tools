//
// Usage: coverage.logCallee();
//
var coverage = function(){

	function drawToScreen(fileName, funcName){
		var cDiv = document.getElementById("coverageDiv");
		var hDiv = document.getElementById("coverageHeader");
		var fileID = fileName.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
		var funcID = funcName.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
		
		if(!cDiv){
			cDiv = document.createElement("div");
			cDiv.id = "coverageDiv";
			$(cDiv).css({  'width' : '500px', 'position' : 'absolute', 
						   'top' : '0px', 'right' : '0px', 'background-color' : 'rgb(158, 225, 74)', 
						   'z-index' : '1000', 'opacity' : '0.93', 'padding' : '7px'
						});
			document.body.appendChild(cDiv);
			hDiv=document.createElement("div");
			hDiv.id = "coverageHeader";
			$(hDiv).css({ 'color': '#7c795d',
						  'font-family' : 'Trocchi, Serif',
						  'font-size': '25px',
						  'font-weight' : 'normal',
						  'line-height' : '48px',
						  'margin': '0',
						  'position': 'absolute',
						  'right': '-80px',
						  'transform': 'rotate(270deg)',
						  'top': '120px',
						  'transform-origin': 'left top 0'
						});						
			hDiv.innerHTML="CoverageJS";
			cDiv.appendChild(hDiv);			
		}
		
		if ($(cDiv).find( '#' + fileID).length == 0) {
			var fileDiv = document.createElement("p");
			fileDiv.id = fileID;
			fileDiv.innerHTML="<div style='font-weight:bold;'>" + fileName + "</div>";
			$(cDiv).append(fileDiv);
		}
		
		funcDiv=$(cDiv).find( '#' + fileID + ' #' + funcID);
		if ($(funcDiv).length == 0) {
			 $(cDiv).find( '#' + fileID).append("<div id='" + funcID + "' class='coverageFunction'>" + funcName + ": <span id='count'>1</span> times.</div>");			 
		}
		else {
			var cSpan = $(funcDiv).find('#count');
			cSpan.text(parseInt(cSpan.text())+1);
			$(funcDiv).css({'color' : 'DarkRed', 'background-color' : 'rgb(48, 223, 206)'});
			$(hDiv).css('color' , 'DarkRed');
			setTimeout(function(){
							$(cDiv).find('.coverageFunction').css({'color' : 'Black', 'background' : 'none'});
							$(hDiv).css('color' , '#7c795d');
					   }, 2000);
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