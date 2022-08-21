/// Clock
module clock;


enum double DELTA = 1.0/60.0;


struct Clock
{
    double dt;
    double lastStep;
    double accumalate;

    /// init a new clock struct
    /// Returns: Clock
    static Clock newClock(double glfwTime)
    {
        Clock result;

        result.dt = DELTA;
        result.lastStep = glfwTime;
        result.accumalate = 0.0;

        return result;
    }

    void update(double glfwTime)
    {
        auto currentStep = glfwTime;
        auto ellapsed = currentStep - lastStep;

        lastStep = currentStep;
        accumalate += ellapsed;

        while(accumalate >= dt)
        {
            accumalate -= dt;
        }
    }
}