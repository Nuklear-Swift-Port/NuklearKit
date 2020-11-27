#include <metal_stdlib>
using namespace metal;
//#import "./NuklearShaderBridge.h"
#import <simd/simd.h>

typedef struct {
  matrix_float4x4 projectionMatrix;
} Uniforms;

struct NKVertexIn {
    float4 color [[attribute(0)]];
    float2 position [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct NKVertexOut {
    float4 position [[position]];
    float4 fragColor;
    float2 fragUV;
};

vertex NKVertexOut nk_vertex_main(const NKVertexIn nkVertexIn [[stage_in]],
                             constant Uniforms &uniforms [[buffer(1)]]) {
    NKVertexOut out {
        .position = uniforms.projectionMatrix * float4(nkVertexIn.position, 0, 1),
        .fragColor = nkVertexIn.color,
        .fragUV = nkVertexIn.uv
    };
    return out;
}

fragment float4 nk_fragment_main(const NKVertexOut vertexInput [[stage_in]],
                                 texture2d<float> baseColor [[texture(0)]],
                                 sampler textureSampler [[sampler(0)]]) {
    float3 sampledColor = baseColor.sample(textureSampler, vertexInput.fragUV).rgb;
    return vertexInput.fragColor * float4(sampledColor, 1.0);
}
