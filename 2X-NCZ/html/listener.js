$(window).on('load', () => {
	const $body = $('body');
	
	window.addEventListener('message', ({ data }) => {
			if (!data || data.type !== 'saugizona') return;

			if (data.enable) {
					$body.css('display', 'flex').removeClass('animate-slidedown');
			} else {
					$body.addClass('animate-slidedown');
					setTimeout(() => {
							$body.css('display', 'none');
					}, 400);
			}
	});
});