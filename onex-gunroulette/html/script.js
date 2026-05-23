var CD = {
	
	isPlay: false,
	isStop: false,
	
	anim: function(n)
	{
		setTimeout(function ()
		{				
			countdown.style.opacity = "1";
			countdown.style.fontSize = "5em";
			
			if (CD.isPlay == false) 
			{
				n++;
				countdown.innerText = n;
				countdown.style.top = "20%";
				countdown.style.color = "rgb(255,255,255)";
				CD.isPlay = true;
			}
			else if(CD.isStop == true)
			{
				countdown.style.top = "5%";
				countdown.style.opacity = "0";
				CD.isPlay = false;
				CD.isStop = false;
				return;
			}

			n--;
			if (n == 0)
			{
				countdown.style.color = "rgb(255,255,255)";

				countdown.innerText = "0";

				setTimeout(function (){
					countdown.style.top = "5%";
					countdown.style.opacity = "0";
					CD.isPlay = false;
				}, 1500)
				return;
			}
			else if (n < 3)
			{
				countdown.style.color = "rgb(255,255,255)";
			}
			countdown.innerText = n;			
			setTimeout(function ()
			{
				countdown.style.fontSize = "6em";
				countdown.style.opacity = "0";
				CD.anim(n);
			}, 500);
		},500);
	},
};

var audioPlayer = null;

window.addEventListener('message', (event) => 
{	

	if (event.data.transactionType == "playSound") {
	
		if (audioPlayer != null) {
		  audioPlayer.pause();
		}
		if (event.data.transactionFile != "thereisammo" && event.data.transactionFile != "thereisnotammo") {
		  console.log("Hmm, thats interesting, I cant play that sound. The name of the sound is: " + event.data.transactionFile);
		} else {
		audioPlayer = new Howl({src: [`${event.data.transactionFile}.ogg`]});
		audioPlayer.volume(0.5);
		audioPlayer.play();
		}
  
	} else {
	let num = event.data.text.replace(/^.{3}/, '');	
	
	if (CD.isPlay == true)
	{
		if (num == "stop")
		{
			CD.isStop = true;
			countdown.innerText = "stop";
			countdown.style.color = "rgb(255,255,255)";
			console.log("stop countdown");
		}
		else
		{
			console.log("the countdown is already running");
		}		
	}
	else if (Number.isInteger(parseInt(num, 10)))
	{
		CD.anim(num);		
	}
	else
	{
		console.log("Use a number");		
		}
	}

});