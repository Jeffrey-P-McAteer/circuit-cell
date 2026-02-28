
# Circuit Cell

C++ code for a thrilling spy adventure videogame!


# Dev Dependencies

```bash
sudo pacman -S cmake gcc qt6-3d
```

# Building

```bash
cmake -S . -B build-debug -DCMAKE_BUILD_TYPE=Debug

cmake --build build-debug

./build-debug/bin/circuit-cell
```

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release

cmake --build build

./build/bin/circuit-cell
```

# Version Data

Stored in 2 places:

 - `CMakeLists.txt` `project(...)` declaration - for C++ `APP_VERSION_*` macros
 - `.gitlab-ci.yml` `variables:` declaration - for release binary naming and tagging

For now I'll handle the fact that we must manually keep these in sync. Not ideal, but the engineering to make a single source of truth is too much work and complexity risk.




