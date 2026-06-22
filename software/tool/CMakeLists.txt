#LB-MIT
#
# MIT License
#
# Copyright (c) 2026 Till Straumann
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#LE-MIT

cmake_minimum_required(VERSION 3.20)

project(scope LANGUAGES C CXX)

set(ACM_TOOLBOX ../../firmware/modules/acm-toolbox/sw)

find_library(LIBUSB NAMES usb-1.0)

include_directories(./ ${ACM_TOOLBOX})

add_library(ticnicpp "libusb_vend_cmd.cpp" "ticnic.cpp")

add_executable(tic_nic_ctl tic_nic_ctl.cpp)

add_subdirectory(${ACM_TOOLBOX} acm-toolbox EXCLUDE_FROM_ALL)

set(LIBS ticnicpp fwcommGeneric ${LIBUSB})

target_link_libraries(tic_nic_ctl PRIVATE ${LIBS})

add_executable(pkt pkt.c)

add_executable(flastic flastic.cpp)

target_link_libraries(flastic PRIVATE ${LIBS})
