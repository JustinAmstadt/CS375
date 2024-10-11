/////////////////////////////////////////////////////////////////////////////
//
//  BasicCube.js
//
//  A cube defined of 12 triangles
//

class BasicCube {

    constructor(gl, vertexShader, fragmentShader) {
        vertexShader = `
            in vec4 aPosition;

            out vec3 fColor;

            uniform mat4 P;
            uniform mat4 MV;

            void main() {
                fColor = aPosition.xyz;
                gl_Position = P * MV * aPosition;
            }
        `;

        fragmentShader = `
            in vec3 fColor;

            out vec4 fragColor;

            void main()
            {
                fragColor = vec4(fColor, 1.0);
            } 
        `;

        let vertices = new Float32Array([
            // Top left front
            0.5, 0.5, 0.5,
            0.5, -0.5, 0.5,
            -0.5, 0.5, 0.5,

            // Bottom right front
            -0.5, -0.5, 0.5,
            -0.5, 0.5, 0.5,
            0.5, -0.5, 0.5,

            // Top left top
            0.5, 0.5, 0.5,
            -0.5, 0.5, -0.5,
            0.5, 0.5, -0.5,

            // Bottom right top
            0.5, 0.5, 0.5,
            -0.5, 0.5, 0.5,
            -0.5, 0.5, -0.5,

            // Top left bottom
            0.5, -0.5, 0.5,
            -0.5, -0.5, -0.5,
            0.5, -0.5, -0.5,

            // Bottom right bottom
            0.5, -0.5, 0.5,
            -0.5, -0.5, 0.5,
            -0.5, -0.5, -0.5,

            // Top left left
            0.5, -0.5, -0.5,
            0.5, 0.5, 0.5,
            0.5, 0.5, -0.5,

            // Bottom right left
            0.5, -0.5, -0.5,
            0.5, -0.5, 0.5,
            0.5, 0.5, 0.5,

            // Top left right
            -0.5, -0.5, 0.5,
            -0.5, 0.5, -0.5,
            -0.5, 0.5, 0.5,

            // Bottom right right
            -0.5, -0.5, 0.5,
            -0.5, -0.5, -0.5,
            -0.5, 0.5, -0.5,

            // Top left back
            -0.5, -0.5, -0.5,
            0.5, 0.5, -0.5,
            -0.5, 0.5, -0.5,

            // Bottom right back
            -0.5, -0.5, -0.5,
            0.5, -0.5, -0.5, 
            0.5, 0.5, -0.5
        ]);

        let program = new ShaderProgram(gl, this, vertexShader, fragmentShader);
        let posAttribute = new Attribute(gl, program, "aPosition", vertices, 3, gl.FLOAT, false, 0, 0);

        this.draw = () => {
            program.use();
            posAttribute.enable();

            gl.drawArrays(gl.TRIANGLES, 0, posAttribute.count);

            posAttribute.disable();
        };
    }
};