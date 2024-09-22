let gl = undefined;
let tetra = undefined;
let cylinder = undefined;
let cone = undefined;
let axes = undefined;
let sphere = undefined;
let ms = undefined;
let angle = 0.0;
let color = 0.0;
let factor = 1.0;

function clamp(value, minVal, maxVal) {
    return Math.max(minVal, Math.min(value, maxVal));
}

function init() {
    let canvas = document.getElementById("webgl-canvas");
    gl = canvas.getContext("webgl2");
    if (!gl) { alert("Your Web browser doesn't support WebGL 2\nPlease contact Dave"); }

    gl.viewport(0, 0, canvas.width, canvas.height);

    gl.clearColor(0.2, 0.2, 0.2, 1.0);
    gl.enable(gl.DEPTH_TEST);

    tetra = new Tetrahedron(gl);
    cylinder = new Cylinder(gl, 6);
    cone = new Cone(gl, 16);
    axes = new Axes(gl);
    sphere = new Sphere(gl, 100, 100);
    ms = new MatrixStack();

    render();
}

function render() {
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    angle += 3.0;
    angle %= 360.0 * 3.0;

    color += factor * 0.005;
    if (color >= 1.0 || color <= -1.0) factor = -factor;

    ms.push();
    ms.translate(0.7, -0.01, 0.0);
    ms.scale(1.0, 3.0, 1.0);
    ms.rotate(angle / 3.0, [1, 0, 1]);
    ms.translate(-0.1, 0.0, 0.1);
    ms.rotate(angle, [1, 1, 0]);
    ms.scale(0.07);
    tetra.color = vec4(clamp(color, 0, 1), clamp(-color, 0, 1), 1.0, 1.0);
    tetra.MV = ms.current();
    tetra.draw();
    ms.pop();

    let spin = (color + 1) / 2.0;

    ms.push();
    ms.rotate(angle / 3.0, [0, 0, 1]);
    ms.translate(spin / 4.0, 0.0, 0.0);
    ms.rotate(angle / 3.0, [0, 0, 1]);
    ms.scale(0.05);
    cylinder.color = vec4(clamp(-color / 2.0, 0, 1), clamp(-color, 0, 1), 0.2, 1.0);
    cylinder.MV = ms.current();
    cylinder.draw();
    ms.pop();

    ms.push();
    ms.rotate(angle / 3.0, [0, 1, 1]);
    ms.translate(-spin / 2.0, 0.0, 0.0);
    ms.rotate(angle / 3.0, [0, 0, 1]);
    ms.scale(0.05);
    cylinder.color = vec4(clamp(-color, 0, 1), clamp(-color, 0, 1), 1.0, 0.3);
    cylinder.MV = ms.current();
    cylinder.draw();
    ms.pop();

    let translateVal = color;

    ms.push();
    ms.translate(-0.7, translateVal * 0.7, 0.0);
    ms.rotate(angle, [0, 1, 1]);
    ms.scale(0.2);
    cone.color = vec4(0, clamp(color, 0, 1), 0.3, 1.0);
    cone.MV = ms.current();
    cone.draw();
    ms.pop();

    let size = (color + 1) / 20.0;

    ms.push();
    ms.translate(0.8, -0.8, 1.0);
    ms.scale(size);
    sphere.color = vec4(1.0, 0.0, 0.0, 1.0);
    sphere.MV = ms.current();
    sphere.draw();
    ms.pop();

    requestAnimationFrame(render);
}

window.onload = init;

