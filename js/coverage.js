//
// Usage: coverage.logCallee();
//
var coverage = function(){
	
	var isOpera = !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;
	var isFirefox = typeof InstallTrigger !== 'undefined';	
	var isChrome = !!window.chrome && !isOpera;
	var enableCoverage = true;
	
	function getCookie(cname) {
		var name = cname + "=";
		var ca = document.cookie.split(';');
		for(var i=0; i<ca.length; i++) {
			var c = ca[i];
			while (c.charAt(0)==' ') c = c.substring(1);
			if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
		}
		return "";
	}	
	
	function setCookie(cname,value) {
		var d = new Date();
		d.setTime(d.getTime() + (10*24*60*60*1000));
		document.cookie = cname + "=" + value + "; expires=" +d.toUTCString()+"; path=/";
		return "";
	}

	function drawToScreen(fileName, funcName,lineNum, info){
		var cDiv = document.getElementById("coverageDiv");
		var hDiv = document.getElementById("coverageHeader");
		var chDiv = document.getElementById("coverageHeaderCover");
		var outputDiv = document.getElementById("coverageOutput");
		var searchFilter = document.getElementById("searchFilter");
		var fileID = fileName.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
		var funcID = funcName.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/]/gi, '');
		
		if(!cDiv){
			cDiv = document.createElement("div");
			cDiv.id = "coverageDiv";
			$(cDiv).css({  'width' : '500px', 'position' : 'absolute', 
						   'top' : '0px', 'right' : '0px', 'background-color' : '#f1f1f1', 
						   'z-index' : '1000', 'opacity' : '0.93', 'padding' : '7px', 'min-height': '110px', 'border-bottom-left-radius' : '20px'
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
			
			chDiv=document.createElement("div");
			chDiv.id = "coverageHeaderCover";
			$(chDiv).css({'width' : '44px',
						  'height': '125px',
						  'margin': '0',
						  'position': 'absolute',
						  'right': '0',
						  'top': '0',
						  'border-top-left-radius': '20px'
						});				
			chDiv.style.cursor = "move";
			cDiv.appendChild(chDiv);		

			$(function() {
				$('body').on('mousedown', 'div#coverageHeaderCover', function() {
					$('div#coverageDiv').addClass('draggable').parents().on('mousemove', function(e) {
						$('.draggable').offset({
							top: e.pageY - 15,
							left: e.pageX - $('div#coverageDiv').outerWidth() + 25
						}).on('mouseup', function() {
							$('div#coverageDiv').removeClass('draggable');
						});
					});
				}).on('mouseup', function() {
					$('.draggable').removeClass('draggable');
				});
			});
			
			$( "div#coverageHeaderCover" ).dblclick(function() {
				if  ($('#coverageDiv').width()==500) {
					$('div#coverageOutput').css('display', "none");
					$('button#coverageJSButton').css('display', "none");
					$('input#searchFilter').css('display', "none");
					// Align from right to minimize to the right
					$('div#coverageDiv').css({ 'left' : '' , 'right': ($(window).width() - ($('div#coverageDiv').offset().left + $('div#coverageDiv').outerWidth())) + 'px'});
					$('div#coverageDiv').animate({width: '30px'});
					setCookie("coverageDisplay","none");
				} else {
					$('div#coverageOutput').css('display', "block");
					$('button#coverageJSButton').css('display', "block");
					$('input#searchFilter').css('display', "block");
					// Align from right to extent to the left
					$('div#coverageDiv').css({ 'left' : '' , 'right': ($(window).width() - ($('div#coverageDiv').offset().left + $('div#coverageDiv').outerWidth())) + 'px'});
					$('div#coverageDiv').animate({width: '500px'});
					// For a selection bug in Chrome
					document.getSelection().removeAllRanges();
					setCookie("coverageDisplay","block");
				}
			});
			
			searchFilter = document.createElement("input");
			searchFilter.type="text";
			searchFilter.id="searchFilter";
			searchFilter.value="Filter";
			$(searchFilter).css({ 'position': 'absolute',
							 'right': '50px',
							 'top': '30px',
							 'border': '1px solid rgb(66, 139, 202)',
							 'width': '75px',
							 'height': '17px',
							 'padding-left': '5px',
							 'color': 'gray',
							 'font-style': 'italic'
						    });	
			cDiv.appendChild(searchFilter);
			$(searchFilter).on('focus',function() {
				if ($(this).val()=='Filter') {
					$(this).val('');
					$(this).css({ 'color': 'black',
								   'font-style': 'normal' });	
				}								
			});		
			$(searchFilter).on('focusout',function() {
				if ($(this).val()=='') {
					$(this).val('Filter');
					$(this).css({ 'color': 'gray',
								   'font-style': 'italic' });	
				}								
			});	
			$(searchFilter).on('keyup', function() {
				var filterString = $(this).val();
				if (filterString.indexOf("file:") == 0) {
					filterString = filterString.split(':')[1];
					$(outputDiv).find("*").show();
					$(outputDiv).find('div.filename').each( function (index, obj){
						if (filterString == '')
							$(obj).parent().show();
						else if (obj.innerHTML.indexOf(filterString)>-1)
							$(obj).parent().show();
						else
							$(obj).parent().hide();										
					}); 
				} else	
					$(outputDiv).find('.coverageFunction span#funcName').each( function (index, obj){
						if (filterString=='') {
							$(obj).parent().parent().show();
							$(obj).parent().show();
						}	
						else if (obj.innerHTML.indexOf(filterString)>-1) {
							$(obj).parent().show();
							$(obj).parent().parent().show();
						}
						else {
							$(obj).parent().hide();					
							if($(obj).parent().parent().children(':visible').length == 1)
							   $(obj).parent().parent().hide();
						}
					});
			});	
			var CSVButton = document.createElement("button");
			$(CSVButton).css({ 'position': 'absolute',
							 'right': '50px',
							 'top': '5px',
							 'border': '1px solid rgb(66, 139, 202)',
							 'width': '82px'
						    });			
			CSVButton.id="coverageJSButton";
			CSVButton.innerHTML="Get CSV";
			cDiv.appendChild(CSVButton);
			$(CSVButton).on('click', coverage.downloadCSV);		

			outputDiv=document.createElement("div");
			outputDiv.id = "coverageOutput";			
			$(outputDiv).css({"word-wrap" : "break-word"});			
			cDiv.appendChild(outputDiv);

			if ( getCookie("coverageDisplay") == "none")			
				$(chDiv).trigger("dblclick");			
		}
		
		if ($(outputDiv).find( '#' + fileID).length == 0) {
			var fileDiv = document.createElement("p");
			fileDiv.id = fileID;
			fileDiv.innerHTML="<div class='filename' style='font-weight:bold; font-style: italic; text-decoration: underline;'>" + fileName + "</div>";
			$(outputDiv).append(fileDiv);
		}
		
		funcDiv=$(outputDiv).find( '#' + fileID + ' #' + funcID);
		if ($(funcDiv).length == 0) {
			if (info) {
				info = "<a onclick=\"coverage.toggleInfo('#" + fileID + " #" + funcID + "');\" style='color:rgb(69, 143, 189);font-weight:bold;'> &#8594;</a><div id='cInfoDiv' style='margin-left:15px;color:rgb(70, 143, 190);border-left: 2px rgb(69, 143, 189) solid;padding-left: 5px;display: none;'>(<span id='info'>"+info+"</span>)</div>";
			}
			else
				info="";
			$(outputDiv).find( '#' + fileID).append("<div id='" + funcID + "' class='coverageFunction'><span id='funcName'>" + funcName + "</span> (<span id='funcLine'>"+lineNum+"</span>): <span id='count'>1</span> times."+ info +"</div>");
			// Hide filter excluded divs
			if ($(searchFilter).val()!="" && $(searchFilter).val()!="Filter")
				$(searchFilter).trigger("keyup");
		}
		else {
			var cSpan = $(funcDiv).find('#count');
			cSpan.text(parseInt(cSpan.text())+1);
			if (info) {
 				iSpan = $(funcDiv).find('#info');
				if (iSpan.length>0)
					$(iSpan)[0].innerHTML += ", "+info;
				else
					$(funcDiv).find('#count').appendChild("<a onclick=\"$('#"+funcID+" #cInfoDiv').slideToggle('fast');\" style='color:rgb(69, 143, 189);font-weight:bold;'> &#8594;</a><div id='cInfoDiv' style='margin-left:15px;color:rgb(70, 143, 190);border-left: 2px rgb(69, 143, 189) solid;padding-left: 5px;display: none;'>(<span id='info'>"+info+"</span>)</div>");
			}
			$(funcDiv).css({'color' : 'DarkRed', 'background-color' : 'rgb(48, 223, 206)'});
			$(hDiv).css('color' , 'DarkRed');
			setTimeout(function(){
							$(outputDiv).find('.coverageFunction').css({'color' : 'Black', 'background' : 'none'});
							$(hDiv).css('color' , '#FFFFFF');
					   }, 2000);
		}
	}

 return {		
	logCallee: function (info) {
		if (!enableCoverage)
			return;
			
		var eArr = (new Error).stack.split("\n");
		var tempArr;
		if (isChrome) {
			tempArr = eArr[2].replace("(", "").split(" ").slice(-2);	
		} else if (isFirefox) {
			tempArr = eArr[1].split("@");
		} else
			return;
		
		// Remove different demonstration styles from function names
		var funcName = tempArr[0].replace(/^Object./gm,'').replace(/^HTMLDocument./gm,'').replace(/^HTMLHtmlElement./gm,'').replace('<.','.');
		var fileName = '/' + tempArr[1].split(":").slice(0,2).join(':').split('?')[0].split('/').slice(3).join('/');
		var lineNum = parseInt(tempArr[1].split(":")[2]-1);
		if (fileName && funcName && lineNum)
			drawToScreen (fileName, funcName,lineNum, info);	
	},
	
	downloadCSV: function () {
		var output = '"File Name";"Function Name";"Line";"Occurance"\n';
		$('#coverageOutput p').filter(':visible').each (function (index, aFile){
			var fileName = $(aFile).find('.filename')[0].innerHTML;
			$(aFile).find('.coverageFunction').filter(':visible').each (function (index, aFunction){
				output += '"' + fileName + '";"' + $(aFunction).find('#funcName')[0].innerHTML + '";"' + $(aFunction).find('#funcLine')[0].innerHTML + '";"' + $(aFunction).find('#count')[0].innerHTML + '"\n';
			});
		});
		
		var pom = document.createElement('a');
		pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(output));
		pom.setAttribute('download', window.location.href.split('?')[0] + '.csv');
		pom.style.display = 'none';
		document.body.appendChild(pom);
		
		pom.click();

		document.body.removeChild(pom);			
	},
	
	toggleInfo: function (funcID){
		$(funcID+' #cInfoDiv').slideToggle('fast');
		var indicator = $(funcID+' a')[0];
		if (indicator.innerHTML == " →")
			indicator.innerHTML = " ↓";
		else if (indicator.innerHTML == " ↓")
			indicator.innerHTML = " →";
	}
 }
}();