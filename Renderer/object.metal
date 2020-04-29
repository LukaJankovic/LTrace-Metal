//
//  object.metal
//  LTrace
//
//  Created by Luka Jankovic on 2020-04-26.
//  Copyright © 2020 Luka Jankovic. All rights reserved.
//

#include <metal_stdlib>

#include "ray.metal"

#define LTRACE_TYPE_SPHERE 0
#define LTRACE_TYPE_PLANE  1

using namespace metal;

class material {
public:
    float3 diffuseColor;
    float3 diffuseGlow;
    
    bool glow;
    
    material() {};
};

class object {
public:
    material material;
    int type;
    
    // General properties
    float3 origin;
    
    // Sphere specific properties
    float radius;
    
    // Plane specific properties
    float3 normal;
    
    // General functions
    float intersect(ray r) {
        switch (type) {
            case LTRACE_TYPE_SPHERE: {
                float3 OC = r.origin - origin;
                float a = length_squared(r.direction);
                float b = dot(OC, r.direction);
                float c = length_squared(OC) - pow(radius, 2);
                
                float discriminant = pow(b, 2) - a * c;
                
                if (discriminant > 0) {
                    float t0 = (-b - sqrt(discriminant)) / a;
                    float t1 = (-b + sqrt(discriminant)) / a;
                    
                    return t0 > t1 ? t1 : t0;
                }
                
                return -1;
            }
            case LTRACE_TYPE_PLANE: {
                float parallel = dot(r.direction, normal);
                
                if (parallel == 0)
                    return -1.f;
                else
                    return dot(origin - r.origin, normal) / parallel;
            }
            default:;
        };
        
        return -1.f;
    }
    
    float3 normalAtPoint(float3 p) {
        switch (type) {
            case LTRACE_TYPE_SPHERE: {
                return normalize(p - origin);
            }
            case LTRACE_TYPE_PLANE: {
                return dot(-1 * p, normal) * normal;
            }
        }
        
        return float3(-1, -1, -1);
    }
    
    // Initializers
    object(float3 o, float r) {
        origin = o;
        radius = r;
        type = LTRACE_TYPE_SPHERE;
    };
    
    object(float3 o, float3 n) {
        origin = o;
        normal = n;
        type = LTRACE_TYPE_PLANE;
    };
    
    object() {};
};
