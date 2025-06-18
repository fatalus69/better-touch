# BETTER-TOUCH

**A smarter `touch` command** — `better-touch` automatically creates any missing directories in the path before creating the file, so you don't have to.

## Usage
`better-touch [OPTIONS] [FILENAME]...`

| Option                       | Description                                                                     |
| ---------------------------- | ------------------------------------------------------------------------------- |
| `-h`, `--help`               | Show this help message and exit                                                 |
| `-V`, `--version`            | Show the current version                                                        |
| `-v`, `--verbose`            | Enable verbose output                                                           |
| `-a`, `--access-time`        | Set the access time of the file to now                                          |
| `-t [time]`, `--time [time]` | Set access time using ISO 8601 format (planned feature) |
| `-c`, `--no-create`          | Don't create the file if it doesn't exist                                       |

> [!CAUTION]
> The `--time` option is currently **not implemented**, due to language-level limitations. It may be added in a future update.


## Installation

1. Download the latest release from the [Releases](https://github.com/fatalus69/better-touch/releases) page.

2. Extract the archive.
3. Run the install script:

````sh
bash installers/install.sh
````
This installs the binary to `/usr/local/bin/` and installs the man page.

## Development
- Clone the project and build the binary
````sh
bash build.sh
````
- To build the release version simply run
````sh
bash build.sh --release
````
<br>

> [!NOTE]
> This is a hobby-project and may contain bugs or incomplete features.