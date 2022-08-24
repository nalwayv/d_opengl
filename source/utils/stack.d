/// Stack: a simple generic stack
module utils.stack;


enum size_t STACKCAP = 4;


/// helper class for simple stack collection uses
/// ```
/// alias StackI = Stack!(int);
///
/// auto s = new StackI();
/// ```
class Stack(T)
{
    private T[] stack;
    private size_t cap;
    private int top;

    this()
    {
        cap = STACKCAP;
        top = -1;
        stack = new T[STACKCAP];
    }

    bool isEmpty()
    {
        return top == -1;
    }

    void push(T value)
    {
        if(top == cap - 1)
        {
            cap *= 2;
            stack.length = cap;
        }
        stack[++top] = value;
    }

    T pop()
    {
        assert(!isEmpty());
        return stack[top--];
    }

    T peek()
    {
        assert(!isEmpty());
        return stack[top];
    }
}