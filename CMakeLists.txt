CMAKE_MINIMUM_REQUIRED(VERSION 2.8 FATAL_ERROR)
CMAKE_POLICY(VERSION 2.8)

SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake"
                      "${CMAKE_MODULE_PATH}")

FIND_PACKAGE(Torch REQUIRED)

include(cmake/USE_C99.cmake)
USE_C99()
set (CMAKE_C_FLAGS "-Wall -Wno-unused-variable ${CMAKE_C_FLAGS}")
set (CMAKE_C_FLAGS "-DCTRLC=1 -DLDL_LONG -DDLONG ${CMAKE_C_FLAGS}")

FILE(GLOB luasrc *.lua)
FILE(GLOB src
  *.c
  "${CMAKE_CURRENT_SOURCE_DIR}/ecos/src/*.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/ecos/external/amd/src/*.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/ecos/external/ldl/src/*.c"
)
LIST(REMOVE_ITEM src
  "${CMAKE_CURRENT_SOURCE_DIR}/ecos/src/runecos.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/ecos/src/runecos_exp.c"
)

INCLUDE_DIRECTORIES(
  GLOB "${CMAKE_CURRENT_SOURCE_DIR}/ecos/include/" *.h
  GLOB "${CMAKE_CURRENT_SOURCE_DIR}/ecos/external/SuiteSparse_config/" *.h
  GLOB "${CMAKE_CURRENT_SOURCE_DIR}/ecos/external/ldl/include/" *.h
  GLOB "${CMAKE_CURRENT_SOURCE_DIR}/ecos/external/amd/include/" *.h
)

ADD_TORCH_PACKAGE(ecos "${src}" "${luasrc}")