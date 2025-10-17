const webview = {
    create: () => {
        const webview = document.createElement('webview');
        document.querySelector('.contentarea').appendChild(webview);
        return webview;
    },
    loadURL: (url) => {
        if (!document.querySelector('.contentarea webview')) {
            webview.create();
        }
        document.querySelector('.contentarea webview').src = url;
    },
    reload: () => {
        document.querySelector('.contentarea webview').reload();
    },
    stop: () => {
        document.querySelector('.contentarea webview').stop();
    }
}