package main;

import "core:os"
import "core:fmt"
import "core:strings"
import "core:path/filepath"

verbose: bool = false;
access_time: bool = false;
modification_time: bool = false;
time: bool = false;

main :: proc() {
    if len(os.args) == 1 {
        fmt.println("Missing file operand");
        os.exit(1);
    }

    first_arg_proccessed : bool = false;
    for arg in os.args {
        if first_arg_proccessed == false {
            first_arg_proccessed = true;
            continue;
        }
        file: string;
        if strings.has_prefix(arg, "-") {
            for char in arg {
                if char == '-' {
                    continue;
                }

                if char == 'v' {
                    verbose = true;
                } else {
                    fmt.println("Unrecognized option ", arg);
                    os.exit(1);
                }
                //TODO: Add functionality:
                // else if char == 'a' {
                //     access_time = true;
                // } else if char == 'm' {
                //     modification_time = true;
                // } else if char == 't' {
                //     time = true;
                // } 
            }
        } else {
            file = arg;
        }
        //default if there are no options present
        createFile(file);
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
        //update access time nonetheless
        file, err := os.open(filename);
        if err != os.ERROR_NONE {
            fmt.println("Error creating file", filename);
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