cmake_minimum_required(VERSION 3.10)
project(KernelMain)


set(CMAKE_C_STANDARD 11)

set(CMAKE_EXE_LINKER_FLAGS "-Tconfiguration/linker/link.ld")

enable_language(ASM_NASM)

file(GLOB_RECURSE ASM_AMD64_SOURCES src/amd64/*.asm)
file(GLOB_RECURSE ASM_I386_SOURCES src/i386/*.asm)

file(GLOB_RECURSE DEF_I386_FILES src/i386/clanguages/*.h*)
file(GLOB_RECURSE DEF_AMD64_FILES src/amd64/clanguages/*.h*)

file(GLOB_RECURSE SRC_I386_FILES src/i386/clanguages/*.c*)
file(GLOB_RECURSE SRC_AMD64_FILES src/amd64/clanguages/*.c*)

add_library(KernelMain STATIC ${DEF_AMD64_FILES} ${DEF_I386_FILES} ${ASM_AMD64_SOURCES} ${ASM_I386_SOURCES} ${SRC_AMD64_FILES} ${SRC_I386_FILES})

target_include_directories(KernelMain PUBLIC src/)

set_source_files_properties(${SRC_AMD64_FILES} PROPERTIES COMPILE_FLAGS -m64 -ffreestanding -fno-rtti -fno-exceptions -fno-stack-protector)
set_source_files_properties(${SRC_I386_FILES} PROPERTIES COMPILE_FLAGS -m32 -ffreestanding -fno-rtti -fno-exceptions -fno-stack-protector)
set_source_files_properties(${ASM_I386_SOURCES} PROPERTIES ASM_NASM_OBJECT_FORMAT elf)
set_source_files_properties(${ASM_AMD64_SOURCES} PROPERTIES ASM_NASM_OBJECT_FORMAT elf64)


add_custom_command(TARGET KernelMain
        POST_BUILD
        COMMAND ld -T${CMAKE_CURRENT_LIST_DIR}/configuration/linker/link.ld -n -o ${CMAKE_BINARY_DIR}/KernelMain.img ${CMAKE_BINARY_DIR}/libKernelMain.a)

file(COPY configuration/grub DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
add_custom_command(TARGET KernelMain POST_BUILD COMMAND cp -rfd ${CMAKE_BINARY_DIR}/KernelMain.img ${CMAKE_BINARY_DIR}/grub/boot/KernelMain.img && grub-mkrescue /usr/lib/grub/i386-pc -o ${CMAKE_BINARY_DIR}/KernelMain.iso ${CMAKE_BINARY_DIR}/grub)