#pragma once

#include <stdio.h>
#include <time.h>

#ifdef _WIN32
    #include <sys/utime.h>
#else
    #include <sys/stat.h>
    #include <fcntl.h>
#endif

int setAccessTime(const char *path, char *time_str);
int setModificationTime(const char *path, char *time_str);