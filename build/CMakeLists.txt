cmake_minimum_required(VERSION 3.8)
project(MultiArch)

set (CMAKE_CXX_STANDARD 11)
set(bd ${CMAKE_CURRENT_LIST_DIR}/../)
set(sd ${bd}/src)

include_directories(
  ${sd}
  )

list(APPEND lib_sources
  ${sd}/MyLib.cpp
  )

message("CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")

find_library(fr_corefoundation CoreFoundation)
list(APPEND libs
  ${fr_corefoundation}
  )

find_library(fr_carbon Carbon)
list(APPEND libs
  ${fr_carbon}
  )
   
add_library(multiarch${debug_flag} STATIC ${lib_sources})
install(TARGETS multiarch${debug_flag} DESTINATION lib)
target_link_libraries(multiarch${debug_flag} ${libs})

macro(create_test name)
  set(test_name "test_${name}${debug_flag}")
  add_executable(${test_name} ${sd}/test/test_${name}.cpp)
  target_link_libraries(${test_name}  multiarch${debug_flag} ${libs})
  install(TARGETS ${test_name} DESTINATION bin/)
endmacro()

create_test("multi_arch")