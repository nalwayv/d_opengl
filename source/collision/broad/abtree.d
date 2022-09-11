/// AABB Tree
module collision.broad.abtree;


import utils.stack;
import maths.utils;
import maths.vec3;
import geometry.aabb;
import geometry.contains;
import geometry.intersection;


enum float EXPAND = 0.1f;
enum float MULTIPLIER = 4.0f;
enum size_t TREECAP = 16;
enum int NULLNODE = -1;


template TreeTemplate( T )
{
    class Node
    {

        AABB aabb;
        Node left;
        Node right;
        Node parent;
        int height;
        T data;
        // bool moved;

        this()
        {
        }

        bool isLeaf() const
        {
            return left is null;
        }
    }

    class ABTree
    {
        private 
        {
            Node root;
            Node[T] database;
        }
        
        this()
        {
        }

        /// balance trees nodes
        /// Returns: Node
        private Node balanceNode(Node leafNode)
        {
            assert(leafNode !is null);

            if(leafNode.isLeaf() || leafNode.height < 2)
            {
                return leafNode;
            }

            Node a = leafNode;
            Node b = a.left;
            Node c = a.right;
            
            auto balance = c.height - b.height;

            // rotate c up
            if(balance > 1)
            {                   
                Node f = c.left;
                Node g = c.right;

                c.left = a;
                c.parent = a.parent;
                a.parent = c;

                if(c.parent !is null)
                {
                    auto cp = c.parent;
                    if(cp.left is a)
                    {
                        cp.left = c;
                    }
                    else
                    {
                        cp.right = c;
                    }
                }
                else
                {
                    root = c;
                }

                // rotate
                if(f.height > g.height)
                {
                    c.right = f;
                    a.right = g;
                    g.parent = a;

                    a.aabb = AABB.fromCombined(b.aabb, g.aabb);
                    c.aabb = AABB.fromCombined(a.aabb, f.aabb);

                    a.height = 1 + maxI(b.height, g.height);
                    c.height = 1 + maxI(a.height, f.height);
                }
                else
                {
                    c.right = g;
                    a.right = f;
                    f.parent = a;

                    a.aabb = AABB.fromCombined(b.aabb, f.aabb);
                    c.aabb = AABB.fromCombined(a.aabb, g.aabb);

                    a.height = 1 + maxI(b.height, f.height);
                    c.height = 1 + maxI(a.height, g.height);
                }

                return c;
            }

            // rotate b up
            if(balance < -1)
            {
                Node d = b.left;
                Node e = b.right;

                b.left = a;
                b.parent = a.parent;
                a.parent = b;

                if(b.parent !is null)
                {
                    auto bp = b.parent;
                    if(bp.left is a)
                    {
                        bp.left = b;
                    }
                    else
                    {
                        bp.right = b;
                    }
                }
                else
                {
                    root = b;
                }

                // rotate
                if(d.height > e.height)
                {
                    b.right = d;
                    a.left = e;
                    e.parent = a;

                    a.aabb = AABB.fromCombined(c.aabb, e.aabb);
                    b.aabb = AABB.fromCombined(a.aabb, d.aabb);

                    a.height = 1 + maxI(c.height, e.height);
                    b.height = 1 + maxI(a.height, d.height);
                }
                else
                {                
                    b.right = e;
                    a.left = d;
                    d.parent = a;

                    a.aabb = AABB.fromCombined(c.aabb, d.aabb);
                    b.aabb = AABB.fromCombined(a.aabb, e.aabb);

                    a.height = 1 + maxI(c.height, d.height);
                    b.height = 1 + maxI(a.height, e.height);
                }

                return b;
            }

            return a;
        }

        /// add node to tree
        private void insertNode(Node leafNode)
        {
            if(root is null)
            {
                root = leafNode;
                return;
            }

            // find best sibling for node
            auto current = root;
            while(current.isLeaf() == false)
            {
                Node left = current.left;
                Node right = current.right;

                auto area = current.aabb.perimeter();
                auto combinedArea = AABB.fromCombined(current.aabb, leafNode.aabb).perimeter();
                auto cost = 2.0f * combinedArea;
                auto inheritCost = 2.0 * (combinedArea - area);

                // cost to decend ever left or right
                float leftCost;
                if(left.isLeaf())
                {
                    AABB aabb = AABB.fromCombined(leafNode.aabb, left.aabb);
                    leftCost = aabb.perimeter() + inheritCost;
                }
                else
                {
                    auto aabb = AABB.fromCombined(leafNode.aabb, left.aabb);

                    auto oldP = left.aabb.perimeter();
                    auto newP = aabb.perimeter();

                    leftCost = (newP - oldP) + inheritCost;
                }

                float rightCost;
                if(right.isLeaf())
                {
                    auto aabb = AABB.fromCombined(leafNode.aabb, right.aabb);
                    rightCost = aabb.perimeter() + inheritCost;
                }
                else
                {
                    auto aabb = AABB.fromCombined(leafNode.aabb, right.aabb);

                    auto oldP = right.aabb.perimeter();
                    auto newP = aabb.perimeter();

                    rightCost = (newP - oldP) + inheritCost;
                }

                if(cost < leftCost && cost < rightCost)
                {
                    break;
                }

                current = (leftCost < rightCost) ? left : right;
            }

            // new node
            Node sibling = current;
            Node oldParent = sibling.parent;
            Node newParent = new Node();
            newParent.parent = oldParent;
            newParent.aabb = AABB.fromCombined(leafNode.aabb, sibling.aabb);
            newParent.height = sibling.height + 1;

            if(oldParent !is null)
            {
                if(oldParent.left is sibling)
                {
                    oldParent.left = newParent;
                }
                else
                {
                    oldParent.right = newParent;
                }

                newParent.left = sibling;
                newParent.right = leafNode;
                sibling.parent = newParent;
                leafNode.parent = newParent;
            }
            else
            {
                newParent.left = sibling;
                newParent.right = leafNode;
                sibling.parent = newParent;
                leafNode.parent = newParent;
                root = newParent;
            }

            current = leafNode.parent;
            while(current !is null)
            {
                current = balanceNode(current);

                current.aabb = AABB.fromCombined(current.left.aabb, current.right.aabb);
                current.height = 1 + maxI(current.left.height, current.right.height);

                current = current.parent;
            }
        }

        /// remove node from tree
        private void removeNode(Node leafNode)
        {
            assert(leafNode !is null);

            if(leafNode is root)
            {
                root = null;
                return;
            }

            Node parent = leafNode.parent;
            Node gParent = parent.parent;
            
            Node sibling = (parent.left is leafNode) ? parent.right : parent.left;

            if(gParent !is null)
            {
                if(gParent.left is parent)
                {
                    gParent.left = sibling;
                }
                else
                {
                    gParent.right = sibling;
                }

                sibling.parent = gParent;

                Node current = gParent;
                while(current !is null)
                {
                    current = balanceNode(current);

                    current.aabb = AABB.fromCombined(current.left.aabb, current.right.aabb);
                    current.height= 1 + maxI(current.left.height, current.right.height);

                    current = current.parent;
                }
            }
            else 
            {
                root = sibling;
                sibling.parent = null;
            }
        }

        /// validate tree
        /// Returns: bool
        private bool validate(Node leafNode)
        {
            if(leafNode is null)
            {
                return true;
            }

            if (leafNode is root)
            {
                if(leafNode.parent !is null)
                {
                    return false;
                }
            }

            Node left = leafNode.left;
            Node right = leafNode.right;

            if(leafNode.isLeaf())
            {
                if(left !is null)
                {
                    return false;
                }

                if(right !is null)
                {
                    return false;
                }

                if(leafNode.height != 0)
                {
                    return false;
                }
            
                return true;
            }

            if(left.parent !is leafNode)
            {
                return false;
            }

            if(right.parent !is leafNode)
            {
                return false;
            }

            return validate(left) && validate(right);
        }

        // ---

        /// check if tree is valid
        /// Returns: bool
        public bool validateTree()
        {
            return validate(root);
        }

        /// add a node to the tree
        public void add(AABB ab, T data)
        {
            Node node = new Node();
            node.data = data;
            node.height = 0;
            node.aabb = ab.expanded(EXPAND);

            auto check = data in database;
            if(check is null)
            {
                database[data] = node;
                insertNode(node);
            }
        }

        /// remove a node from the tree
        public void remove(T data)
        {
            auto checkDB = data in database;
            if(checkDB !is null)
            {
                removeNode(*checkDB);

                database.remove(data);
            }
        }

        /// update and move nodes aabb
        public void move(AABB ab, T data)
        {
            auto checkDB = data in database;
            if(checkDB is null) 
            {
                return;
            }

            Node node = *checkDB;
            if(!node.isLeaf()) 
            {
                return;
            }

            if(containsAABBAABB(node.aabb, ab))
            {
                auto p0 = ab.perimeter();
                auto p1 = node.aabb.perimeter();

                if((p0 / p1) < 2.0f)
                {
                    return;
                }

                removeNode(node);
                node.aabb = ab.expanded(EXPAND);
                insertNode(node);
            }
        }
        
        /// shift the origin of the tree
        public void shiftOrigin(Vec3 origin)
        {
            auto stk = new Stack!Node();
            while(!stk.isEmpty())
            {
                Node current = stk.pop();
                if(current is null)  
                {
                    continue;
                }

                current.aabb = current.aabb.shifted(origin);

                stk.push(current.left);
                stk.push(current.right);
            }
        }

        // ---

        /// query tree if ab intersects any nodes aabb
        /// 
        /// delegate will use that nodes stored data as its paramiter
        public void query(AABB ab, bool delegate(T) cb)
        {
            auto stk = new Stack!Node();
            stk.push(root);

            while(!stk.isEmpty())
            {
                Node current = stk.pop();
                if(current is null)
                {
                    continue;
                }

                if(intersectsAabbAabb(ab, current.aabb))
                {
                    if(current.isLeaf())
                    {
                        if(!cb(current.data))
                        {
                            return;
                        }
                    }
                    else
                    {
                        stk.push(current.left);
                        stk.push(current.right);
                    }
                }
            }
        }
    }
}
