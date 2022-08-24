/// Mouse
module mouse;


import bindbc.glfw;


enum size_t MOUSESIZE = 7;
enum : int
{
    BUTTON_DEFAULT = 0,
    BUTTON_PRESSED = 1,
    BUTTON_HELD = 2,
    BUTTON_RELEASED = 3
}


struct Mouse 
{
    private 
    {
        int[MOUSESIZE] states;
        GLFWwindow* window;
    }

    /// init a new mouse struct
    /// Returns: Mouse
    static Mouse newMouse(GLFWwindow* window)
    {
        Mouse result;

        result.window = window;

        return result;
    }

    /// return current state that glfw mouse button is in
    /// Returns: int
    public int buttonState(int button)
    {
        assert(window !is null);
        assert(button >= 0 && button < MOUSESIZE);

        auto currentButtonState = glfwGetMouseButton(window, button);
        auto previousButtonState = 0xFF & states[button];

        states[button] = states[button] & 0xFFFF00FF | (previousButtonState << 8);
        states[button] = states[button] & 0xFFFFFF00 | (currentButtonState);

        auto getP = 0xFF & (states[button] >> 8);
        auto getC = 0xFF & states[button];

        int result;
        if(getP == 0)
        {
            if(getC == 0)
            {
                result = BUTTON_DEFAULT;
            }
            else
            {
                result = BUTTON_PRESSED;
            }
        }
        else
        { 
            if(getC == 0)
            {
                result = BUTTON_RELEASED;
            }
            else
            {
                result = BUTTON_HELD;
            }
        }
        
        return result;
    }

    public float x()
    {
        double x, y;
        
        glfwGetCursorPos(window, &x, &y);

        return cast(float)x;
    }

    public float y()
    {
        double x, y;
        
        glfwGetCursorPos(window, &x, &y);

        return cast(float)y;
    }

    public void setCursorPosition(float x, float y)
    {
        glfwSetCursorPos(window, cast(double)x, cast(double)y);
    }

    void hideCursor()
    {
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
    }

    void showCursor()
    {
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
    }

}