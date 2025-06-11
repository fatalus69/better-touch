package main;

import "core:os"
import "core:fmt"
import "core:strings"
import "core:path/filepath"

VERSION :: "1.1.0";
NAME :: "better-touch";

verbose: bool = false;
access_time: bool = false;
modification_time: bool = false;
time: bool = false;

main :: proc() {
    if len(os.args) == 1 {
        fmt.println("Missing file operand");
        os.exit(1);
    }

    for arg, i in os.args {
        if i == 0 {
            continue;
        }

        if strings.has_prefix(arg, "-") {
            checkForOptions(arg, i);
        } else {
            filename: string = arg;
            if access_time == true {
                updateAccessTime(filename)
            } else {
                createFile(filename);
            }
        }
    }
}

checkForOptions :: proc(arg: string, index: int) {
    //todo: multiple options in one arg
    if (arg == "--help" || arg == "-h") {
        help();
        os.exit(0);
    } else if (arg == "--version" || arg == "-v") {
        fmt.println("better-touch", VERSION);
        os.exit(0);
    } else if (arg == "--verbose" || arg == "-V") {
        verbose = true;
        return;
    } else if (arg == "--access-time" || arg == "-a") {
        // isnt this the same as without any option?
        access_time = true;
        return;
    } else if (arg == "--time" || arg == "-t") {
        time = true;
        time_string : string = os.args[index];
        //TODO: Logic
    } else {
        string_arr: []string = {"Invalid option ", arg};
        error(strings.concatenate(string_arr[:]));
    }
}

error :: proc(message: string) {
    fmt.println(message);
    fmt.println("Try", NAME, "--help for more information");
    os.exit(1);
}

help :: proc() {
    fmt.println(NAME, VERSION);
    fmt.println("create a file and missing directories, like touch but smarter");
    fmt.println(NAME, "[OPTIONS] [FILENAME]");
    fmt.println("Filename:");
    fmt.println("The file to modify access times or create.");
    fmt.println("Options:");
    fmt.println("-h, --help");
    fmt.println("Show help.");
    fmt.println("-V, --version");
    fmt.println("Display current version.")
    fmt.println("-v, --verbose");
    fmt.println("Enable verbose output");
    fmt.println("-a, --access-time");
    fmt.println("Set access time to now.")
    fmt.println("-t [time], --time [time]");
    fmt.println("Set access time to a specific time.");

    os.exit(0);
}