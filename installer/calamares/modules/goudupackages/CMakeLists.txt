cmake_minimum_required(VERSION 3.16)
project(goudupackages CXX)

# Calamares' exported targets reference KF6::CoreAddons without find_package'ing
# it themselves (CalamaresConfig.cmake uses find_package(kf6 …) which doesn't
# match the per-component KF6 layout nixpkgs ships). Importing the target
# ourselves first satisfies the later link-interface check.
find_package(KF6CoreAddons REQUIRED)
find_package(Calamares REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick QuickWidgets)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# The module is loaded by Calamares via QPluginLoader at runtime; a plain
# MODULE library (not SHARED) is what Calamares expects.
add_library(calamares_viewmodule_goudupackages MODULE
    GoudupackagesViewStep.cpp
    GoudupackagesViewStep.h
)

# Calamares::calamaresui pulls in libcalamares and its Qt6 deps, and sets the
# include path to the installed libcalamares headers.
target_link_libraries(calamares_viewmodule_goudupackages
    PRIVATE
        Calamares::calamaresui
        Qt6::Core
        Qt6::Qml
        Qt6::Widgets
)

# MODULE targets default to no "lib" prefix on some platforms; Calamares loads
# the file by its verbatim name (see module.desc's `load:` key), so force it.
set_target_properties(calamares_viewmodule_goudupackages PROPERTIES
    PREFIX "lib"
)

install(TARGETS calamares_viewmodule_goudupackages
    LIBRARY DESTINATION lib/calamares/modules/goudupackages
)
