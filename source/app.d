// APP
import std.stdio : writeln;
import bindbc.opengl;
import bindbc.glfw;
import maths.mat4;
import maths.vec3;
import clock;
import keyboard;
import mouse;
import obj;
import shader;
import camera;


enum WIDTH = 500;
enum HEIGHT = 500;


GLFWwindowsizefun windowSizeCB()
{
    return function(GLFWwindow* w, int width, int height) 
    {
        glViewport(0, 0, width, height);
    };
}


void main()
{
    // init glfw
    if(loadGLFW("bin\\glfw3.dll") != glfwSupport)
    {
        throw new Exception("Failed to locate glfw3.dll");
    }

    if(!glfwInit())
    {
        throw new Exception("Failed to initialize GLFW");
    }

    // init window    
    auto window = glfwCreateWindow(WIDTH, HEIGHT, "D", null, null);
    if(window is null) 
    {
        glfwTerminate();
        throw new Exception("failed to create window");
    }
    glfwMakeContextCurrent(window);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);

    // init openGL
    if(loadOpenGL() != glSupport)
    {
        throw new Exception("Failed to initialize OpenGL");
    }

    // center window
    auto mode = glfwGetVideoMode(glfwGetPrimaryMonitor());
    glfwSetWindowPos(window, (mode.width / 2) - WIDTH / 2, (mode.height / 2) - HEIGHT / 2);
    glfwSetWindowSizeCallback(window, windowSizeCB);

    // ---

    auto clock = Clock.newClock(glfwGetTime());
    auto keyb = Keyboard.newKeyboard(window);
    auto mouse = Mouse.newMouse(window);
    auto cam = new Camera(0, 0, 1,cast(float)WIDTH, cast(float)HEIGHT);
    
    bool clicked;

    float[18] triVerts = [
        0.0f, 0.5f, 0.0f,  1.0f, 0.0f, 0.0f,
        -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,
        0.5f, -0.5f, 0.0f,  0.0f, 0.0f, 1.0f
    ];
    int[3] triInd = [0, 1, 2];
    auto triShader = new Shader("shaders\\default.vert", "shaders\\default.frag");
    auto triObj = new Obj(triVerts, triInd);
    auto triMatrix = Mat4.identity();

	while(!glfwWindowShouldClose(window))
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);

        glClearColor(0.5, 0.5, 0.5, 1.0);

        // ---

        clock.update(glfwGetTime());

        triShader.use();
        triShader.setMat4("model_Matrix", triMatrix);
        triShader.setMat4("cam_Matrix", cam.matrix());
        triObj.render();

        // ---

        if(keyb.keyState(GLFW_KEY_W) == KEY_HELD)
        {
            cam.transform(clock.dt, CAM_FORWARD);
        }

        if(keyb.keyState(GLFW_KEY_A) == KEY_HELD)
        {
            cam.transform(clock.dt, CAM_LEFT);
        }

        if(keyb.keyState(GLFW_KEY_S) == KEY_HELD)
        {
            cam.transform(clock.dt, CAM_BACKWARD);
        }

        if(keyb.keyState(GLFW_KEY_D) == KEY_HELD)
        {
            cam.transform(clock.dt, CAM_RIGHT);
        }

        if(mouse.buttonState(GLFW_MOUSE_BUTTON_LEFT) == BUTTON_HELD)
        {
            auto w = cast(float)WIDTH;
            auto h = cast(float)HEIGHT;

            if(clicked)
            {
                mouse.setCursorPosition(w / 2, h / 2);
                clicked = false;
            }
            
            auto rx = (mouse.y() - h / 2) / h;
            auto ry = (mouse.x() - w / 2) / w;
            cam.rotate(clock.dt, rx, ry);
        
            mouse.setCursorPosition(w / 2, h / 2);
        }
        else
        {
            clicked = true;
        }

        // ---

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
}
