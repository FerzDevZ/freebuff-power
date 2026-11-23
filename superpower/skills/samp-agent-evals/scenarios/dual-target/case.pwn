#if defined OMP_BUILD
    #include <open.mp>
#else
    #include <a_samp>
#endif

public OnGameModeInit()
{
    return 1;
}
