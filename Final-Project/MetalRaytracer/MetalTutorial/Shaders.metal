#include <metal_stdlib>

using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertexShader(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0); // Pass position directly (can transform here if needed)
    out.texCoord = in.texCoord; // Pass texture coordinates
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                                texture2d<float, access::sample> texture [[texture(0)]]) {
    // Sample the texture
    float4 color = texture.sample(sampler(filter::linear), in.texCoord);
    // float4 color = float4(1.0, 0.2, 0.1, 1.0);
    return color;
}

kernel void computeShader(texture2d<float, access::write> outputTexture [[texture(0)]],
                          uint2 id [[thread_position_in_grid]]) {
    float2 uv = float2(id) / float2(outputTexture.get_width(), outputTexture.get_height());
    
    // Simple color gradient based on UV coordinates
    float3 color = float3(uv.x, uv.y, 1.0);
    
    outputTexture.write(float4(color, 1.0), id);
}
