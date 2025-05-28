package main;

import "core:os"
import "core:fmt"
import "core:strings"
import "core:path/filepath"

verbose: bool = false;

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
        file, options: string;
        if strings.has_prefix(arg, "-") {
            options = arg;
        } else {
            file = arg;
        }
        createFile(file);
    }
}

createFile :: proc(filename: string) {
    dir := filepath.dir(filename);
    if dir != "" {
        createDirectories(dir);
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
            err := os.make_directory(current, 0o755);
            if err != os.ERROR_NONE {
                fmt.println("Error creating directory", current);
                os.exit(1);
            }
        }
    }
}