if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg"
"%~dp0vcpkg" install --triplet x64-windows-qt zlib bzip2 double-conversion icu libjpeg-turbo liblzma libpng openssl pcre2 sqlite3 freetype harfbuzz fontconfig
