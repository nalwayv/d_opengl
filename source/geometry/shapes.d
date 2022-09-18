/// Types
module geometry.shapes;

enum : int 
{
    SHAPE_RAY = 1 << 0,
    SHAPE_AABB = 1 << 1,
    SHAPE_OBB = 1 << 2,
    SHAPE_SPHERE = 1 << 3,
    SHAPE_LINE = 1 << 4,
    SHAPE_PLANE = 1 << 5,
}