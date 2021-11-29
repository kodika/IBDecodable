cmake_minimum_required(VERSION 3.15.1)
list(APPEND CMAKE_MODULE_PATH $ENV{SWIFT_CORELIBS_JAVA_SRC}/cmake/modules)
include(SwiftSupport)

project(IBDecodable LANGUAGES Swift)

set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)
option(BUILD_SHARED_LIBS "build shared libraries" ON)

find_package(dispatch CONFIG REQUIRED)
find_package(Foundation CONFIG REQUIRED)


add_library(SWXMLHash
	SWXMLHash/Source/SWXMLHash.swift
	SWXMLHash/Source/XMLIndexer+XMLIndexerDeserializable.swift
	SWXMLHash/Source/shim.swift
)

target_link_libraries(SWXMLHash PUBLIC
	dispatch
	Foundation
)




file(GLOB_RECURSE SOURCES Sources/*.swift)

add_library(IBDecodable
	${SOURCES}
)

target_link_libraries(IBDecodable PUBLIC
	dispatch
	Foundation
	SWXMLHash
)

set_target_properties(IBDecodable PROPERTIES
  INSTALL_RPATH "$ORIGIN"
  Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/swift
)

_install_target(SWXMLHash)
_install_target(IBDecodable)

export( TARGETS SWXMLHash
  FILE SWXMLHashConfig.cmake
)

export( TARGETS IBDecodable
  FILE IBDecodableConfig.cmake
)
