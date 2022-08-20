/// Stack: a simple generic stack
module utils.stack;


import core.memory : GC;

enum STACKCAP = 4;

/// helper class for simple stack collection uses
/// ```
/// alias StackI = Stack!(int);
///
/// auto s = new StackI();
/// ```
class Stack(T)
{
    private T* stack;
    private int top;
    private int cap;

    this()
    {
        cap = STACKCAP;
        top = -1;
        stack = cast(T*)(GC.calloc(STACKCAP));
    }

    ~this()
    {
        if(stack !is null)
        {
            GC.free(stack);
        }
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
            stack = cast(T*)(GC.realloc(stack, cap));
            assert(stack !is null);
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