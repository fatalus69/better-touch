package main;

import "core:os"
import "core:fmt"
import "core:strings"
import "core:path/filepath"

VERSION :: "1.2.0";
NAME :: "better-touch";

verbose: bool = false;
access_time: bool = false;
modification_time: bool = false;
time: bool = false;
no_create: bool = false;

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
            checkForOptions(arg);
        } else {
            filename: string = arg;
            if time == true{
                modifyAccessTime(filename, os.args[i]);
            } else {
                updateAccessTime(filename);
            }
        }
    }
}

checkForOptions :: proc(arg: string) {
    if strings.has_prefix(arg, "--") {
        if arg == "--help" {
            help();
            os.exit(0);
        } else if arg == "--version" {
            fmt.println("better-touch", VERSION);
            os.exit(0);
        } else if arg == "--verbose" {
            verbose = true;
        } else if arg == "--access-time" && modification_time == false {
            access_time = true;
        } else if arg == "--modification_time" && access_time == false {
            modification_time = true;
        } else if arg == "--time" {
            time = true;
        } else if arg == "--no-create" {
            no_create = true;
        } else {
            string_arr: []string = {"Invalid option ", arg};
            error(strings.concatenate(string_arr[:]));
        }
        return;
    }

    // Print out error in an else case for modification and access time 
    if strings.has_prefix(arg, "-") {
        for i in 1..<len(arg) {
            switch arg[i] {
            case 'h':
                help();
                os.exit(0);
            case 'v':
                fmt.println("better-touch", VERSION);
                os.exit(0);
            case 'V':
                verbose = true;
            case 'a':
                if modification_time != true {
                    access_time = true;
                }
            case 'm':
                if access_time == true {
                    modification_time = true;
                }
            case 't':
                time = true;
            case 'c':
                no_create = true;
            case:
                string_arr: []string = {"Invalid option ", arg};
                error(strings.concatenate(string_arr[:]));
            }
        }
    }

    string_arr: []string = {"Invalid option ", arg};
    error(strings.concatenate(string_arr[:]));
}

error :: proc(message: string) {
    fmt.println(message);
    fmt.println("Try", NAME, "--help for more information");
    os.exit(1);
}

help :: proc() {
    fmt.println(
        NAME, " ", VERSION, "\n",
        "A smarter alternative to 'touch' — creates files and missing directories.\n",
        "\n",
        "Usage:\n",
        "\t", NAME, " [OPTIONS] [FILENAME]...\n",
        "\n",
        "Filename:\n",
        "\tSpecify the file whose access time should be modified, or which should be created.\n",
        "\n",
        "Options:\n",
        "\t-h, --help\n",
        "\t\tShow this help message.\n",
        "\t-V, --version\n",
        "\t\tDisplay the current version.\n",
        "\t-v, --verbose\n",
        "\t\tEnable verbose output.\n",
        "\t-a, --access-time\n",
        "\t\tSet the access time to now.\n",
        "\t-t [time], --time [time]\n",
        "\t\tSet the access time to a specific time in ISO 8601 format. (%Y-%m-%d %H:%M:%S)\n",
        "\t-m [time], --modification_time [time]\n",
        "\t\tSet the modification time to a specific time in ISO 8601 format. (%Y-%m-%d %H:%M:%S)\n",
        "\t-c, --no-create\n",
        "\t\tDon't create a file if it does not exist.\n"
    );
    os.exit(0);
}
