/// AABB Tree
module collision.broad.tree;


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
    struct Node
    {
        AABB aabb;
        bool moved;
        int left;
        int right;
        int height;
        union { 
            int parent;
            int next; 
        }
        T data;

        bool isLeaf() const
        {
            return left == NULLNODE;
        }
    }

    class Tree
    {
        private 
        {
            Node[] nodes;
            int cap;
            int count;
            int free;
            int root;
        }
        
        this()
        {
            nodes = new Node[TREECAP];

            cap = TREECAP;
            count = 0;
            root = NULLNODE;
            free = 0;

            for(auto i = 0; i < cap - 1; i++)
            {
                nodes[i].parent = i + 1;
                nodes[i].height = -1;
            }

            nodes[cap - 1].parent = NULLNODE;
            nodes[cap - 1].height = -1;
        }

        private int allocNewNode()
        {
            if(free == NULLNODE)
            {
                cap *= 2;
                nodes.length = cap;

                for(auto i = count; i < cap - 1; i++)
                {
                    nodes[i].next = i + 1;
                    nodes[i].height = -1;
                }

                nodes[cap - 1].next = NULLNODE;
                nodes[cap - 1].height = -1;

                free = count;
            }

            auto id = free;
            free = nodes[id].next;

            nodes[id].parent = NULLNODE;
            nodes[id].left = NULLNODE;
            nodes[id].right = NULLNODE;
            nodes[id].height = 0;
            nodes[id].moved = false;

            ++count;

            return id;
        }

        private void freeNode(int nodeID)
        {
            assert(nodeID >= 0 && nodeID < cap);
            assert(count > 0);

            nodes[nodeID].next = free;
            nodes[nodeID].height = -1;
            free = nodeID;

            --count;
        }

        private int balanceNode(int nodeID)
        {
            assert(nodeID != NULLNODE);

            auto a = nodeID;
            auto A =  nodes[nodeID];
            if(A.isLeaf() || A.height < 2)
            {
                return a;
            }

            auto b = A.left;
            auto c = A.right;

            assert(b >= 0 && b < cap);
            assert(c >= 0 && c < cap);

            auto B = nodes[b];
            auto C = nodes[c];

            auto balance = C.height - B.height;

            // rotate c up
            if(balance > 1)
            {                   
                auto f = C.left;
                auto g = C.right;
                
                auto F = nodes[f];
                auto G = nodes[g];

                assert(f >= 0 && f < cap);
                assert(g >= 0 && g < cap);

                C.left = a;
                C.parent = A.parent;
                A.parent = c;

                if(C.parent != NULLNODE)
                {
                    if(nodes[C.parent].left == a)
                    {
                        nodes[C.parent].left = c;
                    }
                    else
                    {
                        assert(nodes[C.parent].right == a);
                        nodes[C.parent].right = c;
                    }
                }
                else
                {
                    root = c;
                }

                // rotate
                if(F.height > G.height)
                {
                    C.right = f;
                    A.right = g;
                    G.parent = a;

                    A.aabb = AABB.fromCombined(B.aabb, G.aabb);
                    C.aabb = AABB.fromCombined(A.aabb, F.aabb);

                    A.height = 1 + maxI(B.height, G.height);
                    C.height = 1 + maxI(A.height, F.height);
                }
                else
                {
                    C.right = g;
                    A.right = f;
                    F.parent = a;

                    A.aabb = AABB.fromCombined(B.aabb, F.aabb);
                    C.aabb = AABB.fromCombined(A.aabb, G.aabb);

                    A.height = 1 + maxI(B.height, F.height);
                    C.height = 1 + maxI(A.height, G.height);
                }

                return c;
            }

            // rotate b up
            if(balance < -1)
            {
                int d = B.left;
                int e = B.right;

                auto D = nodes[d];
                auto E = nodes[e];

                assert(d >= 0 && d < cap);
                assert(e >= 0 && e < cap);

                B.left = a;
                B.parent = A.parent;
                A.parent = b;

                if(B.parent != NULLNODE)
                {
                    if(nodes[B.parent].left == a)
                    {
                        nodes[B.parent].left = b;
                    }
                    else
                    {
                        assert(nodes[B.parent].right == a);
                        nodes[B.parent].right = b;
                    }
                }
                else
                {
                    root = b;
                }

                // rotate
                if(D.height > E.height)
                {
                    B.right = d;
                    A.left = e;
                    E.parent = a;

                    A.aabb = AABB.fromCombined(C.aabb, E.aabb);
                    B.aabb = AABB.fromCombined(A.aabb, D.aabb);

                    A.height = 1 + maxI(C.height, E.height);
                    B.height = 1 + maxI(A.height, D.height);
                }
                else
                {                
                    B.right = e;
                    A.left = d;
                    D.parent = a;

                    A.aabb = AABB.fromCombined(C.aabb, D.aabb);
                    B.aabb = AABB.fromCombined(A.aabb, E.aabb);

                    A.height = 1 + maxI(C.height, D.height);
                    B.height = 1 + maxI(A.height, E.height);
                }

                return b;
            }

            return a;
        }

        private void insertNode(int nodeID)
        {
            if(root == NULLNODE)
            {
                root = nodeID;
                nodes[root].parent = NULLNODE;
                return;
            }

            // find best sibling for node
            AABB nodeAABB = nodes[nodeID].aabb;
            auto current = root;
            
            while(nodes[current].isLeaf() == false)
            {
                auto left = nodes[current].left;
                auto right = nodes[current].right;

                auto area = nodes[current].aabb.perimeter();

                auto combinedAABB = AABB.fromCombined(nodes[current].aabb, nodeAABB);
                auto cost = 2.0f * combinedAABB.perimeter();
                auto inheritCost = 2.0 * (combinedAABB.perimeter() - area);

                // cost to decend ever left or right
                float leftCost;
                if(nodes[left].isLeaf())
                {
                    auto aabb = AABB.fromCombined(nodeAABB, nodes[left].aabb);
                    leftCost = aabb.perimeter() + inheritCost;
                }
                else
                {
                    auto aabb = AABB.fromCombined(nodeAABB, nodes[left].aabb);

                    auto oldP = nodes[left].aabb.perimeter();
                    auto newP = aabb.perimeter();

                    leftCost = (newP - oldP) + inheritCost;
                }

                float rightCost;
                if(nodes[right].isLeaf())
                {
                    auto aabb = AABB.fromCombined(nodeAABB, nodes[right].aabb);
                    rightCost = aabb.perimeter() + inheritCost;
                }
                else
                {
                    auto aabb = AABB.fromCombined(nodeAABB, nodes[right].aabb);

                    auto oldP = nodes[right].aabb.perimeter();
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
            auto sibling = current;
            auto oldParent = nodes[sibling].parent;
            auto newParent = allocNewNode();
            nodes[newParent].parent = oldParent;
            nodes[newParent].aabb = AABB.fromCombined(nodeAABB, nodes[sibling].aabb);
            nodes[newParent].height = nodes[sibling].height + 1;

            if(oldParent != NULLNODE)
            {
                if(nodes[oldParent].left == sibling)
                {
                    nodes[oldParent].left = newParent;
                }
                else
                {
                    nodes[oldParent].right = newParent;
                }

                nodes[newParent].left = sibling;
                nodes[newParent].right = nodeID;
                nodes[sibling].parent = newParent;
                nodes[nodeID].parent = newParent;
            }
            else
            {
                nodes[newParent].left = sibling;
                nodes[newParent].right = nodeID;
                nodes[sibling].parent = newParent;
                nodes[nodeID].parent = newParent;
                root = newParent;
            }

            current = nodes[nodeID].parent;
            while(current != NULLNODE)
            {
                current = balanceNode(current);
                
                auto left = nodes[current].left;
                auto right = nodes[current].right;

                assert(left != NULLNODE);
                assert(right != NULLNODE);

                nodes[current].aabb = AABB.fromCombined(nodes[left].aabb, nodes[right].aabb);
                nodes[current].height = 1 + maxI(nodes[left].height, nodes[right].height);

                current = nodes[current].parent;
            }
        }

        private void removeNode(int nodeID)
        {
            if(nodeID == root)
            {
                root = NULLNODE;
                return;
            }

            auto parent = nodes[nodeID].parent;
            auto gParent = nodes[parent].parent;
            
            auto sibling = (nodes[parent].left == nodeID) ? nodes[parent].right : nodes[parent].left;

            if(gParent != NULLNODE)
            {
                if(nodes[gParent].left == parent)
                {
                    nodes[gParent].left = sibling;
                }
                else
                {
                    nodes[gParent].right = sibling;
                }

                nodes[sibling].parent = gParent;
                freeNode(parent);

                auto current = gParent;
                while(current != NULLNODE)
                {
                    current = balanceNode(current);

                    auto left = nodes[current].left;
                    auto right = nodes[current].right;

                    nodes[current].aabb = AABB.fromCombined(nodes[left].aabb, nodes[right].aabb);
                    nodes[current].height= 1 + maxI(nodes[left].height, nodes[right].height);

                    current = nodes[current].parent;
                }
            }
            else 
            {
                root = sibling;
                nodes[sibling].parent = NULLNODE;
                freeNode(parent);
            }
        }

        private void validateTree(int nodeID)
        {
            if(nodeID == NULLNODE) 
            {
                return;
            }

            if(nodeID == root)
            {
                assert(nodes[nodeID].parent == NULLNODE);
            }

            auto node = nodes[nodeID];

            auto left = node.left;
            auto right = node.right;
            
            if(node.isLeaf())
            {
                assert(left == NULLNODE);
                assert(right == NULLNODE);
                assert(node.height == 0);
                return;
            }

            assert(left >= 0 && left < cap);
            assert(right >= 0 && right < cap);

            assert(nodes[left].parent == nodeID);
            assert(nodes[right].parent == nodeID);

            validateTree(left);
            validateTree(right);
        }

        /// add a node to the tree
        /// 
        /// use the int to index into tree
        ///
        /// Returns: int
        public int add(AABB ab, T data)
        {
            auto id = allocNewNode();

            nodes[id].aabb = ab.expanded(EXPAND);
            nodes[id].height = 0;
            nodes[id].data = data;
            nodes[id].moved = true;

            insertNode(id);

            return id;
        }

        /// remove a node from the tree
        /// 
        /// use the int retrived from adding a node to remove
        ///
        /// Returns: int
        public void remove(int nodeID)
        {
            assert(nodeID >= 0 && nodeID < cap);
            assert(nodes[nodeID].isLeaf());

            removeNode(nodeID);
            freeNode(nodeID);
        }

        /// move node
        public bool move(AABB ab, int nodeID)
        {
            assert(nodeID >= 0 && nodeID < cap);
            assert(nodes[nodeID].isLeaf());

            auto aabb = nodes[nodeID].aabb;
            if(aabbConatinsAabb(aabb, ab))
            {
                auto p0 = ab.perimeter();
                auto p1 = aabb.perimeter();
                if((p0 / p1) <= 2.0f)
                {
                    return false;
                }
            }

            auto fat = ab.expanded(EXPAND);

            removeNode(nodeID);

            nodes[nodeID].aabb = fat;
            
            insertNode(nodeID);
            
            nodes[nodeID].moved = true;

            return true;
        }

        /// check validation of tree
        ///
        /// will fail if invalid
        public void valide()
        {
            validateTree(root);
        }

        /// shift the origin of the tree
        public void shiftOrigin(Vec3 origin)
        {
            for(int i = 0; i < cap; i++)
            {
                nodes[i].aabb = nodes[i].aabb.shifted(origin);
            }
        }
        
        /// retrive data from a node stored in the tree by using its nodeID
        /// Returns: size_t
        public T getData(int nodeID)
        {
            assert(nodeID >= 0 && nodeID < cap);
            return nodes[nodeID].data;
        }

        public void query(AABB ab, bool delegate(T) cb)
        {
            auto stk = new StackC!int(cap);

            stk.push(root);
            while(!stk.isEmpty())
            {
                auto current = stk.pop();
                if(current == NULLNODE)  
                {
                    continue;
                }

                auto currentNode = nodes[current];
                if(aabbToAabb(ab, currentNode.aabb) == INTERSECTION)
                {
                    if(currentNode.isLeaf())
                    {
                        cb(currentNode.data);
                        // if(!cb(currentNode.data))
                        // {
                        //     return;
                        // }
                    }
                    else
                    {
                        stk.push(currentNode.left);
                        stk.push(currentNode.right);
                    }
                }
            }
        }
    }
}