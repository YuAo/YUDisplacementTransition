//
//  YUDisplacementTransition.metal
//  Pods
//
//  Created by YuAo on 2019/1/5.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position [[ position ]];
    float2 textureCoordinate;
} MTIDefaultVertexOut;

float2x2 yuDisplacementTransitionGetRotationMatrix(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return float2x2(float2(c, -s), float2(s, c));
}

fragment float4 yuDisplacementTransitionFragmentShader(
                                                       MTIDefaultVertexOut vertexIn [[stage_in]],
                                                       texture2d<float, access::sample> sourceTexture [[texture(0)]],
                                                       sampler sourceSampler [[sampler(0)]],
                                                       texture2d<float, access::sample> targetTexture [[texture(1)]],
                                                       sampler targetSampler [[sampler(1)]],
                                                       texture2d<float, access::sample> displacementTexture [[texture(2)]],
                                                       sampler displacementSampler [[sampler(2)]],
                                                       constant float & progress [[buffer(0)]],
                                                       constant float & intensity [[buffer(1)]],
                                                       constant float & angleSource [[buffer(2)]],
                                                       constant float & angleTarget [[buffer(3)]]
                                                       )
{
    constexpr sampler s(coord::normalized, filter::linear, address::repeat);
    constexpr sampler i(coord::normalized, filter::linear, address::clamp_to_edge);
    float4 displacement = displacementTexture.sample(s, vertexIn.textureCoordinate);
    float2 displacementVec = displacement.rg;
    float2 distortedPosition1 = vertexIn.textureCoordinate + yuDisplacementTransitionGetRotationMatrix(angleSource) * displacementVec * intensity * progress;
    float2 distortedPosition2 = vertexIn.textureCoordinate + yuDisplacementTransitionGetRotationMatrix(angleTarget) * displacementVec * intensity * (1.0 - progress);
    float4 color1 = sourceTexture.sample(i, distortedPosition1);
    float4 color2 = targetTexture.sample(i, distortedPosition2);
    return mix(color1, color2, progress);
}
