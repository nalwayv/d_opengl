module collision.narrow.imeshcollider;


import maths.vec3;


interface IMeshCollider
{
    Vec3 furthestPt(Vec3 direction);    
}