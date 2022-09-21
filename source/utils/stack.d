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


class Stack(T)
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
