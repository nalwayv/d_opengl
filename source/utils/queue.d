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

/// Queue using LL
class QueueL(T)
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

/// Queue with a capacity limit
///
/// raises error if isfull or tying to deque if empty
class QueueC(T)
{
    private
    {
        T[] array;
        size_t cap;
        size_t front;
        size_t rear;
        size_t size;
    }

    this(size_t capacity)
    {
        array = new T[capacity];
        cap = capacity;
        front = -1;
        rear = -1;
        size = 0;
    }

    public bool isEmpty(){ return size == 0; }

    public bool isFull(){ return size == cap; }

    public void enQueue(T value)
    {
        assert(!isFull());

        rear = (rear + 1) % cap;
        array[rear] = value;

        if(front == -1)
        {
            front = rear;
        }
        
        size++;
    }

    public T deQueue()
    {
        assert(!isEmpty());

        auto result = array[front];

        if(front == rear)
        {
            front = rear = -1;
            size = 0;
        }
        else
        {
            font = (front + 1) % cap;
            size--;
        }

        return result;
    }
}