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
                const vec4 frontColor = vec4(0.0, 1.0, 0.0, 1.0);
                const vec4 backColor = vec4(1.0, 0.0, 0.0, 1.0);

                fragColor = gl_FrontFacing ? frontColor : backColor;
            } 
        `;

        let vertices = new Float32Array([
            // Front face
            0.5, 0.5, 0.5,
            -0.5, 0.5, 0.5,
            -0.5, -0.5, 0.5,
        
            0.5, 0.5, 0.5,
            -0.5, -0.5, 0.5,
            0.5, -0.5, 0.5,
        
            // Top face
            0.5, 0.5, 0.5,
            0.5, 0.5, -0.5,
            -0.5, 0.5, -0.5,
        
            0.5, 0.5, 0.5,
            -0.5, 0.5, -0.5,
            -0.5, 0.5, 0.5,
        
            // Bottom face
            0.5, -0.5, 0.5,
            -0.5, -0.5, -0.5,
            0.5, -0.5, -0.5,
        
            0.5, -0.5, 0.5,
            -0.5, -0.5, 0.5,
            -0.5, -0.5, -0.5,
        
            // Left face
            -0.5, 0.5, 0.5,
            -0.5, 0.5, -0.5,
            -0.5, -0.5, -0.5,
        
            -0.5, 0.5, 0.5,
            -0.5, -0.5, -0.5,
            -0.5, -0.5, 0.5,
        
            // Right face
            0.5, 0.5, 0.5,
            0.5, -0.5, 0.5,
            0.5, -0.5, -0.5,
        
            0.5, 0.5, 0.5,
            0.5, -0.5, -0.5,
            0.5, 0.5, -0.5,
        
            // Back face
            -0.5, 0.5, -0.5,
            0.5, 0.5, -0.5,
            0.5, -0.5, -0.5,
        
            -0.5, 0.5, -0.5,
            0.5, -0.5, -0.5,
            -0.5, -0.5, -0.5
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