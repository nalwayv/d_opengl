# ---


def sqr(x) -> float:
    return x*x

def sqrt(x) -> float:
    return x ** 0.5


# ---


class V3:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z


def subV3(a, b) -> V3:
    return V3(a.x - b.x, a.y - b.y, a.z - b.z)

def addV3(a, b) -> V3:
    return V3(a.x + b.x, a.y + b.y, a.z + b.z)

def scaleV3(a, by) -> V3:
    return V3(a.x * by, a.y * by, a.z * by)

def dot(a, b) -> V3:
    return a.x*b.x + a.y*b.y + a.z*b.z

def length(a) -> V3:
    return sqrt(dot(a,a))


# ---


class Sphere:
    def __init__(self, c, r):
        self.c = c
        self.r = r


# ---


class Plane:
    def __init__(self, n, d):
        self.n = n
        self.d = d


def planeCp(plane: Plane, pt: V3) -> V3:
    dis = (dot(plane.n, pt) - plane.d) / dot(plane.n, plane.n)
    c =  subV3(pt, scaleV3(plane.n, dis))
    return c


# ---


# def testA(plane: Plane, sphere: Sphere) -> None:
#     cp = planeCp(plane, sphere.c)
#     v = subV3(sphere.c, cp)
#     lsq = dot(v, v)
#     # r2 = sphere.r * dot(plane.n, plane.n)
#     r2 = sqr(sphere.r)

#     if lsq < r2:
#         print("I")
#     elif lsq > r2:
#         print("F")
#     else:
#         print("B")


def testB(plane: Plane, sphere: Sphere) -> None:
    d = dot(plane.n, sphere.c)
    r = sphere.r * length(plane.n)
    if d + r < plane.d:
        print("B")
    elif d - r > plane.d:
        print("F")
    else:
        print("I")


# ---


sphere = Sphere(V3(-1, -6, -7), 1)
plane = Plane(V3(2, 10, 2), 4)

# testA(plane, sphere)
testB(plane, sphere)

