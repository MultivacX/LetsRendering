import Foundation
import simd

/*struct vec3 {
    var x = 0.0
    var y = 0.0
    var z = 0.0
}

func * (left: Double, right: vec3) -> vec3 {
    return vec3(x: left * right.x, y: left * right.y, z: left * right.z)
}

func + (left: vec3, right: vec3) -> vec3 {
    return vec3(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
}

func - (left: vec3, right: vec3) -> vec3 {
    return vec3(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}

func dot (_ left: vec3, _ right: vec3) -> Double {
    return left.x * right.x + left.y * right.y + left.z * right.z
}

func unit_vector(_ v: vec3) -> vec3 {
    let length : Double = sqrt(dot(v, v))
    return vec3(x: v.x / length, y: v.y / length, z: v.z / length)
}*/

struct ray {
    var origin: SIMD3<Float>
    var direction: SIMD3<Float>
    func point_at_parameter(_ t: Float) -> SIMD3<Float> {
        return origin + t * direction
    }
}

func color(_ r: ray, _ world: hitable) -> SIMD3<Float> {
    var rec = hit_record()
    if world.hit(r, 0.001, Float.infinity, &rec) {
        // 射线与物体的交点 hitpoint 处，法线 N 转换为颜色
        // return 0.5 * SIMD3<Float>(rec.normal.x + 1, rec.normal.y + 1, rec.normal.z + 1);
        
        // diffuse: 在射线与物体的交点 hitpoint 处，沿其法线 N 方向移动单位距离，构造单位球 US
        // 物体 与 US 相切于 hitpoint，向量 US_origin - hitpoint == N / ||N||
        // 在 US 内部取任意一点 S，向量 S - hitpoint 为散射光方向, 转换为颜色
        let target = rec.p + rec.normal + random_in_unit_sphere()
        return 0.5 * color(ray(origin: rec.p, direction: target - rec.p), world)
    } else {
        let unit_direction = normalize(r.direction)
        let t = 0.5 * (unit_direction.y + 1)
        return (1.0 - t) * SIMD3<Float>(x: 1, y: 1, z: 1) + t * SIMD3<Float>(x: 0.5, y: 0.7, z: 1.0)
    }
}
