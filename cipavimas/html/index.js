function sliderUpdated(event,ui) {
}

function getSliderValues() {
	return {boost:$("#boost").slider("value"),fuelmix:$("#fuelmix").slider("value"),gearchange:$("#gearchange").slider("value"),braking:$("#braking").slider("value"),drivetrain:$("#drivetrain").slider("value"),brakeforce:$("#brakeforce").slider("value")};
}

function setSliderValues(values) {
	$(".slider").each(function(){
		if(values[this.id]!=null) {
			$(this).slider("value",values[this.id]);
		}
	});
	sliderUpdated();
}

function menuToggle(bool,send=false) {
	if(bool) {
		$("body").css("display", "block");
		$(".monitor-brand").css("top",$(".monitor").offset().top+$(".monitor").height()*1.075);
	} else {
		$("body").css("display", "none");
	}
	if(send){
		$.post('http://cipavimas/togglemenu', JSON.stringify({state:false}));
	}
}

$(function(){
	$("body").css("display", "none");
	$(".monitor-brand").css("top",$(".monitor").offset().top+$(".monitor").height()*1.075);
	$("#monitorBrand").text(Config.monitorBrand);
	$("#appName").text(Config.appName);
	$("#boost").slider({min:0.1,value:0.25,step:0.01,max:0.50,change:sliderUpdated});
	$("#fuelmix").slider({min:1,value:1.3,step:0.01,max:2,change:sliderUpdated});
	$("#gearchange").slider({min:1,value:9,max:50,change:sliderUpdated});
	$("#braking").slider({value:0.5,max:1,step:0.05,change:sliderUpdated});
	$("#drivetrain").slider({value:0.5,max:1,step:0.05,change:sliderUpdated});
	$("#brakeforce").slider({value:1.4,max:2,step:0.05,change:sliderUpdated});
	$("#defaultbtn").click(function(){setSliderValues({boost:0.25,fuelmix:1.3,gearchange:9,braking:0.5,drivetrain:0.5,brakeforce:1.4});});
	$("#sportbtn").click(function(){setSliderValues({boost:0.50,fuelmix:1.4,gearchange:25,braking:1,drivetrain:0.5,brakeforce:2});});
	$("#savebtn").click(function(){
		$.post('http://cipavimas/save', JSON.stringify(getSliderValues()));
	});
	$("#darktoggle").click(function(){
		$(this).toggleClass("fa");
		$(this).toggleClass("far");
		$(".monitor").toggleClass("mon-light-bg");
		$(".monitor").toggleClass("mon-dark-bg");
	});
	$("#exitProgram").click(function(){
		menuToggle(false,true);
	});
	$("#shutDown").click(function(){
		menuToggle(false,true);
	});
	setInterval(() => {
		var today = new Date();
		var days = ["Sekmadienis","Pirmadienis","Antradienis","Trečiadienis","Ketvirtadienis","Penktadienis","Šeštadienis"];
		var time = days[today.getDay()] + " " + today.getHours() + ":" + (today.getMinutes().toString().length==1 ? "0"+today.getMinutes() : today.getMinutes());
		$("#toptime").text(time);
	}, 1000);
	document.onkeyup = function (data) {
        if (data.which == 27) {
            menuToggle(false,true);
        }
    };
	window.addEventListener('message', function(event){
		if(event.data.type=="togglemenu") {
			menuToggle(event.data.state,false);
			if(event.data.data!=null) {
				setSliderValues(event.data.data);
			}
		}
	});
});