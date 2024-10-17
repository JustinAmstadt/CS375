/////////////////////////////////////////////////////////////////////////////
//
//  ExperimentalCube.js
//
//  A cube defined ???
//

class ExperimentalCube {
    constructor(gl, vertexShader, fragmentShader) {
        vertexShader = `
            uniform mat4 P;
            uniform mat4 MV;

            void main() {
                int bitmap = 15637664;
                int bitmapShiftAmount = gl_VertexID * 3;

                vec4 newPos;
                newPos.x = ((bitmap & (1 << bitmapShiftAmount)) != 0) ? 0.5 : -0.5;
                newPos.y = ((bitmap & (1 << bitmapShiftAmount + 1)) != 0) ? 0.5 : -0.5;
                newPos.z = ((bitmap & (1 << bitmapShiftAmount + 2)) != 0) ? 0.5 : -0.5;
                newPos.w = 1.0;

                gl_Position = P * MV * newPos;
            }
        `;

        fragmentShader = `
            out vec4 fragColor;
            in vec4 vColor;

            void main()
            {
                const vec4 frontColor = vec4(0.0, 1.0, 0.0, 1.0);
                const vec4 backColor = vec4(1.0, 0.0, 0.0, 1.0);

                fragColor = gl_FrontFacing ? frontColor : backColor;
                // fragColor = vColor;
            } 
        `;
        
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
        let indicesBuffer = new Indices(gl, indices);

        this.draw = () => {
            program.use();

            indicesBuffer.enable()

            gl.drawElements(gl.TRIANGLES, indicesBuffer.count, indicesBuffer.type, 0);

            indicesBuffer.disable()
        };
    }
};