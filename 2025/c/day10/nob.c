#define NOB_IMPLEMENTATION
#define NOB_STRIP_PREFIX
#include "nob.h"

// gcc -o build/nob nob.c
int main(int argc, char **argv) {
    GO_REBUILD_URSELF(argc, argv);
    
    Nob_Cmd cmd = {0};
    if(!nob_file_exists("HiGHS")) {
        cmd_append(&cmd, "git", "clone", "https://github.com/ERGO-Code/HiGHS", "--depth=1");
        if (!cmd_run(&cmd)) return 1;
        
        nob_mkdir_if_not_exists("HiGHS/build");

        cmd.count = 0;
        cmd_append(&cmd, "cmake", "-S", "HiGHS", "-B", "HiGHS/build", "-DBUILD_SHARED_LIBS=ON");
        if (!cmd_run(&cmd)) return 1;

        cmd.count = 0;
        cmd_append(&cmd, "cmake", "--build", "HiGHS/build", "--parallel");
        if (!cmd_run(&cmd)) return 1;

        cmd.count = 0;
        cmd_append(&cmd, "sudo", "cp", "HiGHS/build/lib/libhighs.so.1", "/usr/lib");
        if (!cmd_run(&cmd)) return 1;

    }

    cmd.count = 0;
    cmd_append(&cmd, "cc");
    cmd_append(&cmd, "-Wall",  "-Wextra");
    cmd_append(&cmd, "-ggdb");
    cmd_append(&cmd, "-IHiGHS/highs");
    cmd_append(&cmd, "-IHiGHS/build");
    cmd_append(&cmd, "-LHiGHS/build/lib");
    cmd_append(&cmd, "-o", "build/main", "main.c");
    cmd_append(&cmd, "-lm");
    cmd_append(&cmd, "-lhighs");
    if (!cmd_run(&cmd)) return 1;

    return 0;
}