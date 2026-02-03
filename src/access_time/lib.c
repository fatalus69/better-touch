#include "lib.h"

// kill the user if he doesnt enter ISO 8601
int parseTimeString(const char* time_str, struct tm* tm) {
    // manual parsing because windows has no strptime
    return sscanf(
        time_str,
        "%d-%d-%d %d:%d:%d",
        &tm->tm_year,
        &tm->tm_mon,
        &tm->tm_mday,
        &tm->tm_hour,
        &tm->tm_min,
        &tm->tm_sec
    ) == 6
    && (tm->tm_year -= 1900, tm->tm_mon -= 1, 1);
}

// not sure if I like this, but it works...
#ifdef _WIN32
#include <windows.h>

static FILETIME tm_to_filetime(struct tm *tm) {
    ULARGE_INTEGER ull;
    ull.QuadPart = ((unsigned long long)mktime(tm) + 11644473600ULL) * 10000000ULL;
    FILETIME ft;
    ft.dwLowDateTime  = ull.LowPart;
    ft.dwHighDateTime = ull.HighPart;
    return ft;
}

int setFileTimes(const char *filepath, struct tm *atime, struct tm *mtime) {
    // create file just to be sure
    HANDLE h = CreateFileA(
        filepath,
        FILE_WRITE_ATTRIBUTES,
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        NULL,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL,
        NULL
    );

    if (h == INVALID_HANDLE_VALUE)
        return -1;

    FILETIME ctime, fatime, fmtime;
    GetFileTime(h, &ctime, &fatime, &fmtime);

    if (atime)
        fatime = tm_to_filetime(atime);
    if (mtime)
        fmtime = tm_to_filetime(mtime);

    bool ok = SetFileTime(h, &ctime, &fatime, &fmtime);
    CloseHandle(h);

    return ok ? 0 : -1;
}
#else
    int setFileTimes(const char *filepath, struct tm *atime, struct tm *mtime) {
        #ifndef _WIN32
            struct timespec times[2];

            if (atime) {
                times[0].tv_sec  = mktime(atime);
                times[0].tv_nsec = 0;
            } else {
                times[0].tv_nsec = UTIME_OMIT;
            }

            if (mtime) {
                times[1].tv_sec  = mktime(mtime);
                times[1].tv_nsec = 0;
            } else {
                times[1].tv_nsec = UTIME_OMIT;
            }

            return utimensat(AT_FDCWD, filepath, times, 0);
        #endif
    }
#endif

int setAccessTime(const char *path, char *time_str) {
    struct tm tm = {0};
    if (!parseTimeString(time_str, &tm))
        return -1;

    return setFileTimes(path, &tm, NULL);
}

int setModificationTime(const char *path, char *time_str) {
    struct tm tm = {0};
    if (!parseTimeString(time_str, &tm))
        return -1;

    return setFileTimes(path, NULL, &tm);
}