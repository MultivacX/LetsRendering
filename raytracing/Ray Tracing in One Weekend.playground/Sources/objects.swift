import Foundation
import simd

struct hit_record {
    var t: Float
    var p: SIMD3<Float>
    var normal: SIMD3<Float>
    init() {
        t = 0.0
        p = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
        normal = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
    }
}

protocol hitable {
    func hit(_ r: ray, _ tmin: Float, _ tmax: Float, _ rec: inout hit_record) -> Bool
}

class sphere: hitable  {
    var center = SIMD3<Float>(x: 0.0, y: 0.0, z: 0.0)
    var radius = Float(0.0)
    init(_ c: SIMD3<Float>, _ r: Float) {
        center = c
        radius = r
    }
    func hit(_ r: ray, _ tmin: Float, _ tmax: Float, _ rec: inout hit_record) -> Bool {
        // 1. || P - center || = radius
        // 2. P = origin + t * direction
        // 3. || origin + t * direction - center || = radius
        // 4. t^2 * direction^2 + 2 * direction * oc * t + oc^2 - radius^2 = 0
        // a=direction^2, b=2*direction*oc, c=oc^2-radius^2
        // (-b +- sqrt(b*b - 4*a*c) / (2*a)
        
        let oc = r.origin - center
        let a = dot(r.direction, r.direction)
        let b = dot(oc, r.direction)
        let c = dot(oc, oc) - radius*radius
        let discriminant = b*b - a*c
        if discriminant > 0 {
            var t = (-b - sqrt(discriminant) ) / a
            if t < tmin {
                t = (-b + sqrt(discriminant) ) / a
            }
            if tmin < t && t < tmax {
                rec.t = t
                rec.p = r.point_at_parameter(rec.t)
                rec.normal = (rec.p - center) / SIMD3<Float>(repeating: radius)
                return true
            }
        }
        return false
    }
}

class hitable_list: hitable  {
    var list = [hitable]()
    func add(_ h: hitable) {
        list.append(h)
    }
    func hit(_ r: ray, _ tmin: Float, _ tmax: Float, _ rec: inout hit_record) -> Bool {
        var hit_anything = false
        for item in list {
            if (item.hit(r, tmin, tmax, &rec)) {
                hit_anything = true
            }
        }
        return hit_anything
    }
}

func random_in_unit_sphere() -> SIMD3<Float> {
    var p = SIMD3<Float>()
    repeat {
        p = 2.0 * SIMD3<Float>(x: Float(drand48()), y: Float(drand48()), z: Float(drand48())) - SIMD3<Float>(x: 1, y: 1, z: 1)
    } while dot(p, p) >= 1.0
    return p
    
    // r = [0, 1), theta, phi
    // x = r * sin(t) * cos(p)
    // y = r * sin(t) * sin(p)
    // z = r * cos(t)
//    let r = drand48()
//    let t = drand48()
//    let p = drand48()
//    let sin_t = sin(Double.pi * 2.0 * t)
//    let cos_t = sin(Double.pi * 2.0 * t)
//    let sin_p = sin(Double.pi * 2.0 * p)
//    let cos_p = sin(Double.pi * 2.0 * p)
//    let x = Float(r + sin_t * cos_p)
//    let y = Float(r + sin_t * sin_p)
//    let z = Float(r + cos_t)
//    return SIMD3<Float>(x: x, y: y, z: z)
}
