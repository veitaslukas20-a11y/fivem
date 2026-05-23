function Main(){
    return {
        top: false,
        bottom: false,
        keybings: [],
        text: '',
        loading: 0,
        copy: false,
        copyText: '',
        listen() {
            window.addEventListener('message', (event) => {
                let data = event.data
                if (data.action == 'top') {
                    this.top = data.top
                    this.text = data.text || ''
                }
                if (data.action == 'bottom') {
                    this.bottom = data.bottom
                    this.keybings = data.keybings || []
                }
                if (data.action == 'loading') {
                    this.loading = data.loading
                    this.persent = data.persent || 0
                }
            })
        },
    }
}