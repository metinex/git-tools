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
						   'top' : '0px', 'right' : '0px', 'background-color' : '#f1f1f1', 
						   'z-index' : '1000', 'opacity' : '0.93', 'padding' : '7px', 'min-height': '150px'
						});
			document.body.appendChild(cDiv);
			hDiv=document.createElement("div");
			hDiv.id = "coverageHeader";
			$(hDiv).css({ 'color': '#FFFFFF',
						  'background-color': 'rgb(66, 139, 202)',
						  'font-family' : 'Trocchi, Serif',
						  'font-size': '23px',
						  'font-weight' : 'normal',
						  'line-height' : '44px',
						  'margin': '0',
						  'position': 'absolute',
						  'right': '-80px',
						  'transform': 'rotate(270deg)',
						  'top': '124px',
						  'transform-origin': 'left top 0',
						  'border-top-left-radius': '20px',
						  'padding-left' : '7px',
						  'padding-right' : '7px'
						});						
			hDiv.innerHTML="CoverageJS";
			cDiv.appendChild(hDiv);		
			
			document.addEventListener('DOMContentLoaded', function () {
			  document.querySelector('button').addEventListener("click", coverage.downloadCSV);
			});
			var CSVButton = document.createElement("button");
			$(CSVButton).css({ 'position': 'absolute',
							 'right': '50px',
							 'top': '5px',
							 'border-color': 'rgb(66, 139, 202)'
						    });			
			CSVButton.id="coverageJSButton";
			CSVButton.innerHTML="Get CSV";
			cDiv.appendChild(CSVButton);
			$(CSVButton).on('click', coverage.downloadCSV);						
		}
		
		if ($(cDiv).find( '#' + fileID).length == 0) {
			var fileDiv = document.createElement("p");
			fileDiv.id = fileID;
			fileDiv.innerHTML="<div class='filename' style='font-weight:bold; font-style: italic; text-decoration: underline;'>" + fileName + "</div>";
			$(cDiv).append(fileDiv);
		}
		
		funcDiv=$(cDiv).find( '#' + fileID + ' #' + funcID);
		if ($(funcDiv).length == 0) {
			 $(cDiv).find( '#' + fileID).append("<div id='" + funcID + "' class='coverageFunction'><span id='funcName'>" + funcName + "</span>: <span id='count'>1</span> times.</div>");			 
		}
		else {
			var cSpan = $(funcDiv).find('#count');
			cSpan.text(parseInt(cSpan.text())+1);
			$(funcDiv).css({'color' : 'DarkRed', 'background-color' : 'rgb(48, 223, 206)'});
			$(hDiv).css('color' , 'DarkRed');
			setTimeout(function(){
							$(cDiv).find('.coverageFunction').css({'color' : 'Black', 'background' : 'none'});
							$(hDiv).css('color' , '#FFFFFF');
					   }, 2000);
		}
	}

 return {		
	logCallee: function () {
		var eArr = (new Error).stack.split("\n");
		var tempArr = eArr[2].replace("(", "").split(" ").slice(-2);
		var funcName = tempArr[0];
		var fileName = tempArr[1].split(":").slice(0,2).join(':').split('?')[0];		
		drawToScreen (fileName, funcName);	
	},
	
	downloadCSV: function () {
		var output = '"File Name";"Function Name";"Occurance"\n';
		$('#coverageDiv p').each (function (index, aFile){
			var fileName = $(aFile).find('.filename')[0].innerHTML;
			$(aFile).find('.coverageFunction').each (function (index, aFunction){
				output += '"' + fileName + '";"' + $(aFunction).find('#funcName')[0].innerHTML + '";"' + $(aFunction).find('#count')[0].innerHTML + '"\n';
			});
		});
		
		var pom = document.createElement('a');
		pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(output));
		pom.setAttribute('download', window.location.href.split('?')[0] + '.csv');
		pom.style.display = 'none';
		document.body.appendChild(pom);
		
		pom.click();

		document.body.removeChild(pom);			
	}		
 }
}();