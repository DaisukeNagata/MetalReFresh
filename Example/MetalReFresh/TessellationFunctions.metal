/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Tessellation functions for MetalBasicTessellation.
            The compute kernel populates a per-patch tessellation factors buffer.
            The post-tessellation vertex function converts patch coordinates to display coordinates.
            The fragment function outputs a flat color for each vertex position.
 */

#include <metal_stdlib>
using namespace metal;

#pragma mark Structs

// Control Point struct
struct ControlPoint {
    float4 position [[attribute(0)]];
};

// Patch struct
struct PatchIn {
    patch_control_point<ControlPoint> control_points;
};

// Vertex-to-Fragment struct
struct FunctionOutIn {
    float4 position [[position]];
    half4  color [[flat]];
};

#pragma mark Compute Kernels

// Triangle compute kernel
kernel void tessellation_kernel_triangle(constant float& edge_factor [[ buffer(0) ]],
                                         constant float& inside_factor [[ buffer(1) ]],
                                         device MTLTriangleTessellationFactorsHalf* factors [[ buffer(2) ]],
                                         uint pid [[ thread_position_in_grid ]])
{
    // Simple passthrough operation
    // More sophisticated compute kernels might determine the tessellation factors based on the state of the scene (e.g. camera distance)
    factors[pid].edgeTessellationFactor[0] = edge_factor;
    factors[pid].edgeTessellationFactor[1] = edge_factor;
    factors[pid].edgeTessellationFactor[2] = edge_factor;
    factors[pid].insideTessellationFactor = inside_factor;
}

// Quad compute kernel
kernel void tessellation_kernel_quad(constant float& edge_factor [[ buffer(0) ]],
                                     constant float& inside_factor [[ buffer(1) ]],
                                     device MTLQuadTessellationFactorsHalf* factors [[ buffer(2) ]],
                                     uint pid [[ thread_position_in_grid ]])
{
    // Simple passthrough operation
    // More sophisticated compute kernels might determine the tessellation factors based on the state of the scene (e.g. camera distance)
    factors[pid].edgeTessellationFactor[0] = edge_factor;
    factors[pid].edgeTessellationFactor[1] = edge_factor;
    factors[pid].edgeTessellationFactor[2] = edge_factor;
    factors[pid].edgeTessellationFactor[3] = edge_factor;
    factors[pid].insideTessellationFactor[0] = inside_factor;
    factors[pid].insideTessellationFactor[1] = inside_factor;
}

#pragma mark Post-Tessellation Vertex Functions


// Quad post-tessellation vertex function
[[patch(quad, 4)]]
vertex FunctionOutIn tessellation_vertex_quad(PatchIn patchIn [[stage_in]],
                                              float2 patch_coord [[ position_in_patch ]])
{
    // Parameter coordinates
    float u = patch_coord.x;
    float v = patch_coord.y;
    
    // Linear interpolation
    float2 upper_middle = mix(patchIn.control_points[0].position.xy, patchIn.control_points[1].position.xy, u);
    float2 lower_middle = mix(patchIn.control_points[2].position.xy, patchIn.control_points[3].position.xy, 1-u);
    
    // Output
    FunctionOutIn vertexOut;
    vertexOut.position = float4(mix(upper_middle, lower_middle, v), 0.0, 0.8);
    //ChangeColor
    vertexOut.color = half4(u, v, 0.1-v, 0.1);
    return vertexOut;
}


#pragma mark Fragment Function

// Common fragment function
fragment half4 tessellation_fragment(FunctionOutIn fragmentIn [[stage_in]])
{
    return fragmentIn.color;
}
