package main;

import "core:os"
import "core:fmt"
import "core:strings"

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