function show_help(){
	var iWidth = document.documentElement.clientWidth;
	var iHeight = document.documentElement.clientHeight;
	var ratio = 0.8;
	var half_width = iWidth * ratio / 2;
	var half_height = iHeight * ratio / 2;

	var bgObj = document.createElement("div");
	bgObj.setAttribute("id","bgbox");
	bgObj.style.width = iWidth+"px";
	bgObj.style.height =Math.max(document.body.clientHeight, iHeight)+ 35 + "px";
	document.body.appendChild(bgObj);

	var oShow = document.getElementById('show_help');
	oShow.style.display = 'block';
	oShow.style.width = iWidth * ratio + "px";
	oShow.style.height = iHeight * ratio + "px";
	oShow.style.left = iWidth/2-half_width+"px";
	oShow.style.top = iHeight/2-half_height+"px";

	var oClosebtn = document.createElement("span");
	oClosebtn.innerHTML = "X";
	oShow.appendChild(oClosebtn);
	
	var oPage = document.getElementById('help_page');
	oPage.style.height = iHeight * ratio - 39 + "px";

	function oClose(){
		oShow.style.display = 'none';
		oShow.removeChild(oClosebtn);
		document.body.removeChild(bgObj);
	}

	oClosebtn.onclick = oClose;
	bgObj.onclick = oClose;

	function getEvent() {
		return window.event || arguments.callee.caller.arguments[0];
	}

	document.onkeyup = function(){
		var event = getEvent();
		if (event.keyCode == 27){
			oClose();
		}
	}
}