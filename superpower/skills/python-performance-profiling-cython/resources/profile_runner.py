import cProfile
import pstats

def run_profile(fn):
    profiler = cProfile.Profile()
    profiler.enable()
    fn()
    profiler.disable()
    stats = pstats.Stats(profiler).sort_stats('cumtime')
    stats.print_stats(10)
