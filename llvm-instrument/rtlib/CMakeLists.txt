cmake_minimum_required(VERSION 3.1)
project(rtlogger)

#How do you  NOT do module.. Now note that we are using a env variable hack.. Ideally, we should not have this..
add_library(logger MODULE logger.cpp) 
