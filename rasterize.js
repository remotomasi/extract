var page = require('webpage').create(),
    address, output, size;

if (phantom.args.length < 2 || phantom.args.length > 3) {
    console.log('Usage: rasterize.js URL filename');
    phantom.exit();
} else {
    address = phantom.args[0];
    output = phantom.args[1];
    page.viewportSize = { width: 1280, height: 1024 };
    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address!');
        } else {
            page.evaluate(function () {
                /* scale the whole body */
                document.body.style.webkitTransform = "scale(2)";
                document.body.style.webkitTransformOrigin = "0% 0%";
                /* fix the body width that overflows out of the viewport */
                document.body.style.width = "50%";
				document.body.bgColor = 'white';
            });
            window.setTimeout(function () {
                page.render(output);
                phantom.exit();
            }, 200);
        }
    });
}