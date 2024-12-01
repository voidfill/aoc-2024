# Advent of Code 2024 in Zig

My solutions to the [Advent of Code 2024](https://adventofcode.com/2024) in Zig.

Requires Zig master branch.

Uses [git-crypt](https://github.com/AGWA/git-crypt) to encrypt the inputs. If youd like to run a specific day, you will have to replace the input files with your own.

## Usage

Run the test inputs for all days:

```sh
zig build test --summary all
```

Run all days with real inputs:

```sh
zig build run
```

Run a specific day:

```sh
zig build run -Dday=1
```

For development, run in watch mode:

```sh
zig build test --watch
```
