//
//  main.swift
//  LTrace
//
//  Created by Luka Jankovic on 2020-04-26.
//  Copyright © 2020 Luka Jankovic. All rights reserved.
//

import Foundation
import Metal
import simd

// Used for "printing" to a flie (Credit: NSHipster)0
struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}

// Argument struct representations

struct material {
    var diffuseColor: simd_float3;
    var diffuseGlow:  simd_float3;
    
    var glow: CBool;
}

struct object {
    var material: material;
    var type: CInt;
    
    // General properties
    var origin: simd_float3;
    
    // Sphere specific properties
    var radius: CFloat;
    
    // Plane specific properties
    var normal: simd_float3;
}

struct scene {
    var objectsList: UnsafeMutablePointer<object>;
    var size: CInt;
}

struct test {
    var test_color: simd_float3;
}

// Constants
var width: CInt = 1000;
var height: CInt = 500;

let framebufferSize: Int = Int(width * height * 3);

// Find GPU device
let device: MTLDevice! = MTLCreateSystemDefaultDevice();

NSLog("Using default device: " + device.name);

// Initialize kernel code, queue, etc.
let defautlLibrary: MTLLibrary! = device.makeDefaultLibrary();
let kernelFunction: MTLFunction! = defautlLibrary.makeFunction(name: "render");

let mainQueue: MTLCommandQueue! = device.makeCommandQueue();
let pipelineState: MTLComputePipelineState! = try device.makeComputePipelineState(function: kernelFunction);

let cmdBuf: MTLCommandBuffer! = mainQueue.makeCommandBuffer();
let cmdEncoder: MTLComputeCommandEncoder! = cmdBuf.makeComputeCommandEncoder();

cmdEncoder.setComputePipelineState(pipelineState);

// Create scene
var mat = material(diffuseColor: simd_float3(1, 1, 1), diffuseGlow: simd_float3(0, 0, 0), glow: false);
var sphere = object(material: mat, type: 0, origin: simd_float3(1, 1, 1), radius: 1, normal: simd_float3(0, 0, 0));

var s = scene(objectsList: &sphere, size: 1);

// Test

var c = (0...framebufferSize).map{_ in simd_float3(1, 1, 0.5) };
var testBuf = device.makeBuffer(bytes:&c, length: Int(MemoryLayout<simd_float3>.stride * framebufferSize), options: []);

// End Test

// Copy data to device
/*let sceneBuf = device.makeBuffer(length: MemoryLayout<scene>.stride, options: []);
sceneBuf?.contents().;copyMemory(from: &s, byteCount: MemoryLayout<scene>.size);*/

let FBBuf = device.makeBuffer(length: Int(MemoryLayout<CInt>.stride * framebufferSize), options: [])!;

//cmdEncoder.setBuffer(sceneBuf, offset: 0, index: 0);
cmdEncoder.setBuffer(testBuf, offset: 0, index: 0);
cmdEncoder.setBytes(&width, length: MemoryLayout<CInt>.stride, index: 1);
cmdEncoder.setBytes(&height, length: MemoryLayout<CInt>.stride, index: 2);
cmdEncoder.setBuffer(FBBuf, offset: 0, index: 3);

let threadGridSize = MTLSize(width: Int(width), height: Int(height), depth: 1);
let threadGroupSize = MTLSize(width: pipelineState.threadExecutionWidth, height: 1, depth: 1);

cmdEncoder.dispatchThreads(threadGridSize, threadsPerThreadgroup: threadGroupSize);
cmdEncoder.endEncoding();

cmdBuf.commit();
cmdBuf.waitUntilCompleted();

let resPtr = FBBuf.contents().bindMemory(to: CInt.self, capacity: framebufferSize);
var framebuffer = Array(UnsafeBufferPointer<CInt>(start: resPtr, count: framebufferSize)).map{ String($0) };

let fileURL = URL(fileURLWithPath: "out.ppm");

var fm = FileManager.default;
fm.createFile(atPath: fileURL.path, contents: nil, attributes: nil);

let fileHandle = try FileHandle(forWritingTo: fileURL);
var output = FileHandlerOutputStream(fileHandle);

print("P3\n\(width) \(height)\n255", to:&output);

for i in stride(from: 0, to: framebufferSize as Int, by: 3) {
    print(framebuffer[i] + " " +
          framebuffer[i + 1] + " " +
          framebuffer[i + 2], to: &output);
}
