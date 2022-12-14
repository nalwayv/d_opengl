// App
import std.stdio : writeln;
import bindbc.opengl;
import bindbc.glfw;
import maths.utils;
import maths.mat4;
import maths.vec3;
import collision.broad.tree;
import collision.narrow.gjk;
import geometry.aabb;
import primitive.box;
import primitive.sphere;
import primitive.plane;
import primitive.capsule;
import model;
import clock;
import keyboard;
import mouse;
import camera;
import shadercache;


alias Tree = TreeTemplate!(Model).Tree;


enum WIDTH = 640;
enum HEIGHT = 480;


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

    const moveSp = 3.0f;
    bool clicked;
    bool debugMode = false;
    auto clock = Clock.newClock(glfwGetTime());
    auto keyb = Keyboard.newKeyboard(window);
    auto mouse = Mouse.newMouse(window);
    auto cam = new Camera(0, 0, 5, cast(float)WIDTH, cast(float)HEIGHT);


    auto shaderCache = new ShaderCache();
    shaderCache.add("default", "shaders\\default.vert", "shaders\\default.frag");


    auto boxPrimitive = new BoxMesh(2.0f, 2.0f, 2.0f, 1, 1, 1);
    auto spherePrimitive = new SphereMesh(1.0f, 1.0f, 10, 3);
    auto planePrimitive = new PlaneMesh(15.0f, 15.0f, 1, 1, PLANE_ORIENTATION_Y);


    auto shapeA = new Model(boxPrimitive.getPoints(), boxPrimitive.getIndices());
    shapeA.setColor(1, 0, 0);

    auto shapeB = new Model(spherePrimitive.getPoints(), spherePrimitive.getIndices());
    shapeB.setColor(0, 1, 0);
    shapeB.translate(5.0f, 0.0f, 0.0f);

    auto shapeC = new Model(planePrimitive.getPoints(), planePrimitive.getIndices());
    shapeC.translate(0.0f, -2.0f, 0.0f);


    auto tree = new Tree();
    auto aID = tree.add(shapeA.computeAABB(), shapeA);
    auto bID = tree.add(shapeB.computeAABB(), shapeB);
    auto cID = tree.add(shapeC.computeAABB(), shapeC);
    tree.valide();


	while(!glfwWindowShouldClose(window))
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        glClearColor(0.5, 0.5, 0.5, 1.0);
        if(debugMode)
        {
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        }
        else
        {
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }
        // ---

        clock.update(glfwGetTime());

        // ---
        // camera
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
        // update

        if(keyb.keyState(GLFW_KEY_F1) == KEY_PRESSED) 
        {
            debugMode = !debugMode;
        }

        if(keyb.keyState(GLFW_KEY_I) == KEY_HELD) 
        {
            shapeA.translate(0.0, 1.0 * moveSp * clock.dt, 0.0);
        }

        if(keyb.keyState(GLFW_KEY_K) == KEY_HELD) 
        {
            shapeA.translate(0.0, -1.0 * moveSp * clock.dt, 0.0);
        }

        if(keyb.keyState(GLFW_KEY_J) == KEY_HELD) 
        {
            shapeA.translate(-1.0 * moveSp * clock.dt, 0.0, 0.0);
        }

        if(keyb.keyState(GLFW_KEY_L) == KEY_HELD)
        {
            shapeA.translate(1.0 * moveSp * clock.dt, 0.0, 0.0);
        }

        if(keyb.keyState(GLFW_KEY_U) == KEY_HELD)
        {
            shapeA.translate(0.0, 0.0, 1.0 * moveSp * clock.dt);
        }

        if(keyb.keyState(GLFW_KEY_O) == KEY_HELD)
        {
            shapeA.translate(0.0, 0.0, -1.0 * moveSp * clock.dt);
        }
        
        auto ab = shapeA.computeAABB();
        tree.query(ab, (Model b) {
        
            auto gjk = new Gjk(shapeA, b);
            
            if(gjk.check())
            {
            
                Vec3 result;
            
                if(gjk.responce(result))
                {
                    shapeA.translate(result.negated());

                    return true;
                }
            }

            return false;
        });

        tree.move(ab, aID);
        tree.valide();

        // ---
        // render
        shapeA.render(shaderCache, cam);
        shapeB.render(shaderCache, cam);
        shapeC.render(shaderCache, cam);
        
        // ---
        // buffers
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwTerminate();
}
