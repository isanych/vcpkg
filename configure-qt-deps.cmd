if not exist "%~dp0vcpkg.exe" call "%~dp0bootstrap-vcpkg"
"%~dp0vcpkg" install --triplet bzip2 double-conversion freetype harfbuzz libjpeg-turbo liblzma libpng openssl pcre2 sqlite3 zlib fontconfig
