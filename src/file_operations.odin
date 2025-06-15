package main;

import "core:os"
import "core:fmt"
import "core:strings"
import "core:path/filepath"
import "core:c/libc"
import "core:strconv"

UTIME_NOW  :: -1;
UTIME_OMIT :: -2;

AT_FDCWD :: -100;

utimensat :: proc(pathname: cstring, times: ^libc.timespec) -> int

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
            fmt.println("Successfully created file", filename)
        }
        defer os.close(file);
    }
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
    error("Not implemented yet!");
    // time_value: string = time_string;
    // formatted_date: libc.tm = validateTimeAndFormat(time_value)

    // times: [2]libc.timespec;
    // times[0] = libc.timespec{tv_sec = libc.mktime(&formatted_date), tv_nsec = 0};

    //TODO: For future Windows release we have to check os.ARCH and do it like this for UNIX and another way for Windows
    // result := utimensat(cstring(alloc_cstring(filename)));
    // if result != 0 {
    //     error("failed to set time");
    // }
}

validateTimeAndFormat :: proc(time_string: string) -> (libc.tm) {
    //accept it ONLY as 2025-06-15T12:02:21 => ISO 8601
    if len(time_string) != 19 || time_string[10] != 'T' {
        error_arr: []string = {"Invalid timestamp ", strings.clone(time_string)};    
        error(strings.concatenate(error_arr[:]));
    }

    seperated_date: []string = strings.split(time_string, "T");
    date: string = seperated_date[0];
    date_time: string = seperated_date[1];

    split_date: []string = strings.split(date, "-");
    split_datetime: []string = strings.split(date_time, ":");

    tm := libc.tm{
        tm_year = convertStringToI32(split_date[0]) - 1900,
        tm_mon  = convertStringToI32(split_date[1]) - 1,
        tm_mday = convertStringToI32(split_date[2]),
        tm_hour = convertStringToI32(split_datetime[0]),
        tm_min  = convertStringToI32(split_datetime[1]),
        tm_sec  = convertStringToI32(split_datetime[2]),
        tm_isdst = -1,
    }

    return tm;
}

convertStringToI32 :: proc (data: string) -> i32 {
    converted, ok := strconv.parse_i64_maybe_prefixed(data);
    if !ok {
        error_arr: []string = {"Invalid number ", data};    
        error(strings.concatenate(error_arr[:]));
    }
    return i32(converted);
}