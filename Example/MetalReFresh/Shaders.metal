/*
Copyright (C) 2016 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
Shader functions for the Game of Life sample. Define the core of the GPU-based simulation
    and describe how to draw the current game state to the screen
*/

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Set of vectors to the eight neighbors of a grid cell
constant float2 kNeighborDirections[] =
{
    float2(-1, -1), float2(-1, 0), float2(-1, 1),
    float2( 0, -1), /*  center  */ float2( 0, 1),
    float2( 1, -1), float2( 1, 0), float2( 1, 1),
};

// Likelihood that a random cell will become alive when interaction happens at an adjacent cell
constant float kSpawnProbability = 0.444;

// Values that represent "aliveness" and "maximum deadness"
constant int kCellValueAlive = 0;
constant int kCellValueDead = 255;

typedef struct
{
    packed_float2 position;
    packed_float2 texCoords;
} VertexIn;

typedef struct {
    float4 position [[position]];
    float2 texCoords;
} FragmentVertex;

vertex FragmentVertex lighting_vertex(device VertexIn *vertexArray [[buffer(0)]],
                                      uint vertexIndex [[vertex_id]])
{
    FragmentVertex out;
    out.position = float4(vertexArray[vertexIndex].position, 0, 1);
    out.texCoords = vertexArray[vertexIndex].texCoords;
    return out;
}

fragment half4 lighting_fragment(FragmentVertex in [[stage_in]],
                                 texture2d<uint, access::sample> gameGrid [[texture(0)]],
                                 texture2d<half, access::sample> colorMap [[texture(1)]])
{
    // We sample the game grid to get the value of a cell. The cell is alive
    // if its value is exactly 0; otherwise the value represents the number
    // of simulation steps the cell has been dead. We normalize this to between 0 and 1.
    constexpr sampler nearestSampler(coord::normalized, filter::nearest);
    float deadTime = gameGrid.sample(nearestSampler, in.texCoords).r / 255.0;
    
    // In order to color the simulation, we map the aliveness of a cell onto
    // a color with a 1D texture that contains a gradient.
    half4 color = colorMap.sample(nearestSampler, float2(deadTime, 0));
    return color;
}

/// This utility function transforms a 2D integral vector into a random-looking
/// number between 0 and 1 with roughly uniform distribution
static float hash(int2 v){
    return fract(sin(dot(float2(v), float2(12.9898, 78.233))) * 43758.5453);
}

kernel void activate_random_neighbors(texture2d<uint, access::write> writeTexture [[texture(0)]],
                                      constant uint2 *cellPositions [[buffer(0)]],
                                      ushort2 gridPosition [[thread_position_in_grid]])
{
    // Iterate over the eight neighbors of this grid cell, quasi-randomly setting each neighbor
    // to either alive or maximally dead
    for (ushort i = 0; i < 8; ++i)
    {
        int2 neighborPosition = int2(cellPositions[gridPosition.x]) + int2(kNeighborDirections[i]);
        ushort cellValue = hash(neighborPosition) < kSpawnProbability ? kCellValueAlive : kCellValueDead;
        writeTexture.write(cellValue, uint2(neighborPosition));
    }
}

/// This kernel function runs one step of a Game of Life simulation, reading
/// the previous game state from one texture, and writing the updated state
/// into another texture
kernel void game_of_life(texture2d<uint, access::sample> readTexture [[texture(0)]],
                         texture2d<uint, access::write> writeTexture [[texture(1)]],
                         sampler wrapSampler [[sampler(0)]],
                         ushort2 gridPosition [[thread_position_in_grid]])
{
    ushort width = readTexture.get_width();
    ushort height = readTexture.get_height();
    float2 bounds(width, height);
    float2 position = float2(gridPosition);
    
    // Don't perform the update or the write if we would be going out of bounds of the grid
    if (gridPosition.x < width && gridPosition.y < height)
    {
        // Count up the number of neighbors of this cell that are alive
        ushort neighbors = 0;
        for (int i = 0; i < 8; ++i)
        {
            // Sample from the current game state texture, wrapping around edges if necessary
            float2 coords = (position + kNeighborDirections[i] + float2(0.5)) / bounds;
            ushort cellValue = readTexture.sample(wrapSampler, coords).r;
            neighbors += (cellValue == kCellValueAlive) ? 1 : 0;
        }

        // Determine if this cell is itself alive
        ushort deadFrames = readTexture.read(uint2(position)).r;
        
        /*
            The rules of the Game of Life:
              Any live cell with fewer than two live neighbours dies, as if caused by under-population.
              Any live cell with two or three live neighbours lives on to the next generation.
              Any live cell with more than three live neighbours dies, as if by over-population.
              Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
         */
        bool alive = (deadFrames == 0 && (neighbors == 2 || neighbors == 3)) || (deadFrames > 0 && (neighbors == 3));
        
        // If we are alive, keep our value at 0; otherwise increment the number of frames we've been dead
        ushort cellValue = alive ? kCellValueAlive : deadFrames + 1;
        
        // Finally, write the new "aliveness" of this cell into the next game state texture
        writeTexture.write(cellValue, uint2(position));
    }
}
