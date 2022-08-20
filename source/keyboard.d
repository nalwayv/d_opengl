/// KEyboard
module keyboard;


import bindbc.glfw;


enum KBSIZE = 350;
enum
{
    KEY_DEFAULT = 0,
    KEY_PRESSED = 1,
    KEY_HELD = 2,
    KEY_RELEASED = 3
}


struct Keyboard 
{
    int[KBSIZE] states;
    GLFWwindow* window;

    /// init a new keyboard struct
    /// Returns: Keyboard
    static Keyboard newKeyboard(GLFWwindow* window)
    {
        Keyboard result;

        result.window = window;

        return result;
    }

    /// return current state that glfw key is in
    /// Examples: getState(GLFW_KEY_A) == KEY_PRESSED
    /// Returns: int
    int getState(int key)
    {
        assert(window !is null);
        assert(key >= 0 && key < KBSIZE);

        auto currentKeyState = glfwGetKey(window, key);
        auto previousKeyState = 0xFF & states[key];

        states[key] = states[key] & 0xFFFF00FF | (previousKeyState << 8);
        states[key] = states[key] & 0xFFFFFF00 | (currentKeyState);

        auto getP = 0xFF & (states[key] >> 8);
        auto getC = 0xFF & states[key];

        int result;
        if(getP == 0)
        {
            if(getC == 0)
            {
                result = KEY_DEFAULT;
            }
            else
            {
                result = KEY_PRESSED;
            }
        }
        else
        { 
            if(getC == 0)
            {
                return KEY_RELEASED;
            }
            else
            {
                return KEY_HELD;
            }
        }
        
        return result;
    }
}