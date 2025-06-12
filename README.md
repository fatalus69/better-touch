## <p style="text-align: center;">BETTER-TOUCH</p>

**A smarter `touch` command** — `better-touch` automatically creates any missing directories in the path before creating the file, so you don't have to.

#### Usage
`better-touch <filename>`

#### Installation

1. Download the latest release from the [Releases](https://github.com/fatalus69/better-touch/releases) page.

2. Extract the archive.
3. Move the binary to a directory in your `$PATH`, such as `/usr/local/bin`:

````sh
sudo mv ./better-touch /usr/local/bin/
````

#### Development
- Clone the project and build the binary
````sh
./build.sh
````
- To build the release version simply run
````sh
./build.sh --release
````
- And install it by running 
````sh
./installers/install.sh
````