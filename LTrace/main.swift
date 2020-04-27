//
//  main.swift
//  LTrace
//
//  Created by Luka Jankovic on 2020-04-26.
//  Copyright © 2020 Luka Jankovic. All rights reserved.
//

import Foundation
import Metal

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

// Constants
var width: CInt = 200;
var height: CInt = 100;

let framebufferSize: Int = Int(width * height * 3);

// Find GPU device
let device: MTLDevice! = MTLCreateSystemDefaultDevice();

NSLog("Using default device: " + device.name);

// Initialize kernel code, queue, etc.
let defautlLibrary: MTLLibrary! = device.makeDefaultLibrary();
let kernelFunction: MTLFunction! = defautlLibrary.makeFunction(name: "drawShade");

let mainQueue: MTLCommandQueue! = device.makeCommandQueue();
let pipelineState: MTLComputePipelineState! = try device.makeComputePipelineState(function: kernelFunction);

let cmdBuf: MTLCommandBuffer! = mainQueue.makeCommandBuffer();
let cmdEncoder: MTLComputeCommandEncoder! = cmdBuf.makeComputeCommandEncoder();

cmdEncoder.setComputePipelineState(pipelineState);

// Copy data to device
let FBBuf = device.makeBuffer(length: Int(MemoryLayout<CInt>.stride * framebufferSize), options: [])!;

cmdEncoder.setBytes(&width, length: MemoryLayout<CInt>.stride, index: 0)
cmdEncoder.setBytes(&height, length: MemoryLayout<CInt>.stride, index: 1);
cmdEncoder.setBuffer(FBBuf, offset: 0, index: 2)

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
