package main;

import "core:os"
import "core:fmt"
import "core:strings"
import "core:path/filepath"
import "core:c"
import "core:c/libc"
import "core:strconv"

// relative to this file
when ODIN_OS == .Linux do foreign import access_time_lib  "../build/libaccesstime.a"

foreign access_time_lib {
    // compiler complains without the 3 dashes
    setAccessTime :: proc(filepath: cstring, time_str: cstring) -> c.int ---
    setModificationTime :: proc(filepath: cstring, time_str: cstring) -> c.int ---
}

createFile :: proc(filename: string) {
    dir := filepath.dir(filename);
    if dir != "" && no_create == false {
        createDirectories(dir);
    }

    if os.is_file(filename) {
        if verbose == true {
            fmt.println("File", filename, "already exists. ")
        }
        // touch the file nonetheless
        file, err := os.open(filename);
        if err == os.ERROR_NONE {
            fmt.println("Error touching file", filename);
            os.exit(1);    
        }
        os.close(file);
        return;
    }

    if no_create == false {
        file, err := os.open(filename, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0o644);
        if err != os.ERROR_NONE {
            fmt.println("Error creating file", filename);
            os.exit(1);
        }
    
        if verbose == true {
            fmt.println("Successfully created file", filename);
        }
        defer os.close(file);
    }
}

updateAccessTime :: proc(filename: string) {
    if os.is_file(filename) {
        // Touch the file
        file, err := os.open(filename, os.O_RDONLY | os.O_WRONLY);
        defer os.close(file);
        
        if err != os.ERROR_NONE {
            fmt.println("Error updating access time for", filename);
            os.exit(1);
        }

        if verbose == true {
            fmt.println("Updated access time for", filename);
        }
    } else if no_create == false {
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

modifyAccessTime :: proc(filename: string, time_string: string) {
    filename_cstr := strings.clone_to_cstring(filename);
    time_string_cstr := strings.clone_to_cstring(time_string);
    defer delete(filename_cstr);
    defer delete(time_string_cstr);

    ok := setAccessTime(filename_cstr, time_string_cstr);
    if ok != 0 {
        error_arr: []string = {"Error setting access time for ", filename, " with time string ", time_string, "Please ensure the timestamp is in ISO 8601 format \"%Y-%m-%d %H:%M:%S\""};    
        error(strings.concatenate(error_arr[:]));
    }
}