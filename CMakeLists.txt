cmake_minimum_required(VERSION 3.6)
project(SwiftLog)

#set(CMAKE_CXX_STANDARD 11)

#set(SOURCE_FILES main.cpp)
#add_executable(test ${SOURCE_FILES})

#add_custom_target(Hello
#        COMMAND /home/public/soft/swift-3.0-GM-CANDIDATE-ubuntu14.04/usr/bin/swift build
#        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
#        SOURCES Package.swift Sources/Formatter.swift Sources/Logger.swift Sources/LogTarget.swift)

set(FILES
        Package.swift
        Sources/Formatter.swift
        Sources/Logger.swift
        Sources/LogTarget.swift)

add_custom_target(swiftlog
        COMMAND /home/public/soft/swift-3.0-GM-CANDIDATE-ubuntu14.04/usr/bin/swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES ${FILES})