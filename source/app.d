// App
import std.stdio : writeln;
import bindbc.opengl;
import bindbc.glfw;
import maths.utils;
import maths.mat4;
import maths.vec3;
import collision.broad.abtree;
import collision.narrow.gjk;
import geometry.aabb;
import model;
import clock;
import keyboard;
import mouse;
import camera;
import shadercache;


alias Tree = TreeTemplate!(Model).ABTree;


enum WIDTH = 640;
enum HEIGHT = 480;


class Scene
{
    private
    {
        Tree tree;
    }

    this()
    {
        tree = new Tree();
    }

    int addModel(Model model)
    {
        auto id = tree.add(model.computeAABB(), model);
        tree.valide();
        return id;
    }

    void removeModel(int id)
    {
        tree.remove(id);
        tree.valide();
    }

    void updateModel(int id)
    {
        auto m = tree.getData(id);
        tree.move(m.computeAABB(), id);
        tree.valide();
    }

    void query(int id)
    {
        auto m = tree.getData(id);
        tree.query(m.computeAABB(), (Model b) {
            auto gjk = new Gjk(m, b);
            if(gjk.check())
            {
                auto cData = gjk.getCollisionData();
                Vec3 translateBy = cData.normal.scaled(cData.depth);
                m.translate(translateBy);
                return true;
            }
            return false;
        });
    }
}


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

    auto clock = Clock.newClock(glfwGetTime());
    auto keyb = Keyboard.newKeyboard(window);
    auto mouse = Mouse.newMouse(window);
    auto cam = new Camera(0, 0, 5, cast(float)WIDTH, cast(float)HEIGHT);

    // shaders
    auto shaderCache = new ShaderCache();
    shaderCache.add("default", "shaders\\default.vert", "shaders\\default.frag");

    // // model
    auto cubeA = new Model("models\\cube");
    cubeA.setColor(1, 0, 0);

    auto cubeB = new Model("models\\cube");
    cubeB.scale(1.1f, 1.1f, 1.1f);
    cubeB.translate(5.0f, 0.0f, 0.0f);
    cubeB.setColor(0, 1, 0);

    Scene scene = new Scene();
    auto aID = scene.addModel(cubeA);
    auto bID = scene.addModel(cubeB);

	while(!glfwWindowShouldClose(window))
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        glClearColor(0.5, 0.5, 0.5, 1.0);

        // ---

        clock.update(glfwGetTime());

        // ---

        cubeA.render(shaderCache, cam);
        cubeB.render(shaderCache, cam);

        // ---

        scene.query(aID);
        scene.updateModel(aID);
        scene.updateModel(bID);

        // ---

        if(keyb.keyState(GLFW_KEY_UP) == KEY_HELD) 
        {
            cubeA.translate(0.0, 1.0 * moveSp * clock.dt, 0.0);
        }

        if(keyb.keyState(GLFW_KEY_DOWN) == KEY_HELD) 
        {
            cubeA.translate(0.0, -1.0 * moveSp * clock.dt, 0.0);
        }

        if(keyb.keyState(GLFW_KEY_LEFT) == KEY_HELD) 
        {
            cubeA.translate(-1.0 * moveSp * clock.dt, 0.0, 0.0);
        }

        if(keyb.keyState(GLFW_KEY_RIGHT) == KEY_HELD)
        {
            cubeA.translate(1.0 * moveSp * clock.dt, 0.0, 0.0);
        }

        if(keyb.keyState(GLFW_KEY_RIGHT) == KEY_HELD)
        {
            cubeA.translate(1.0 * moveSp * clock.dt, 0.0, 0.0);
        }

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
