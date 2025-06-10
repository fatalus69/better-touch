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

createFile :: proc(filename: string) {
    dir := filepath.dir(filename);
    if dir != "" {
        createDirectories(dir);
    }

    if os.is_file(filename) {
        if verbose == true {
            fmt.println("File", filename, "already exists. ")
        }
        // Still touch the file
        file, err := os.open(filename);
        if err == os.ERROR_NONE {
            fmt.println("Error touching file", filename);
            os.exit(1);    
        }
        os.close(file);
        return;
    }

    file, err := os.open(filename, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o644);
    if err != os.ERROR_NONE {
        fmt.println("Error creating file", filename);
        os.exit(1);
    }

    if verbose == true {
        fmt.println("Successfully created file", filename)
    }
    defer os.close(file);
}

updateAccessTime :: proc(filename: string) {
    if os.is_file(filename) {
        // Touch the file
        file, err := os.open(filename);
        if err != os.ERROR_NONE {
            fmt.println("Error updating access time for", filename);
            os.exit(1);
        }
        defer os.close(file);
        if verbose == true {
            fmt.println("Updated access time for", filename);
        }
    } else {
        createFile(filename);
    }
}

createDirectories :: proc(pathname: string) {
    parts := strings.split(pathname, string(filepath.SEPARATOR_STRING));
    current := "";

    if pathname[0] == filepath.SEPARATOR_STRING[0] {
        current = filepath.SEPARATOR_STRING;
    }

    for part in parts {
        if part == "" {
            continue;
        }

        current = filepath.join({current, part});

        if !os.is_file(current) {
            if os.is_dir(current) {
                continue;
            }
            
            if verbose == true {
                fmt.println("Creating directory", current);
            }

            err := os.make_directory(current, 0o755);
            if err != os.ERROR_NONE {
                fmt.println("Error creating directory", current);
                os.exit(1);
            }
        }
    }
}

error :: proc(message: string) {
    fmt.println(message);
    fmt.println("Try", NAME, "--help for more information");
    os.exit(1);
}

help :: proc() {
    fmt.println("HELP");
    os.exit(0);
}