module geometry.obb;

import std.format;
import utils.bits;
import maths.utils;
import maths.vec3;
import maths.mat4;
import maths.mat3;


struct Obb
{
    Mat3 axis;
    Vec3 basis;
    Vec3 extents;

    static Obb newObb(Vec3 basis, Vec3 extents)
    {
        Obb result;

        result.axis = Mat3.identity();
        result.basis = basis;
        result.extents = extents;
        
        return result;
    }

    Obb transformed(Mat4 m4)
    {
        Mat4 tmp;

        tmp.m00 = axis.m00;
        tmp.m01 = axis.m01;
        tmp.m02 = axis.m02;
        tmp.m03 = 0.0f;
        tmp.m10 = axis.m10;
        tmp.m11 = axis.m11;
        tmp.m12 = axis.m12;
        tmp.m13 = 0.0f;
        tmp.m20 = axis.m20;
        tmp.m21 = axis.m21;
        tmp.m22 = axis.m22;
        tmp.m23 = 0.0f;
        tmp.m30 = basis.x;
        tmp.m31 = basis.y;
        tmp.m32 = basis.z;
        tmp.m33 = 1.0f;

        Mat4 mul = tmp.multiplied(m4);

        Obb result;
        
        result.axis.m00 = mul.m00;
        result.axis.m01 = mul.m01;
        result.axis.m02 = mul.m02;
        result.axis.m00 = mul.m10;
        result.axis.m00 = mul.m11;
        result.axis.m00 = mul.m12;
        result.axis.m00 = mul.m20;
        result.axis.m00 = mul.m21;
        result.axis.m00 = mul.m22;

        result.basis.x = mul.m30;
        result.basis.y = mul.m31;
        result.basis.z = mul.m32;

        result.extents.x = extents.x;
        result.extents.y = extents.y;
        result.extents.z = extents.z;

        return result;
    }

    Vec3 closestPoint(Vec3 pt)
    {
        Vec3 d = pt.subbed(basis);

        Vec3 result = basis;

        for(auto i = 0; i < 3 ; i++)
        {
            Vec3 currentRow = axis.rowAt(i);
            auto currentExtent = extents.at(i);

            auto dis = d.dot(currentRow);
           
            if(dis > currentExtent)
            {
                dis = currentExtent;
            }
           
            if(dis < -currentExtent)
            {
                dis = -currentExtent;
            }

            result = result.added(currentRow.scaled(dis));
        }

        return result;
    }

    // -- override

    size_t toHash() const nothrow @safe
    {
        const prime = 31;
        size_t result = 1;
        size_t tmp;

        tmp = floatToBits(basis.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(basis.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(basis.z);
        result = prime * result + (tmp ^ (tmp >>> 32));


        tmp = floatToBits(extents.x);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(extents.y);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(extents.z);
        result = prime * result + (tmp ^ (tmp >>> 32));


        tmp = floatToBits(axis.m00);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(axis.m01);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(axis.m02);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(axis.m10);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(axis.m11);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(axis.m12);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(axis.m20);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(axis.m21);
        result = prime * result + (tmp ^ (tmp >>> 32));

        tmp = floatToBits(axis.m22);
        result = prime * result + (tmp ^ (tmp >>> 32));

        return result;
    }

    bool opEquals(ref const Obb other) const pure
    {
        if(basis.x != other.basis.x) return false;
        if(basis.y != other.basis.y) return false;
        if(basis.z != other.basis.z) return false;

        if(extents.x != other.extents.x) return false;
        if(extents.y != other.extents.y) return false;
        if(extents.z != other.extents.z) return false;

        if(!isEquilF(axis.m00, other.axis.m00)) return false;
        if(!isEquilF(axis.m01, other.axis.m01)) return false;
        if(!isEquilF(axis.m02, other.axis.m02)) return false;
        if(!isEquilF(axis.m00, other.axis.m10)) return false;
        if(!isEquilF(axis.m01, other.axis.m11)) return false;
        if(!isEquilF(axis.m02, other.axis.m12)) return false;
        if(!isEquilF(axis.m00, other.axis.m20)) return false;
        if(!isEquilF(axis.m01, other.axis.m21)) return false;
        if(!isEquilF(axis.m02, other.axis.m22)) return false;

        return true;
    }

    /// Returns: string
    string toString() const pure
    {
        return format("OBB [[%.2f, %.2f, %.2f], [%.2, %.2, %.2], []]", 
            basis.x, basis.y, basis.z,
            extents.x, extents.y, extents.z
        );
    }
}