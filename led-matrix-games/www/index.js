var ws, i, buttons, address = 'ws://192.168.0.1:37890';
navigator.vibrate = navigator.vibrate ||
                  navigator.webkitVibrate ||
                  navigator.mozVibrate || 
                  navigator.msVibrate;
				  
//address = 'ws:/localhost:37890';

window.addEventListener('resize', updateButtons);

function updateButtons() {
    var buttonSize, buttons, i, offset = 40;

    if (window.innerWidth > window.innerHeight) {
        buttonSize = window.innerWidth / 8;
    } else {
        buttonSize = window.innerHeight / 5;
    }

    buttons = document.querySelectorAll('.round-button');
    for (i = 0; i < buttons.length; i++) {
        buttons[i].style.width = buttonSize + 'px';
        buttons[i].style.height = buttonSize + 'px';
        buttons[i].style.fontSize = (buttonSize / 2) + 'px';
        buttons[i].style.lineHeight = buttonSize + 'px';
    }

    // up button
    buttons[0].style.left = (buttonSize + offset) + 'px';
    buttons[0].style.top = (window.innerHeight / 2 - 1.6 * buttonSize) + 'px';

    // down button
    buttons[1].style.left = (buttonSize + offset) + 'px';
    buttons[1].style.bottom = (window.innerHeight / 2 - 1.6 * buttonSize) + 'px';

    // left button
    buttons[2].style.left = (offset) + 'px';
    buttons[2].style.top = (window.innerHeight / 2 - buttonSize / 2) + 'px';

    // rigth button
    buttons[3].style.left = (offset + 2 * buttonSize) + 'px';
    buttons[3].style.top = (window.innerHeight / 2 - buttonSize / 2) + 'px';

    // A button
    buttons[4].style.right = (offset + 2 * buttonSize) + 'px';
    buttons[4].style.top = (window.innerHeight / 2 - buttonSize / 2) + 'px';

    // B button
    buttons[5].style.right = (offset + 0.5 * buttonSize) + 'px';
    buttons[5].style.top = (window.innerHeight / 2 - buttonSize / 2) + 'px';
}

function vibrate() {
	if (navigator.vibrate) {
		navigator.vibrate(50);
	}
}

function createWs(onOpened) {
    ws = new WebSocket(address);

    ws.onerror = function () {
        console.log(arguments);
        ws = null;
		document.body.style.backgroundColor = 'red';
    };

    ws.onclose = function () {
        console.log(arguments);
        ws = null;
    };

    ws.onopen = function () {
		document.body.style.backgroundColor = 'lightgreen';
        if (onOpened) {
            onOpened();
        }
    };
}

function sendKey(key) {
    if (!key) {
        return;
    }

    if (!ws) {
        createWs(function () {
            ws.send(key);
        });
    } else {
        ws.send(key);
    }
}

buttons = document.querySelectorAll('.round-button');
for (i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener('click', function (event) {
		vibrate();
        sendKey(event.target.id);
    });
    buttons[i].addEventListener('touchstart', function (event) {
		vibrate();
		sendKey(event.target.id);
		event.stopPropagation();
		event.preventDefault();
    }, false);
}

document.addEventListener('keydown', function (e) {
    var button = null;
    switch (e.which) {
        case 37: // left
            button = 'left';
            break;
        case 38: // up
            button = 'up';
            break;
        case 39: // right
            button = 'right';
            break;
        case 40: // down
            button = 'down';
            break;
        case 65: // a
            button = 'a';
            break;
        case 66: // b
            button = 'b';
            break;
        default:
            return; // exit this handler for other keys
    }
    e.preventDefault(); // prevent the default action (scroll / move caret)
    sendKey(button);
});

updateButtons();
