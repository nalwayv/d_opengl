# ---


EPSILON = 0.00001
PI = 3.14159
TAU = 6.28318
PHI = 1.57079


# ---


def sqr(x: float) -> float:
    return x * x

def sqrt(x: float) -> float:
    return x ** 0.5


# ---


class V3:
    def __init__(self, x: float, y: float, z: float):
        self.x: float = x
        self.y: float = y
        self.z: float = z

    def __str__(self):
        return f"[{self.x} {self.y} {self.z}]"

def dot(a: V3, b: V3) -> float:
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)

def length(a: V3) -> float:
    return sqrt(dot(a, a))

def subV3(a: V3, b: V3) -> V3:
    return V3(a.x - b.x, a.y - b.y, a.z - b.z)

def addV3(a: V3, b: V3) -> V3:
    return V3(a.x + b.x, a.y + b.y, a.z + b.z)

def scaleV3(a: V3, by: float) -> V3:
    return V3(a.x * by, a.y * by, a.z * by)

def cross(a: V3, b: V3) -> V3:
    x = a.y * b.z - a.z * b.y
    y = a.z * b.x - a.x * b.z
    z = a.x * b.y - a.y * b.x
    return V3(x, y, z)

def normal(v3: V3) -> V3:
    l = length(v3)

    x = v3.x / l
    y = v3.y / l
    z = v3.z / l
    
    return V3(x, y, z)


# ---


class Sphere:
    def __init__(self, c: V3, r: float):
        self.c: V3 = c
        self.r: float = r

    def __str__(self):
        return f"[{self.c.x} {self.c.y} {self.c.z}] {self.r}"


# ---


class Aabb:
    def __init__(self, c: V3, e: V3):
        self.c: V3 = c
        self.e: V3 = e

    def getMin(self) -> V3:
        a = addV3(self.c, self.e)
        b = subV3(self.c, self.e)
        return V3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))

    def getMax(self) -> V3:
        a = addV3(self.c, self.e)
        b = subV3(self.c, self.e)
        return V3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))


# ---


class Plane:
    def __init__(self, n: V3, d: float):
        self.n = n
        self.d = d

    def __str__(self):
        return f"[{self.n.x} {self.n.y} {self.n.z}] {self.d}"

def planeNormal(plane: Plane) -> Plane:
    nLen = length(plane.n)
    inv = 1.0 / nLen
    return Plane(scaleV3(plane.n, inv), plane.d * inv)

def planeCp(plane: Plane, pt: V3) -> V3:
    dis = (dot(plane.n, pt) - plane.d) / dot(plane.n, plane.n)
    c =  subV3(pt, scaleV3(plane.n, dis))
    return c


# ---


def testA():
    pass

# ---


sphere = Sphere(V3(0, 0, 0), 2)
plane = Plane(V3(2, 10, 2), 4)
aabb = Aabb(V3(0, 0, 0), V3(3, 3, 3))


# ---

print("")



