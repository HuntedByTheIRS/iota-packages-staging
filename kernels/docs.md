# Prometheus — Linux Kernel Build Tool

<!--toc:start-->
- [Prometheus — Linux Kernel Build Tool](#prometheus-linux-kernel-build-tool)
  - [Surface-Level Usage](#surface-level-usage)
    - [Synopsis](#synopsis)
    - [Actions](#actions)
    - [Options](#options)
    - [Selecting a Kernel](#selecting-a-kernel)
    - [Config File Format](#config-file-format)
      - [Tags](#tags)
    - [Directory Layout](#directory-layout)
    - [Practical Examples](#practical-examples)
    - [Exit Codes](#exit-codes)
  - [Internals](#internals)
    - [Architecture](#architecture)
    - [Module Breakdown](#module-breakdown)
      - [`main.v` — Entry & Config Resolution](#mainv-entry-config-resolution)
      - [`user/args.v` — CLI Parsing](#userargsv-cli-parsing)
      - [`parser/parser.v` — Config File Reader](#parserparserv-config-file-reader)
      - [`build/builder.v` — Build Pipeline](#buildbuilderv-build-pipeline)
        - [`build_kernel()` — Action Dispatcher](#buildkernel-action-dispatcher)
        - [`run_build()` — Kernel Build Pipeline](#runbuild-kernel-build-pipeline)
        - [`run_install()` / `run_uninstall()`](#runinstall-rununinstall)
        - [Utility Functions](#utility-functions)
        - [Signal Safety](#signal-safety)
    - [Error Handling](#error-handling)
    - [Optimisations](#optimisations)
    - [Security](#security)
<!--toc:end-->

Prometheus automates downloading, configuring, building, and installing Linux kernels from
declarative config files. Written in V.

---

## Surface-Level Usage

### Synopsis

```
prometheus [--force-modules] [--jobs=N] <action> [<kernel[@version]> ...]
```

### Actions

| Action         | Description |
|----------------|-------------|
| `build`        | Download, configure, and compile the kernel |
| `install`      | Install a previously built kernel |
| `makeinstall`  | Build + install in one step |
| `uninstall`    | Uninstall a kernel (from its build directory) |
| `list`         | List configured kernels in `/var/cache/prometheus/` |
| `remove`       | Remove a kernel config file from `/var/cache/prometheus/` |
| `update`       | Update the version string in a config file |
| `remote`       | Remote repository subcommands (search, fetch, reveal, update, set) |

### Options

| Option             | Description |
|--------------------|-------------|
| `--force-modules`  | Force rebuild of kernel modules |
| `--jobs=N`         | Override `make -j` with N parallel jobs (1–255) |

### Selecting a Kernel

Config files live in `/var/cache/prometheus/`. You refer to them in two ways:

**Bare name** — looks for `<name>.conf`:

```
prometheus build linux-zen
```

**`name@version`** — searches all `.conf` files for matching `%NAME%` and `%VERSION%`:

```
prometheus build linux-zen@7.1.3
prometheus makeinstall linux-zen@7.1.3
prometheus update linux-zen@7.1.3 7.1.4

**Remote** — see [Remote Repository](#remote-repository) section:
```
prometheus remote set <url>
prometheus remote search <query>
prometheus remote fetch <path>
```

### Config File Format

A config file is a plain text file with `%TAG%` markers. Example (`linux-zen.conf`):

```
%NAME%
linux-zen

%VERSION%
7.1.3

%SOURCE-DIR%
linux-{VERSION}

%KERNEL-SOURCE%
https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-{VERSION}.tar.xz

%EXTERNAL-SOURCES%
https://github.com/zen-kernel/zen-kernel/releases/download/v{VERSION}-zen1/linux-v{VERSION}-zen1.patch.zst

%CONFIG%
defconfig

%MAKEOPTS%
-j2

%PREPARE%
unzstd linux-v{VERSION}-zen1.patch.zst

%PATCH%
linux-v{VERSION}-zen1.patch

%BUILD%
make

%INSTALL-MODULES%
true

%INSTALL%
make install
```

#### Tags

| Tag                  | Required | Description |
|----------------------|----------|-------------|
| `%NAME%`             | yes      | Kernel identifier (e.g. `linux-zen`) |
| `%VERSION%`          | yes      | Version string (e.g. `7.1.3`) |
| `%SOURCE-DIR%`       | yes      | Subdirectory inside the tarball (supports `{VERSION}`) |
| `%KERNEL-SOURCE%`    | yes      | URL to the kernel tarball |
| `%EXTERNAL-SOURCES%` | no       | Additional files to download (patches, etc.) |
| `%CONFIG%`           | no       | `make` target to generate `.config` (e.g. `defconfig`) |
| `%MAKEOPTS%`         | no       | Extra flags passed to each build command |
| `%PREPARE%`          | no       | Shell commands run before patching (e.g. `unzstd`) |
| `%PATCH%`            | no       | Patch files to apply with `patch -p1` |
| `%BUILD%`            | yes      | Shell commands to compile the kernel |
| `%INSTALL-MODULES%`      | no       | Run `make modules_install` after build (`true`/`false`) |
| `%INSTALL%`              | no       | Shell commands to install the kernel (e.g. `make install`) |
| `%IGNORE-KERNEL-SOURCE%` | no       | Skip kernel source download; run build commands directly in the temp dir (`true`/`false`) |

`{VERSION}` in any field is replaced with the value of `%VERSION%` at parse time.

### Directory Layout

| Path | Purpose |
|------|---------|
| `/var/cache/prometheus/` | Config files (`.conf`) |
| `/var/cache/prometheus-tmp/<name>-<version>/` | Build directory (auto-created, cleaned after build except for `install`) |

### Practical Examples

```bash
# Show available kernels
prometheus list

# Build linux-zen from linux-zen.conf
prometheus build linux-zen

# Build with 8 parallel jobs
prometheus build --jobs=8 linux-zen

# Update a config file's version
prometheus update linux-zen 7.1.4
prometheus update linux-zen@7.1.3 7.1.4

# Build and install in one shot
prometheus makeinstall linux-zen@7.1.4

# Remove a kernel config (by name or name@version)
prometheus remove linux-zen
prometheus remove linux-zen@7.1.3

# Set the remote repository URL
prometheus remote set https://example.com/kernel-remote

# Search for kernels matching a query
prometheus remote search linux-zen

# Search by tag
prometheus remote search tags=zen

# Search by category
prometheus remote search categories=patched

# Fetch a kernel config from the remote (by path or name@version)
prometheus remote fetch patched/zen/linux-zen-latest.conf
prometheus remote fetch linux-zen@7.1.3

# View a remote config without downloading
prometheus remote reveal patched/zen/linux-zen-latest.conf
prometheus remote reveal linux-zen@7.1.3

# Regenerate db.conf (run in the root of a remote repository)
prometheus remote update
```

### Exit Codes

| Code | Meaning |
|------|---------|
| 0    | Success |
| 1    | Any error (invalid args, build failure, missing config, etc.) |

---

## Remote Repository

Prometheus can operate with remote kernel repositories. A remote is an HTTP(S)-hosted
directory of kernel config files with a database index (`db.conf`) at the root.

### Directory Structure

```
remote-root/
  db.conf                  ← database index (see below)
  patched/                 ← category
    zen/                   ← tag
      linux-zen-latest.conf
  vanilla/                 ← category
    latest/                ← tag
      some-kernel.conf
```

### `db.conf` Format

A database file is a sequence of entries. Each entry starts with the config file's
relative path inside `%` markers, followed by metadata fields:

```
%patched/zen/linux-zen-latest.conf%
VERSION=7.1.3
NAME=linux-zen
TAGS=[zen]
CATEGORIES=[patched]
EXTERNAL_SOURCES=true
IGNORE_KERNEL_SOURCE=false

%vanilla/latest/some-kernel.conf%
VERSION=6.14.7
NAME=some-kernel
TAGS=[latest]
CATEGORIES=[vanilla]
EXTERNAL_SOURCES=false
IGNORE_KERNEL_SOURCE=false
```

| Field                  | Description |
|------------------------|-------------|
| `%<relative_path>%`    | Path from the db.conf root to the `.conf` file |
| `VERSION`              | Kernel version string |
| `NAME`                 | Kernel name |
| `TAGS`                 | Comma-separated tag list in `[brackets]` |
| `CATEGORIES`           | Comma-separated category list in `[brackets]` |
| `EXTERNAL_SOURCES`     | Whether the config uses external sources (`true`/`false`) |
| `IGNORE_KERNEL_SOURCE` | When `true`, the build runs with no kernel source — commands execute directly in the temp directory |

### Remote Subcommands

| Subcommand | Description |
|---|---|
| `remote set <url>` | Write the remote URL to `/var/cache/prometheus/remote.conf` |
| `remote search [query]` | Fetch `db.conf` from the remote and search by name, version, or path |
| `remote search name@version` | Exact match by kernel name and version |
| `remote search tags=tag1,tag2` | Filter search results by tag (OR logic) |
| `remote search categories=cat1,cat2` | Filter search results by category (OR logic) |
| `remote fetch <path>` | Download a config file from the remote to `/var/cache/prometheus/` |
| `remote fetch <name@version>` | Look up the path in db.conf, then download |
| `remote reveal <path>` | Print a remote config file's contents without downloading |
| `remote reveal <name@version>` | Look up the path in db.conf, then reveal |
| `remote update` | Walk the current directory, regenerate `db.conf` (add new `.conf` files, remove stale entries) |

### `IGNORE_KERNEL_SOURCE` Build Mode

When `IGNORE_KERNEL_SOURCE=true` (either in a config file's `%IGNORE-KERNEL-SOURCE%`
tag or in a remote `db.conf` entry), the build pipeline changes:

| Step | Normal Mode | `IGNORE_KERNEL_SOURCE` Mode |
|------|-------------|-----------------------------|
| Kernel source download | Downloaded and extracted | Skipped |
| External sources | Downloaded | Skipped |
| Patching | Applied in kernel tree | Skipped |
| Configure (`defconfig`, etc.) | Run in kernel tree | Skipped |
| `%PREPARE%` commands | Run in build dir | Run in build dir |
| `%BUILD%` commands | Run in kernel source subdir | **Run in build dir** |
| `%INSTALL%` commands | Run in kernel source subdir | **Run in build dir** |
| `modules_install` | Run if `%INSTALL-MODULES%` is true | Skipped |

This mode is useful for custom build instructions, meta-packages, or any config
that does not use a standard kernel source tree.

---

## Internals

### Architecture

Prometheus is organised into five modules:

```
prometheus/
  main.v              Entry point, config resolution, file update, remote routing
  build/builder.v     Build orchestration, kernel operations, utility functions
  user/args.v         CLI argument parsing
  parser/parser.v     Config file parser, {VERSION} substitution
  remote/remote.v     Remote repository operations (db.conf parser, search, fetch, update)
```

### `remote/remote.v` — Remote Repository

The remote module handles all `prometheus remote <subcommand>` invocations:

- **`handle_set()`** — writes the remote URL to `/var/cache/prometheus/remote.conf`.
- **`handle_search()`** — fetches `db.conf` from the remote URL, parses the entry-based
  format, and filters by text query, tags (`tags[...]`), or categories (`categories[...]`).
  Output is `<relative-path> (<name>@<version>)`.
- **`handle_fetch()`** — downloads a config file from the remote to the config directory,
  extracting the filename from the remote path.
- **`handle_reveal()`** — fetches a config file from the remote and prints its contents.
- **`handle_update()`** — walks the current directory recursively for `.conf` files,
  derives tags/categories from the directory structure (`<category>/<tag>/<file>.conf`),
  reads existing `db.conf` to preserve known entries, merges new entries from parsed
  `.conf` files, removes stale entries, and writes the updated `db.conf`.
- **`parse_db()`** — parses the db.conf entry-based format into `DbEntry` structs.
- **`find_conf_files()`** — recursive directory walk for `.conf` files, skipping `db.conf`.

### Module Breakdown

#### `main.v` — Entry & Config Resolution

`main()` runs first:

1. **Argument parsing** — calls `user.define_args()` which returns an `Arguments` struct. On failure, prints help and exits with code 1.
2. **Config directory** — `ensure_config_dir()` creates `/var/cache/prometheus/` if missing.
3. **Action routing**:
   - `list`/`search` → passes an empty config to `build.build_kernel()` which dispatches internally.
   - `update` → resolves the config file path via `resolve_config_path()`, then calls `update_version_in_file()` to replace the `%VERSION%` value.
   - `remote` → dispatches to the `remote` module's handler based on the subcommand.
   - `build`/`install`/`makeinstall`/`uninstall` → loads the `KernelConfig` via `load_kernel_config()`, then calls `build.build_kernel()`.

**Config resolution** (`load_kernel_config()`):

- If the user passed `name@version`: iterates every `.conf` in the config directory, parses each, and returns the first match for both `%NAME%` and `%VERSION%`.
- If the user passed a bare name: validates the name via `safe_config_path()` (rejects `..` and `/`), then reads `<name>.conf` directly.
- On parse failure: builds an error message listing all available `.conf` files via `list_available_configs()`.

**Security**: `safe_config_path()` prevents path traversal by rejecting kernel names containing `..` or `/`. Both `load_kernel_config()` and `resolve_config_path()` (used by `update`) gate through this function.

#### `user/args.v` — CLI Parsing

`define_args()` processes `os.args`:

1. **Flag filtering** — iterates arguments once, stripping `--force-modules` and `--jobs=N` into the `Arguments` struct. Everything else stays in the positional list.
2. **Action parsing** — `Action.from_string(args[1])` maps the verb to the `Action` enum.
3. **Kernel reference** — `parse_kernel_reference()` splits on `@`:
   - `name@version` → validates neither part is empty, validates the name contains no path traversal chars.
   - bare name → used directly as `file_name`.
4. **Update-specific** — the `update` action requires a fourth argument (`new_version`).

**Optimisations**: `trim_space()` is hoisted to the top of `parse_kernel_reference()` instead of being called in each branch. `_unlikely_()` hints wrap validation checks (empty parts, path traversal).

#### `parser/parser.v` — Config File Reader

`parse_file()` reads a `.conf` file line by line:

1. Lines starting and ending with `%` are treated as tag headers.
2. All subsequent non-empty lines until the next tag are collected as that tag's value.
3. `save_tag_data()` maps each tag to the `KernelConfig` struct field.
4. After all tags are read, `substitute_version_vars()` replaces every `{VERSION}` in every field with the actual version string.

**Multi-line tags**: `%EXTERNAL-SOURCES%`, `%PREPARE%`, `%PATCH%`, `%BUILD%`, and `%INSTALL%` support multiple lines (stored as `[]string`). Single-value tags (`%NAME%`, `%VERSION%`, etc.) join lines with `\n`.

#### `build/builder.v` — Build Pipeline

This is the core module. It exports a single public function `build_kernel()`.

##### `build_kernel()` — Action Dispatcher

The orchestrator. After handling `list`/`search` (which return early), it:

1. Prints the action and kernel header with coloured output.
2. Checks `/boot` mount status via `check_boot_mount()` (warning only, non-fatal).
3. Computes `build_dir = /var/cache/prometheus-tmp/<name>-<version>`.
4. Applies `--jobs=N` override via `override_makeopts_jobs()` if the flag was given.
5. Registers a `defer { cleanup_build_dir(build_dir) }` for `build` and `makeinstall` actions — this runs on both success and error paths.
6. Dispatches to the matching action handler.

**Makeopts override** (`override_makeopts_jobs()`): Scans `config.makeopts` for an existing `-j` flag at a word boundary (preceded by space or at string start). If found, validates that the characters following `-j` are all digits before replacing the numeric value. If not found or invalid, appends `-j<N>`. This correctly handles edge cases like `-joops` (appends a fresh flag instead of corrupting the string).

##### `run_build()` — Kernel Build Pipeline

The pipeline branches on `config.ignore_kernel_source`:

**Normal mode** (`ignore_kernel_source=false`, default):

```
validate_kernel_config()         — checks name/version/source are non-empty + no path traversal
ensure_build_dir()               — creates build dir if missing
download_source_file()           — wgets kernel tarball if not already present
download_source_file() (loop)    — wgets each external source (patches, etc.)
extract_archive()                — auto-detects format (.tar.xz, .tar.gz, .tar.bz2, .tar.zst, .tar, .zip)
run_prepare_commands()           — runs %PREPARE% steps (e.g. unzstd)
apply_patch_files()              — applies each %PATCH% with patch -p1
run_config_target()              — runs %CONFIG% target (e.g. make defconfig)
run_build_commands()             — runs each %BUILD% command with makeopts appended
run_module_install()             — make modules_install (if %INSTALL-MODULES% is true)
```

**Ignore-Kernel-Source mode** (`ignore_kernel_source=true`):

```
validate_kernel_config()         — does not require kernel_source URL
ensure_build_dir()               — creates build dir if missing
run_prepare_commands()           — runs %PREPARE% steps in build_dir
run_build_commands()             — runs each %BUILD% command in build_dir (no source subdir)
```

In this mode the build commands execute directly in the temp directory without a
kernel source tree. Useful for custom build instructions where `%KERNEL-SOURCE%` is
not applicable.

##### `run_install()` / `run_uninstall()`

- `run_install()`: Validates the working directory exists (source subdir in normal mode, build dir in `IGNORE_KERNEL_SOURCE` mode), then runs each `%INSTALL%` command.
- `run_uninstall()`: If the build directory still exists, runs `make uninstall` from it. Otherwise prints a not-yet-implemented message.

##### Utility Functions

| Function | Role | Inline |
|----------|------|--------|
| `exec_cmd()` | Wraps `os.system()`, returns error on non-zero exit. All shell commands flow through this. | `@[inline]` |
| `cleanup_build_dir()` | `os.rmdir_all()` with a warning on failure | `@[inline]` |
| `extract_archive()` | Detects archive type by extension and runs the correct extraction command | — |
| `check_boot_mount()` | Checks `/boot`, `/boot/efi`, `/efi` via `mountpoint -q` | — |

##### Signal Safety

`SIGINT` kills the child process (via `os.system()`), which causes `exec_cmd()` to see a non-zero exit, triggers the `or` error handler in `build_kernel`, which propagates the error. The `defer { cleanup_build_dir(build_dir) }` fires, removing the temp directory. `SIGKILL`/`SIGSEGV` cannot be caught — in those cases the temp dir may persist.

### Error Handling

All fallible operations use V's `!` (optional error) return type and propagate upward:

```
exec_cmd() → run_build() → build_kernel() → main() → exit(1)
```

At each level, the caller either handles the error (`or` block printing a coloured message) or re-propagates it with `!`. The `defer` for cleanup runs regardless of the exit path, so build directories are always cleaned on failure (for `build`/`makeinstall`).

### Optimisations

**Inlining**: Six hot-path or tiny functions are marked `@[inline]` — `exec_cmd`, `cleanup_build_dir`, `ensure_build_dir`, `validate_kernel_config`, `run_config_target`, `ensure_config_dir`.

**Branch prediction**: `_unlikely_()` hints are placed on:

- Command failures (`exec_cmd`) — almost all shell commands succeed.
- Validation failures — empty fields, path traversal chars, missing directories.
- `_likely_()` on existing files (`download_source_file`) — files persist between rebuilds.
- `_likely_()` on `install_modules` — most kernel configs install modules.

**Duplicate work eliminated**:

- `download_source_file()` caches `dest_path` instead of recomputing `os.join_path`.
- `parse_kernel_reference()` trims once at the top.
- `list_available_configs()` eliminates duplicated "list .conf files" blocks.

### Security

| Protection | Location | Mechanism |
|---|---|---|
| Config path traversal | `safe_config_path()` | Rejects `..` and `/` in `file_name` before constructing path |
| CLI arg traversal | `parse_kernel_reference()` | Same check on kernel name from CLI args |
| Build dir traversal | `validate_name_component()` | Rejects `..` and `/` in `config.name` and `config.version` |
| Config dir creation | `ensure_config_dir()` | Created with system default permissions under `/var/cache/` |

Config files are trusted (written by the user to `/var/cache/prometheus/`), so their contents (shell commands in `%BUILD%`, `%PREPARE%`, etc.) are executed as-is via `os.system()`.
