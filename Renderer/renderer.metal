//
//  renderer.metal
//  LTrace
//
//  Created by Luka Jankovic on 2020-04-26.
//  Copyright © 2020 Luka Jankovic. All rights reserved.
//

#include <metal_stdlib>

#include "scene.metal"

using namespace metal;

struct test {
    float3 test_color;
};

float3 castRay(scene s, ray r, float attenuation) {
    if (attenuation > 0.1) {
        intersection a = s.intersectRay(r);
        if (a.hit) {
            float3 target = a.position + a.normal + s.randomUnitVec();
            if (!a.object.material.glow) {
                ray newTarget;
                newTarget.origin = a.position;
                newTarget.direction = target - a.position;
                
                return ((castRay(s, newTarget, attenuation / 2)) * a.object.material.diffuseColor) * attenuation;
            } else
                return a.object.material.diffuseGlow;
        } else
            return float3(0);
    }
    
    return float3(0);
}

kernel void render(constant test *t, constant int *width, constant int *height,
                   device int *framebuffer,
                   uint2 pos [[thread_position_in_grid]]) {
    
    int idx = ((pos.y * *width) + pos.x) * 3;
    
    test in = *t;
    
    framebuffer[idx] = static_cast<int>(255.59 * in.test_color[0]);
    framebuffer[idx + 1] = static_cast<int>(255.59 * in.test_color[1]);
    framebuffer[idx + 2] = static_cast<int>(255.59 * in.test_color[2]);
    
    /*Loki rng = Loki(1, 2, 3);
    scene scene = *s;
    
    float u = (2.f * (pos.x + rng.rand()) - *width) / *height;
    float v = (-2.f * (pos.y + rng.rand()) + *height) / *height;
    
    ray currentRay;
    currentRay.origin = float3(0);
    currentRay.direction = float3(u, v, 1);
    
    float3 res;
    //float attenuation = 1.f;
    
    intersection a = scene.intersectRay(currentRay);
    
    if (a.hit) {
        res = float3(0);
    } else {
        res = float3(1);
    }
    
    int idx = ((pos.y * *width) + pos.x) * 3;
    
    framebuffer[idx] = static_cast<int>(255.59 * res[0]);
    framebuffer[idx + 1] = static_cast<int>(255.59 * res[1]);
    framebuffer[idx + 2] = static_cast<int>(255.59 * res[2]);
    
    /*do {
        intersection a = scene.intersectRay(currentRay);
        
        if (a.hit) {
            float3 target = a.position + a.normal + scene.randomUnitVec();
            
            if (!a.object.material.glow) {
                ray newTarget;
                newTarget.origin = a.position;
                newTarget.direction = target - a.position;
                
                currentRay = newTarget;
                attenuation /= 2;
            } else {
                res = a.object.material.diffuseGlow;
                attenuation = 0.f;
            }
        } else {
            res = float3(0);
            attenuation = 0.f;
        }
    } while(attenuation > 0.1f);*/
}
