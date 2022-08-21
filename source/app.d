// APP
import std.stdio : writeln;
import bindbc.opengl;
import bindbc.glfw;
import maths.mat4;
import clock;
import keyboard;
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
    auto kb = Keyboard.newKeyboard(window);
    
    float[18] triVerts = [
        0.0f, 0.5f, 0.0f,  1.0f, 0.0f, 0.0f,
        -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,
        0.5f, -0.5f, 0.0f,  0.0f, 0.0f, 1.0f
    ];
    int[3] triInd = [0, 1, 2];
    auto triShader = new Shader("shaders\\default.vert", "shaders\\default.frag");
    auto triObj = new Obj(triVerts, triInd);
    auto triMatrix = Mat4.identity();
    auto cam = new Camera(0.0f, 0.0f, 3.0f, cast(float)WIDTH, cast(float)HEIGHT);

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

        if(kb.getState(GLFW_KEY_W) == KEY_HELD)
        {
            cam.translateIn(clock.dt);
        }

        if(kb.getState(GLFW_KEY_A) == KEY_HELD)
        {
            cam.translateLeft(clock.dt);
        }

        if(kb.getState(GLFW_KEY_S) == KEY_HELD)
        {
            cam.translateOut(clock.dt);
        }

        if(kb.getState(GLFW_KEY_D) == KEY_HELD)
        {
            cam.translateRight(clock.dt);
        }

        if(kb.getState(GLFW_KEY_Q) == KEY_HELD)
        {
            cam.translateUp(clock.dt);
        }

        if(kb.getState(GLFW_KEY_E) == KEY_HELD)
        {
            cam.translateDown(clock.dt);
        }

        // ---

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
}
