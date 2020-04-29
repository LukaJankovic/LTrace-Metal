//
//  scene.metal
//  LTrace
//
//  Created by Luka Jankovic on 2020-04-26.
//  Copyright © 2020 Luka Jankovic. All rights reserved.
//

#include <metal_stdlib>

#include "object.metal"
#include "../Loki/loki_header.metal"

using namespace metal;

class intersection {
public:
    object object;
    float3 position;
    float3 normal;
    float t;
    bool hit;
    ray ray;
};

class scene {
public:
    device object *objectsList;
    int size;
    
    intersection intersectRay(ray r) {
        bool hit = false;
        
        object closestObj = objectsList[0];
        
        intersection closest;
        closest.ray = r;
        closest.t = MAXFLOAT;
        
        for (int i = 0; i < size; i++) {
            object intersectObj = objectsList[i];
            //object intersectObj = *intersect_ptr;
            
            float intersect_t = intersectObj.intersect(r);
            
            if (intersect_t > 0 & intersect_t < closest.t) {
                hit = true;
                
                closest.object = objectsList[i];
                closest.ray = r;
                closest.t = intersect_t;
                
                closestObj = intersectObj;
            }
        }
        
        if (hit) {
            closest.hit = true;
            closest.position = closest.ray.extend(closest.t);
            closest.normal = closestObj.normalAtPoint(closest.position);
        } else {
            closest.hit = false;
        }
        
        return closest;
    }
    
    float3 randomUnitVec() {

        Loki rng = Loki(1, 2, 3);
        
        float3 vc;
        
        do {
            vc = ((float3(rng.rand(), rng.rand(), rng.rand()) * 2) - float3(1.f, 1.f, 1.f));
        } while (length_squared(vc) >= 1);
        
        return vc;
    }
};
