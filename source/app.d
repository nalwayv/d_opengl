// APP
import std.stdio : writeln;
import bindbc.opengl;
import bindbc.glfw;
import maths.utils;
import maths.mat4;
import maths.vec3;
import clock;
import keyboard;
import mouse;
import obj;
import shader;
import camera;
import transform;


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
    auto cam = new Camera(0, 0, 5, cast(float)WIDTH, cast(float)HEIGHT);

    bool clicked;

    // cube
    auto size = Vec3(2.0f, 2.0f, 2.0f);
    float[144] objVerts = [
        // front
         size.x,  size.y,  size.z, 0.0f, 0.0f, 1.0f,
        -size.x,  size.y,  size.z, 0.0f, 0.0f, 1.0f,
        -size.x, -size.y,  size.z, 0.0f, 0.0f, 1.0f,
         size.x, -size.y,  size.z, 0.0f, 0.0f, 1.0f,
        // right
         size.x,  size.y,  size.z, 1.0f, 0.0f, 0.0f,
         size.x, -size.y,  size.z, 1.0f, 0.0f, 0.0f,
         size.x, -size.y, -size.z, 1.0f, 0.0f, 0.0f,
         size.x,  size.y, -size.z, 1.0f, 0.0f, 0.0f,
        // top
         size.x,  size.y,  size.z, 0.0f, 1.0f, 0.0f,
         size.x,  size.y, -size.z, 0.0f, 1.0f, 0.0f,
        -size.x,  size.y, -size.z, 0.0f, 1.0f, 0.0f,
        -size.x,  size.y,  size.z, 0.0f, 1.0f, 0.0f,
        // left
        -size.x,  size.y,  size.z, 0.0f, 1.0f, 0.0f,
        -size.x,  size.y, -size.z, 0.0f, 1.0f, 0.0f,
        -size.x, -size.y, -size.z, 0.0f, 1.0f, 0.0f,
        -size.x, -size.y,  size.z, 0.0f, 1.0f, 0.0f,
        // bottom
        -size.x, -size.y, -size.z, 0.0f, 0.0f, 1.0f,
         size.x, -size.y, -size.z, 0.0f, 0.0f, 1.0f,
         size.x, -size.y,  size.z, 0.0f, 0.0f, 1.0f,
        -size.x, -size.y,  size.z, 0.0f, 0.0f, 1.0f,
        // back
         size.x, -size.y, -size.z, 1.0f, 0.0f, 0.0f,
        -size.x, -size.y, -size.z, 1.0f, 0.0f, 0.0f,
        -size.x,  size.y, -size.z, 1.0f, 0.0f, 0.0f,
         size.x,  size.y, -size.z, 1.0f, 0.0f, 0.0f
    ];

    int[36] objInd = [
        0,  1,  2,  2,  3,  0,
        4,  5,  6,  6,  7,  4,
        8,  9, 10, 10, 11,  8,
        12, 13, 14, 14, 15, 12,
        16, 17, 18, 18, 19, 16,
        20, 21, 22, 22, 23, 20
    ];

    auto objShader = new Shader("shaders\\default.vert", "shaders\\default.frag");
    auto obj = new Obj(objVerts, objInd);
    auto objTransform = Transform.newTransform(0.0f, 0.0f, 0.0f);

	while(!glfwWindowShouldClose(window))
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);

        glClearColor(0.5, 0.5, 0.5, 1.0);

        // ---

        clock.update(glfwGetTime());

        objTransform.rotate(toRad(15 * clock.dt), Vec3(0.2, 1, 0.5));

        objShader.use();
        objShader.setMat4("model_Matrix", objTransform.matrix());
        objShader.setMat4("cam_Matrix", cam.matrix());
        obj.render();

        // ---

        if(keyb.keyState(GLFW_KEY_W) == KEY_HELD)
        {
            cam.transform(CAM_FORWARD, clock.dt);
        }

        if(keyb.keyState(GLFW_KEY_A) == KEY_HELD)
        {
            cam.transform(CAM_LEFT, clock.dt);
        }

        if(keyb.keyState(GLFW_KEY_S) == KEY_HELD)
        {
            cam.transform(CAM_BACKWARD, clock.dt);
        }

        if(keyb.keyState(GLFW_KEY_D) == KEY_HELD)
        {
            cam.transform(CAM_RIGHT, clock.dt);
        }

        if(keyb.keyState(GLFW_KEY_Q) == KEY_HELD)
        {
            cam.zoom(CAM_IN, clock.dt);
        }

        if(keyb.keyState(GLFW_KEY_E) == KEY_HELD)
        {
            cam.zoom(CAM_OUT, clock.dt);
        }

        if(keyb.keyState(GLFW_KEY_R) == KEY_PRESSED)
        {
            cam.reset();
        }

        if(mouse.buttonState(GLFW_MOUSE_BUTTON_LEFT) == BUTTON_HELD)
        {
            mouse.hideCursor();

            if(clicked)
            {
                mouse.setCursorPosition(cast(float)WIDTH / 2, cast(float)HEIGHT / 2);
                clicked = false;
            }

            cam.rotate(mouse.x(), mouse.y(), clock.dt);
            mouse.setCursorPosition(cast(float)WIDTH / 2, cast(float)HEIGHT / 2);
        }
        else
        {
            mouse.showCursor();
            clicked = true;
        }

        // ---

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
}
