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

float3 castRay(scene s, ray r, float attenuation) {
    if (attenuation > 0.1) {
        intersection a = s.intersectRay(r);
        if (a.hit) {
            float3 target = a.position + a.normal + s.randomUnitVec();
            if (!a.object->material.glow) {
                ray newTarget;
                newTarget.origin = a.position;
                newTarget.direction = target - a.position;
                
                return ((castRay(s, newTarget, attenuation / 2)) * a.object->material.diffuseColor) * attenuation;
            } else
                return a.object->material.diffuseGlow;
        } else
            return float3(0);
    }
    
    return float3(0);
}
