//
//  ray.metal
//  LTrace
//
//  Created by Luka Jankovic on 2020-04-25.
//  Copyright © 2020 Luka Jankovic. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

class ray {
public:
    float3 origin;
    float3 direction;
    
    float3 extend(float d) {
        return origin + (d * direction);
    }
};
