/// CubeData
/// simple helper struct for creating cube data ?
module cubedata;


import maths.utils;
import vertex;


struct CubeMesh
{
    Vertex[24] verts;
    int[36] indicies;

    static CubeMesh newCubeMesh(float w, float h, float d, float r, float g, float b)
    {
        r = normalizeF(clampF(r, 0.0f, 255.0f), 0, 255.0f);
        g = normalizeF(clampF(g, 0.0f, 255.0f), 0, 255.0f);
        b = normalizeF(clampF(b, 0.0f, 255.0f), 0, 255.0f);

        CubeMesh result;

        result.verts = [
            Vertex([ w,  h,  d], [r, g, b]),
            Vertex([-w,  h,  d], [r, g, b]),
            Vertex([-w, -h,  d], [r, g, b]),
            Vertex([ w, -h,  d], [r, g, b]),
            Vertex([ w,  h,  d], [r, g, b]),
            Vertex([ w, -h,  d], [r, g, b]),
            Vertex([ w, -h, -d], [r, g, b]),
            Vertex([ w,  h, -d], [r, g, b]),
            Vertex([ w,  h,  d], [r, g, b]),
            Vertex([ w,  h, -d], [r, g, b]),
            Vertex([-w,  h, -d], [r, g, b]),
            Vertex([-w,  h,  d], [r, g, b]),
            Vertex([-w,  h,  d], [r, g, b]),
            Vertex([-w,  h, -d], [r, g, b]),
            Vertex([-w, -h, -d], [r, g, b]),
            Vertex([-w, -h,  d], [r, g, b]),
            Vertex([-w, -h, -d], [r, g, b]),
            Vertex([ w, -h, -d], [r, g, b]),
            Vertex([ w, -h,  d], [r, g, b]),
            Vertex([-w, -h,  d], [r, g, b]),
            Vertex([ w, -h, -d], [r, g, b]),
            Vertex([-w, -h, -d], [r, g, b]),
            Vertex([-w,  h, -d], [r, g, b]),
            Vertex([ w,  h, -d], [r, g, b])
        ];

        result.indicies = [
            0,  1,  2,  2,  3,  0,
            4,  5,  6,  6,  7,  4,
            8,  9, 10, 10, 11,  8,
            12, 13, 14, 14, 15, 12,
            16, 17, 18, 18, 19, 16,
            20, 21, 22, 22, 23, 20
        ];

        return result;
    }
}
