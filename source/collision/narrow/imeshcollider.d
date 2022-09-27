module collision.narrow.imeshcollider;


import maths.vec3;


interface IMeshCollider
{
    Vec3 farthestPoint(Vec3 direction);
    size_t pointsLength();
}