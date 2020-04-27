//
//  drawTest.metal
//  LTrace
//
//  Created by Luka Jankovic on 2020-04-26.
//  Copyright © 2020 Luka Jankovic. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

kernel void drawShade(constant int *width, constant int *height,
                      device int *framebuffer,
                      uint2 pos [[thread_position_in_grid]]) {
    int idx = ((pos.y * *width) + pos.x) * 3;
    
    framebuffer[idx] = static_cast<int>(255.99 * (static_cast<float>(pos.x) / static_cast<float>(*width)));
    framebuffer[idx + 1] = static_cast<int>(255.99 * (static_cast<float>(pos.y) / static_cast<float>(*height)));
    framebuffer[idx + 2] = static_cast<int>(255.59 * 0.2f);
}
