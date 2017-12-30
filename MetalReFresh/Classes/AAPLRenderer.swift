//
//  AAPLRenderer.swift
//  MetalGameOfLife
//
//  Created by nagatadaisuke on 2017/09/17.
//  Copyright © 2017年 nagatadaisuke. All rights reserved.
//

import UIKit
import MetalKit

struct ScreenAnimation {
    
    static var screenAnimation = Int()
}

class AAPLRenderer:NSObject,MTKViewDelegate {
    
    var mtkView : MTKView!
    var device : MTLDevice!
    var library : MTLLibrary!
    var commandQueue : MTLCommandQueue!
    var textureQueue : Array<MTLTexture?> = []
    var renderPipelineState : MTLRenderPipelineState!
    var simulationPipelineState : MTLComputePipelineState!
    var activationPipelineState : MTLComputePipelineState!
    var currentGameStateTexture : MTLTexture!
    var samplerState : MTLSamplerState!
    var vetexBuffer : MTLBuffer!
    var colorMap : MTLTexture!
    var gridSize : MTLSize!

    var activationPoints : Array<NSValue?> = []
    var nextResizeTimestamp = Date()
    var imageCount = Int()
    var pointSet = CGPoint()
    
    func instanceWithView(view:MTKView)
    {
        guard view.device != nil else {
            return
        }
        
        mtkView = view
        mtkView.delegate = self
        device = mtkView.device
        library = device.makeDefaultLibrary()
        commandQueue = device.makeCommandQueue()
        
        textureQueue.reserveCapacity(kTextureCount)
        
        buildRenderResources()
        buildRenderPipeline()
        buildComputePipelines()
        reshapeWithDrawableSize(drawableSize:mtkView.drawableSize)
        
    }
    
    func cGImageForImageNamed(image:UIImage)->CGImage
    {
        return image.cgImage!
    }
    
    func buildRenderResources()
    {
        
        guard ImageEntity.imageArray.count != 0 else {
            return
        }
        
        if ImageEntity.imageArray.count == 1 {
            imageCount = 0
        }
        // Use MTKTextureLoader to load a texture we will use to colorize the simulation
        let textureLoader  = MTKTextureLoader.init(device: device)

        let colorMapCGImage = cGImageForImageNamed(image: ImageEntity.imageArray[imageCount])
        
        do{
            colorMap = try textureLoader.newTexture(cgImage: colorMapCGImage, options: [:])
            
        }catch{}
        
        colorMap.label = "Color Map"
        var controlPointsBufferOptions = MTLResourceOptions()
        controlPointsBufferOptions = .storageModeShared
        
        let vertexData :  Array<Float> =  {
            [
               -1,  1,  0, 0,
               -1, -1,  0, 1,
                1, -1,  1, 1,
                1, -1,  1, 1,
                1,  1,  1, 0,
               -1,  1,  0, 0,
                
            ]
        }()
        
        // Full screen animation from 88
        vetexBuffer = device.makeBuffer(bytes: vertexData,
                                        length: MemoryLayout.size(ofValue: vertexData)*ScreenAnimation.screenAnimation,
                                        options: controlPointsBufferOptions)
        
        vetexBuffer.label = "Fullscreen Quad Vertices"
    }
    
    func buildRenderPipeline()
    {
        
        let vertexProgram = library.makeFunction(name: "lighting_vertex")
        let fragmentProgram = library.makeFunction(name: "lighting_fragment")
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float2
        vertexDescriptor.attributes[1].offset = 2*MemoryLayout.size(ofValue: Float())
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].format = MTLVertexFormat.float2
        vertexDescriptor.layouts[0].stride = 8*MemoryLayout.size(ofValue:  Float())
        vertexDescriptor.layouts[0].stepRate = 1
        vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction.perVertex
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Fullscreen Quad Pipeline"
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        do{
            renderPipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
        }catch{}
    }
    
    func buildComputePipelines()
    {
        commandQueue = device.makeCommandQueue()
        
        let descriptor = MTLComputePipelineDescriptor()
        descriptor.computeFunction = library.makeFunction(name: "game_of_life")
        descriptor.label = "Game of Life"
        do{
            simulationPipelineState = try device.makeComputePipelineState(descriptor: descriptor,
                                                                          options: MTLPipelineOption.bufferTypeInfo,
                                                                          reflection: nil)
        }catch{}
        
        descriptor.computeFunction = library.makeFunction(name: "activate_random_neighbors")
        descriptor.label = "Activate Random Neighbors"
        do{
            activationPipelineState = try device.makeComputePipelineState(descriptor: descriptor,
                                                                          options: MTLPipelineOption.bufferTypeInfo,
                                                                          reflection: nil)
        }catch{}
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = MTLSamplerAddressMode.clampToZero
        samplerDescriptor.tAddressMode = MTLSamplerAddressMode.clampToZero
        samplerDescriptor.minFilter = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.magFilter = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.normalizedCoordinates = true
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)
        
    }
    
    func reshapeWithDrawableSize(drawableSize:CGSize)
    {
        
        let scale = mtkView.layer.contentsScale
        let proposedGridSize = MTLSize(width: Int(drawableSize.width/scale), height: Int(drawableSize.height/scale), depth: 1)
        
        gridSize = proposedGridSize
        
        buildComputeResources()
        
    }
    
    func buildComputeResources()
    {
        textureQueue.removeAll()
        currentGameStateTexture = nil
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.r8Uint,
                                                                  width: gridSize.width,
                                                                  height: gridSize.height,
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead,.shaderWrite]
        
        for _ in 0...kTextureCount-1{
            let texture = device.makeTexture(descriptor: descriptor)
            texture?.label = "Game State"
            textureQueue.append(texture)
            
        }
        
        let randomGrid  = [(gridSize.width * gridSize.height)]
        
        let currentReadTexture = textureQueue.last
        currentReadTexture??.replace(region: MTLRegionMake2D(0, 0, 1, gridSize.height),
                                     mipmapLevel : 0,
                                     withBytes: randomGrid,
                                     bytesPerRow: gridSize.width)
        
    }
    
    //MARK: - Interactivity
    func activateRandomCellsInNeighborhoodOfCell(cell:CGPoint)
    {
        pointSet = cell
        activationPoints.append(NSValue(cgPoint: cell))
    }
    
    //MARK: - Render and Compute Encoding
    func encodeComputeWorkInBuffer(commandBuffer:MTLCommandBuffer)
    {
        
        let readTexture = textureQueue.first
        let writeTexture = textureQueue.last
        
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        
        //Returns the specified size of an object, such as a texture or threadgroup.
        let threadsPerThreadgroup = MTLSizeMake(3, 3, 1)
        let threadgroupCount = MTLSizeMake((gridSize.width/threadsPerThreadgroup.width), (gridSize.height/threadsPerThreadgroup.height), 1)
        
        commandEncoder?.setComputePipelineState(simulationPipelineState)
        commandEncoder?.setTexture(readTexture!, index: 0)
        commandEncoder?.setTexture(writeTexture!, index: 1)
        commandEncoder?.setSamplerState(samplerState, index: 0)
        commandEncoder?.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
        
        if activationPoints.count > 0 && Int(pointSet.x) != 0 {
            
            let byteCount = activationPoints.count * 1 * MemoryLayout.size(ofValue: 1)
            var cellPositions  = [(byteCount,byteCount)]
            
            for (_, byteCount) in activationPoints.enumerated() {
                
                var point = CGPoint()
                byteCount?.getValue(&point)
                
                cellPositions = [(Int(point.x),Int(point.y))]
                
            }
            
            let threadsPerThreadgroup = MTLSize(width: activationPoints.count,height: 1,depth: 1)
            let threadgroupCount = MTLSize(width:Int(pointSet.x),height: Int(pointSet.y),depth: 1)
            
            commandEncoder?.setComputePipelineState(activationPipelineState)
            commandEncoder?.setTexture(writeTexture!, index: 0)
            commandEncoder?.setBytes(cellPositions, length: byteCount, index: 0)
            commandEncoder?.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
            
            activationPoints.removeAll()
            
        }
        
        commandEncoder?.endEncoding()
        
        currentGameStateTexture = textureQueue.first!!
        textureQueue.remove(at: 0)
        textureQueue.append(currentGameStateTexture)
    }
    
    func encodeRenderWorkInBuffer(commandBuffer:MTLCommandBuffer)
    {
        let renderPassDescriptor = mtkView.currentRenderPassDescriptor
        
        if renderPassDescriptor != nil {
            
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
            
            renderEncoder?.setRenderPipelineState(renderPipelineState)
            renderEncoder?.setVertexBuffer(vetexBuffer, offset: 0, index: 0)
            renderEncoder?.setFragmentTexture(currentGameStateTexture, index: 0)
            renderEncoder?.setFragmentTexture(colorMap, index: 1)
            renderEncoder?.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 6)
            renderEncoder?.endEncoding()

            commandBuffer.present(mtkView.currentDrawable!.layer.nextDrawable()!)
            mtkView.releaseDrawables()
         
        }
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
    {
        self.reshapeWithDrawableSize(drawableSize: self.mtkView.drawableSize)
    }
    
    func draw(in view: MTKView)
    {

        Thread.sleep(forTimeInterval: 0.1)

        let commandBuffer = commandQueue.makeCommandBuffer()
     
        self.encodeComputeWorkInBuffer(commandBuffer: commandBuffer!)
        self.encodeRenderWorkInBuffer(commandBuffer: commandBuffer!)
        
        commandBuffer?.commit()
    }
}


