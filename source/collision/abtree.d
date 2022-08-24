/// AABB Tree
module collision.abtree;

// import utils.stack;
import maths.utils;
import maths.vec3;
import geometry.aabb;


enum size_t TREECAP = 16;
enum int NULLNODE = -1;

// TODO(...)
// alias ABStack = Stack!int;


template TplTree(T)
{
    struct Node
    {
        AABB aabb;
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

    class ABTree
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
            root = 0;
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
                nodes.length = cap; // reallocates

                for(auto i = count; i < cap - 1; i++)
                {
                    nodes[i].parent = i + 1;
                    nodes[i].height = -1;
                }

                nodes[cap - 1].parent = NULLNODE;
                nodes[cap - 1].height = -1;

                free = count;
            }

            auto id = free;
            free = nodes[id].next;

            nodes[id].parent = NULLNODE;
            nodes[id].left = NULLNODE;
            nodes[id].right = NULLNODE;
            nodes[id].height = 0;

            count += 1;

            return id;
        }

        private void freeNode(int nodeID)
        {
            assert(nodeID >= 0 && nodeID < cap);
            assert(count > 0);

            nodes[nodeID].next = free;
            nodes[nodeID].height = 0;
            free = nodeID;

            count -= 1;
        }

        private int balanceNode(int nodeID)
        {
            assert(nodeID != NULLNODE);

            auto a = nodeID;
            if(nodes[a].isLeaf() || nodes[a].height < 2)
            {
                return a;
            }

            auto b = nodes[a].left;
            auto c = nodes[a].right;

            auto balance = nodes[c].height - nodes[b].height;

            // rotate c up
            if(balance > 1)
            {                   
                auto f = nodes[c].left;
                auto g = nodes[c].right;

                assert(b >= 0 && b < cap);
                assert(c >= 0 && c < cap);

                nodes[c].left = a;
                nodes[c].parent = nodes[a].parent;
                nodes[a].parent = c;

                if(nodes[c].parent != NULLNODE)
                {
                    auto cp = nodes[c].parent;
                    if(nodes[cp].left == a)
                    {
                        nodes[cp].left = c;
                    }
                    else
                    {
                        nodes[cp].right = c;
                    }
                }
                else
                {
                    root = c;
                }

                // rotate
                if(nodes[f].height > nodes[g].height)
                {
                    nodes[c].right = f;
                    nodes[a].right = g;
                    nodes[g].parent = a;

                    nodes[a].aabb = AABB.fromCombined(nodes[b].aabb, nodes[g].aabb);
                    nodes[c].aabb = AABB.fromCombined(nodes[a].aabb, nodes[f].aabb);

                    nodes[a].height = 1 + maxI(nodes[b].height, nodes[g].height);
                    nodes[c].height = 1 + maxI(nodes[a].height, nodes[f].height);
                }
                else
                {
                    nodes[c].right = g;
                    nodes[a].right = f;
                    nodes[f].parent = a;

                    nodes[a].aabb = AABB.fromCombined(nodes[b].aabb, nodes[f].aabb);
                    nodes[c].aabb = AABB.fromCombined(nodes[a].aabb, nodes[g].aabb);

                    nodes[a].height = 1 + maxI(nodes[b].height, nodes[f].height);
                    nodes[c].height = 1 + maxI(nodes[a].height, nodes[g].height);
                }

                return c;
            }

            // rotate b up
            if(balance < -1)
            {
                int d = nodes[b].left;
                int e = nodes[b].right;

                assert(d >= 0 && d < cap);
                assert(e >= 0 && e < cap);

                nodes[b].left = a;
                nodes[b].parent = nodes[a].parent;
                nodes[a].parent = b;

                if(nodes[b].parent != NULLNODE)
                {
                    auto bp = nodes[b].parent;
                    if(nodes[bp].left == a)
                    {
                        nodes[bp].left = b;
                    }
                    else
                    {
                        nodes[bp].right = b;
                    }
                }
                else
                {
                    root = b;
                }

                // rotate
                if(nodes[d].height > nodes[e].height)
                {
                    nodes[b].right = d;
                    nodes[a].left = e;
                    nodes[e].parent = a;

                    nodes[a].aabb = AABB.fromCombined(nodes[c].aabb, nodes[e].aabb);
                    nodes[b].aabb = AABB.fromCombined(nodes[a].aabb, nodes[d].aabb);

                    nodes[a].height = 1 + maxI(nodes[c].height, nodes[e].height);
                    nodes[b].height = 1 + maxI(nodes[a].height, nodes[d].height);
                }
                else
                {                
                    nodes[b].right = e;
                    nodes[a].left = d;
                    nodes[d].parent = a;

                    nodes[a].aabb = AABB.fromCombined(nodes[c].aabb, nodes[d].aabb);
                    nodes[b].aabb = AABB.fromCombined(nodes[a].aabb, nodes[e].aabb);

                    nodes[a].height = 1 + maxI(nodes[c].height, nodes[d].height);
                    nodes[b].height = 1 + maxI(nodes[a].height, nodes[e].height);
                }

                return b;
            }

            return a;
        }

        private void insertNode(int nodeID)
        {
            if(root == nodeID)
            {
                root = nodeID;
                nodes[root].parent = NULLNODE;
                return;
            }

            // find best sibling for node
            auto current = root;
            while(!nodes[current].isLeaf())
            {
                auto left = nodes[current].left;
                auto right = nodes[current].right;

                auto area = nodes[current].aabb.perimeter();
                auto combinedArea = AABB.fromCombined(nodes[current].aabb, nodes[nodeID].aabb).perimeter();
                auto cost = 2.0f * combinedArea;
                auto inheritCost = 2.0 * (combinedArea - area);

                // cost to decend ever left or right
                float leftCost;
                if(nodes[left].isLeaf())
                {
                    leftCost = AABB.fromCombined(
                        nodes[nodeID].aabb,
                        nodes[left].aabb
                    ).perimeter() + inheritCost;
                }
                else
                {
                    auto p1 = AABB.fromCombined(
                        nodes[nodeID].aabb,
                        nodes[left].aabb,
                    ).perimeter();
                    auto p2 = nodes[left].aabb.perimeter();
                    leftCost = (p1 - p2) + inheritCost;
                }

                float rightCost;
                if(nodes[right].isLeaf())
                {
                    rightCost = AABB.fromCombined(
                        nodes[nodeID].aabb,
                        nodes[right].aabb
                    ).perimeter() + inheritCost;
                }
                else
                {
                    auto p1 = AABB.fromCombined(
                        nodes[nodeID].aabb,
                        nodes[right].aabb,
                    ).perimeter();
                    auto p2 = nodes[right].aabb.perimeter();
                    leftCost = (p1 - p2) + inheritCost;
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
            nodes[newParent].aabb = AABB.fromCombined(
                nodes[nodeID].aabb,
                nodes[sibling].aabb
            );
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
            auto sibling = (nodes[parent].left != nodeID) ? nodes[parent].left : nodes[parent].right;

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

            auto node = cast(const Node*)(nodes.ptr + nodeID);

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
            nodes[id].aabb = ab.expanded(0.1f);
            nodes[id].height = 0;
            nodes[id].data = data;

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
        
        /// retrive data from a node stored in the tree 
        /// by using its nodeID retrived from first adding
        /// a node to the tree
        /// Returns: T
        public T getData(int nodeID)
        {
            assert(nodeID >= 0 && nodeID < cap);
            return nodes[nodeID].data;
        }
    }
}