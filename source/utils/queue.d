/// Queue: a simple generic queue
module utils.queue;


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


class Queue(T)
{
    private
    {
        Node!T head;
        Node!T tail;
        int size;
    }

    this()
    {
        head = null;
        tail = null;
        size = 0;
    }

    public T peek()
    {
        assert(!isEmpty());
        return head.value;
    }

    public bool isEmpty()
    {
        return size == 0;    
    }

    public void enQueue(T value)
    {
        auto node = new Node!T(value, null);

        if(head is null)
        {
            head = node;
            tail = node;
        }
        else
        {
            tail.next = node;
            tail = node;
        }

        size++;
    }

    public T deQueue()
    {
        assert(!isEmpty());

        auto result = head.value;

        auto node = head;

        head = head.next;

        node = null;

        size--;

        return result;
    }
}
