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

            uniform mat4 P;
            uniform mat4 MV;

            void main() {
                gl_Position = P * MV * aPosition;
            }
        `;

        fragmentShader = `
            out vec4 fragColor;

            void main()
            {
                const vec4 frontColor = vec4(0.0, 1.0, 1.0, 1.0);
                const vec4 backColor = vec4(1.0, 0.0, 0.0, 1.0);

                fragColor = gl_FrontFacing ? frontColor : backColor;
            } 
        `;

        let vertices = new Float32Array([
            // Front
            0.5, 0.5, 0.5, // Top right
            -0.5, 0.5, 0.5, // Top left
            0.5, -0.5, 0.5, // Bottom right
            -0.5, -0.5, 0.5, // Bottom left
        
            // Back
            0.5, 0.5, -0.5, // Top right
            -0.5, 0.5, -0.5, // Top left
            0.5, -0.5, -0.5, // Bottom right
            -0.5, -0.5, -0.5 // Bottom left
        ]);
        
        let indices = new Uint16Array([
            // Front face
            0, 1, 2,
            1, 3, 2,
        
            // Back face
            4, 6, 5,
            5, 6, 7,
        
            // Top face
            0, 4, 1,
            1, 4, 5,
        
            // Bottom face
            2, 3, 6,
            3, 7, 6,
        
            // Left face
            1, 5, 3,
            3, 5, 7,
        
            // Right face
            0, 2, 4,
            2, 6, 4 
        ]);
        
        let program = new ShaderProgram(gl, this, vertexShader, fragmentShader);
        let posAttribute = new Attribute(gl, program, "aPosition", vertices, 3, gl.FLOAT, false, 0, 0);
        let indicesBuffer = new Indices(gl, indices);

        this.draw = () => {
            program.use();

            posAttribute.enable();
            indicesBuffer.enable()

            gl.drawElements(gl.TRIANGLES, 3, indicesBuffer.type, 0);

            indicesBuffer.disable()
            posAttribute.disable();
        };
    }
};
