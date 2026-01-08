#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"

int main(int argc, char **argv) {
    GO_REBUILD_URSELF(argc, argv);
    
    Nob_Cmd cmd = {0};

    cmd_append(&cmd, "cc");
    cmd_append(&cmd, "-Wall",  "-Wextra");
    cmd_append(&cmd, "-ggdb");
    cmd_append(&cmd, "-o", "main", "main.c");
    
    if (!cmd_run(&cmd)) return 1;

    return 0;
}