const wv = {
    add: () => {
        document.querySelector('.contentarea').innerHTML = '';
        const wv = document.createElement('webview');
        document.querySelector('.contentarea').appendChild(wv);
        return wv;
    },
    url: (url) => {
        if (!document.querySelector('.contentarea webview')) {
            wv.add();
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