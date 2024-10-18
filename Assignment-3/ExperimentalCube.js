/////////////////////////////////////////////////////////////////////////////
//
//  ExperimentalCube.js
//
//  A cube defined ???
//

class ExperimentalCube {
    constructor(gl, vertexShader, fragmentShader) {
        vertexShader = `
            uniform int indexBitmaps[12];

            uniform mat4 P;
            uniform mat4 MV;

            out vec4 vColor;

            void main() {
                // Shift to the right by a certain amount and then do a mask to find each value
                int index = (indexBitmaps[gl_InstanceID] >> (gl_VertexID * 4)) & 0xF;

                int bitmap = 15637664;
                int bitmapShiftAmount = index * 3;

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
        
        let indexBitmapArray = new Int16Array([
            // Front face
            (2 << 8) | (1 << 4) | 0,
            (2 << 8) | (3 << 4) | 1,

            // Back face
            (5 << 8) | (6 << 4) | 4,
            (7 << 8) | (6 << 4) | 5,

            // Top face
            (1 << 8) | (4 << 4) | 0,
            (5 << 8) | (4 << 4) | 1,
        
            // Bottom face
            (6 << 8) | (3 << 4) | 2,
            (6 << 8) | (7 << 4) | 3,
        
            // Left face
            (3 << 8) | (5 << 4) | 1,
            (7 << 8) | (5 << 4) | 3,
        
            // Right face
            (4 << 8) | (2 << 4) | 0,
            (4 << 8) | (6 << 4) | 2,
        ]);
        
        let program = new ShaderProgram(gl, this, vertexShader, fragmentShader);
        const uniformLocation = gl.getUniformLocation(program.program, 'indexBitmaps');

        this.draw = () => {
            program.use();

            gl.uniform1iv(uniformLocation, indexBitmapArray);

            gl.drawArraysInstanced(gl.TRIANGLES, 0, 3, indexBitmapArray.length);
        };
    }
};