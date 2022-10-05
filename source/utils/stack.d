/// Stack: a simple generic stack
module utils.stack;


private class Node(T)
{
    public
    {
        T value;
        Node next;
    }

    this(T value, Node next)
    {
        this.value = value;
        this.next = next;
    }
}

/// Stack using LL
class StackL(T)
{
    private
    {
        Node!T top;
        int size;
    }

    this()
    {
        top = null;
        size = 0;
    }

    public bool isEmpty()
    {
        return size == 0;
    }

    public void push(T value)
    {
        top = new Node!T(value, top);
        size++;
    }

    public T pop()
    {
        assert(!isEmpty());

        auto result = top.value;

        auto node = top;
        top = node.next;
        node = null;
        size--;

        return result;
    }

    public T peek()
    {
        assert(!isEmpty());
        return top.value;
    }
}


/// Stack with a capacity limit
///
/// fails if isfull or tyying to pop data if isempty
class StackC(T)
{
    private
    {
        T[] array;
        size_t cap;
        size_t top;
    }

    this(size_t capacity)
    {
        array = new T[capacity];
        cap = capacity;
        top = -1;
    }

    public bool isEmpty(){ return top == -1; }
    
    public bool isFull(){ return top == cap -1; }

    public void push(T value)
    {
        assert(!isFull());

        array[++top] = value;
    }

    public T pop()
    {
        assert(!isEmpty());
        return array[top--];
    }

    public T peek()
    {
        assert(!isEmpty());
        return array[top];
    }
}