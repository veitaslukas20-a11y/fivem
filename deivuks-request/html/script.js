var style = document.createElement('style');
style.innerHTML = `
.box {
    display: block;
    position: absolute;
    top: 2vh;
    left: 70vh;
    min-width: 20vh;
    padding: 2vh 2vh;
    background-color: rgba(0, 0, 0, 0.555);
}

.box a {
    text-align: center;
    color: white;
    font-family: 'Roboto';
    font-weight: 400;
    font-size: 2vh;
}

.box bold {
    text-align: center;
    color: white;
    font-family: 'Roboto';
    font-weight: 600;
    font-size: 2vh;
}
`
document.head.appendChild(style);


function Main(){
    return {
        show: false,
        player: '',
        keybind: '',
        listen() {
            window.addEventListener('message', (event) => {
                let data = event.data
                if (data.show) {
                    this.show = true
                    this.player = data.player
                    this.keybind = '['+data.keybind+']'
                } else {
                    this.show = false
                }
            })
        },
    }
}