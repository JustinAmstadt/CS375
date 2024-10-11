/////////////////////////////////////////////////////////////////////////////
//
//  IndexedCube.js
//
//  A cube defined of 12 triangles using vertex indices.
//

class IndexedCube {
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
            // Front
            0.5, 0.5, 0.5, // Top left
            0.5, -0.5, 0.5, // Bottom left
            -0.5, 0.5, 0.5, // Top right
            -0.5, -0.5, 0.5, // Bottom right

            // Back
            0.5, 0.5, -0.5, // Top left
            0.5, -0.5, -0.5, // Bottom left
            -0.5, 0.5, -0.5, // Top right
            -0.5, -0.5, -0.5, // Bottom right
        ]);

        let indices = new Uint16Array([
            1, 2, 0, // Top left front
            1, 3, 2, // Bottom right front 
            0, 6, 4, // Top left top
            0, 2, 6, // Bottom right top
            1, 7, 5, // Top left bottom
            1, 3, 7, // Bottom right bottom
            5, 0, 4, // Top left left
            5, 1, 0, // Bottom right left
            3, 6, 2, // Top left right
            3, 7, 6, // Bottom right right
            7, 4, 6, // Top left back
            7, 5, 4 // Bottom right back
        ]);

        let program = new ShaderProgram(gl, this, vertexShader, fragmentShader);
        let posAttribute = new Attribute(gl, program, "aPosition", vertices, 3, gl.FLOAT, false, 0, 0);
        let indicesBuffer = new Indices(gl, indices);

        this.draw = () => {
            program.use();

            posAttribute.enable();
            indicesBuffer.enable()

            gl.drawElements(gl.TRIANGLES, indicesBuffer.count, indicesBuffer.type, 0);

            indicesBuffer.disable()
            posAttribute.disable();
        };
    }
};
