## # vcpkg_find_acquire_program
##
## Download or find a well-known tool.
##
## ## Usage
## ```cmake
## vcpkg_find_acquire_program(<VAR>)
## ```
## ## Parameters
## ### VAR
## This variable specifies both the program to be acquired as well as the out parameter that will be set to the path of the program executable.
##
## ## Notes
## The current list of programs includes:
##
## - 7Z
## - BISON
## - FLEX
## - GASPREPROCESSOR
## - PERL
## - PYTHON2
## - PYTHON3
## - JOM
## - MESON
## - NASM
## - NINJA
## - NUGET
## - YASM
## - ARIA2 (Downloader)
##
## Note that msys2 has a dedicated helper function: [`vcpkg_acquire_msys`](vcpkg_acquire_msys.md).
##
## ## Examples
##
## * [ffmpeg](https://github.com/Microsoft/vcpkg/blob/master/ports/ffmpeg/portfile.cmake)
## * [openssl](https://github.com/Microsoft/vcpkg/blob/master/ports/openssl/portfile.cmake)
## * [qt5](https://github.com/Microsoft/vcpkg/blob/master/ports/qt5/portfile.cmake)
function(vcpkg_find_acquire_program VAR)
  set(EXPANDED_VAR ${${VAR}})
  if(EXPANDED_VAR)
    return()
  endif()

  unset(NOEXTRACT)
  unset(_vfa_RENAME)
  unset(SUBDIR)
  unset(REQUIRED_INTERPRETER)
  unset(_vfa_SUPPORTED)
  unset(POST_INSTALL_COMMAND)

  vcpkg_get_program_files_platform_bitness(PROGRAM_FILES_PLATFORM_BITNESS)
  vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)

  if(VAR MATCHES "PERL")
    set(PROGNAME perl)
    set(PATHS ${DOWNLOADS}/tools/perl/perl/bin)
    set(BREW_PACKAGE_NAME "perl")
    set(APT_PACKAGE_NAME "perl")
    set(URL "http://strawberryperl.com/download/5.30.0.1/strawberry-perl-5.30.0.1-64bit.zip")
    set(ARCHIVE "strawberry-perl-5.30.0.1-64bit.zip")
    set(HASH 352086ae012a780a0115f4a7e1239e6147fc34a5941d6a7f40557c7b1624b9663c36d778c8d28796daa46f30b5897dd705949a4853be35f4ced6ad9b191063d2)
  elseif(VAR MATCHES "NASM")
    set(PROGNAME nasm)
    set(PATHS ${DOWNLOADS}/tools/nasm/nasm-2.14.02)
    set(BREW_PACKAGE_NAME "nasm")
    set(APT_PACKAGE_NAME "nasm")
    set(URL
      "http://www.nasm.us/pub/nasm/releasebuilds/2.14.02/win32/nasm-2.14.02-win32.zip"
      "http://fossies.org/windows/misc/nasm-2.14.02-win32.zip"
    )
    set(ARCHIVE "nasm-2.14.02-win32.zip")
    set(HASH a0f16a9f3b668b086e3c4e23a33ff725998e120f2e3ccac8c28293fd4faeae6fc59398919e1b89eed7461685d2730de02f2eb83e321f73609f35bf6b17a23d1e)
  elseif(VAR MATCHES "YASM")
    set(PROGNAME yasm)
    set(SUBDIR 1.3.0.6)
    set(PATHS ${DOWNLOADS}/tools/yasm/${SUBDIR})
    set(URL "https://www.tortall.net/projects/yasm/snapshots/v1.3.0.6.g1962/yasm-1.3.0.6.g1962.exe")
    set(ARCHIVE "yasm-1.3.0.6.g1962.exe")
    set(_vfa_RENAME "yasm.exe")
    set(NOEXTRACT ON)
    set(HASH c1945669d983b632a10c5ff31e86d6ecbff143c3d8b2c433c0d3d18f84356d2b351f71ac05fd44e5403651b00c31db0d14615d7f9a6ecce5750438d37105c55b)
  elseif(VAR MATCHES "PYTHON3")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME python)
      set(SUBDIR "python-3.7.3")
      set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
      set(URL "https://www.python.org/ftp/python/3.7.3/python-3.7.3-embed-amd64.zip")
      set(ARCHIVE "python3.zip")
      set(HASH 4b3e0067b5e8d00b1cac5d556ab4fbd71df2a1852afb3354ee62363aabc8801aca84da09dbd26125527ae54b50488f808c1d82abf18969c23a51dcd57576885f)
      set(POST_INSTALL_COMMAND ${CMAKE_COMMAND} -E remove python37._pth)
    else()
      set(PROGNAME python3)
      set(BREW_PACKAGE_NAME "python")
      set(APT_PACKAGE_NAME "python3")
    endif()
  elseif(VAR MATCHES "PYTHON2")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME python)
      set(SUBDIR "python2")
      set(PATHS ${DOWNLOADS}/tools/python/${SUBDIR})
      set(URL "https://www.python.org/ftp/python/2.7.16/python-2.7.16.amd64.msi")
      set(ARCHIVE "python2.msi")
      set(HASH 47c1518d1da939e3ba6722c54747778b93a44c525bcb358b253c23b2510374a49a43739c8d0454cedade858f54efa6319763ba33316fdc721305bc457efe4ffb)
    else()
      set(PROGNAME python2)
      set(BREW_PACKAGE_NAME "python2")
      set(APT_PACKAGE_NAME "python")
    endif()
  elseif(VAR MATCHES "RUBY")
    set(PROGNAME "ruby")
    set(PATHS ${DOWNLOADS}/tools/ruby/rubyinstaller-2.6.3-1-x86/bin)
    set(URL https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.6.3-1/rubyinstaller-2.6.3-1-x86.7z)
    set(ARCHIVE rubyinstaller-2.6.3-1-x86.7z)
    set(HASH 4322317dd02ce13527bf09d6e6a7787ca3814ea04337107d28af1ac360bd272504b32e20ed3ea84eb5b21dae7b23bfe5eb0e529b6b0aa21a1a2bbb0a542d7aec)
  elseif(VAR MATCHES "JOM")
    set(PROGNAME jom)
    set(SUBDIR "jom-1.1.3")
    set(PATHS ${DOWNLOADS}/tools/jom/${SUBDIR})
    set(URL "http://download.qt.io/official_releases/jom/jom_1_1_3.zip")
    set(ARCHIVE "jom_1_1_3.zip")
    set(HASH 5b158ead86be4eb3a6780928d9163f8562372f30bde051d8c281d81027b766119a6e9241166b91de0aa6146836cea77e5121290e62e31b7a959407840fc57b33)
  elseif(VAR MATCHES "7Z")
    set(PROGNAME 7z)
    set(PATHS "${PROGRAM_FILES_PLATFORM_BITNESS}/7-Zip" "${PROGRAM_FILES_32_BIT}/7-Zip" "${DOWNLOADS}/tools/7z/Files/7-Zip")
    set(URL "https://7-zip.org/a/7z1900.msi")
    set(ARCHIVE "7z1900.msi")
    set(HASH f73b04e2d9f29d4393fde572dcf3c3f0f6fa27e747e5df292294ab7536ae24c239bf917689d71eb10cc49f6b9a4ace26d7c122ee887d93cc935f268c404e9067)
  elseif(VAR MATCHES "NINJA")
    set(PROGNAME ninja)
    set(SUBDIR "ninja-1.8.2")
    if(CMAKE_HOST_WIN32)
      set(PATHS "${DOWNLOADS}/tools/ninja/${SUBDIR}")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(PATHS "${DOWNLOADS}/tools/${SUBDIR}-osx")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD")
      set(PATHS "${DOWNLOADS}/tools/${SUBDIR}-freebsd")
    else()
      set(PATHS "${DOWNLOADS}/tools/${SUBDIR}-linux")
    endif()
    set(BREW_PACKAGE_NAME "ninja")
    set(APT_PACKAGE_NAME "ninja-build")
    set(URL "https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-win.zip")
    set(ARCHIVE "ninja-1.8.2-win.zip")
    set(HASH 9b9ce248240665fcd6404b989f3b3c27ed9682838225e6dc9b67b551774f251e4ff8a207504f941e7c811e7a8be1945e7bcb94472a335ef15e23a0200a32e6d5)
  elseif(VAR MATCHES "NUGET")
    set(PROGNAME nuget)
    set(PATHS "${DOWNLOADS}/tools/nuget")
    set(BREW_PACKAGE_NAME "nuget")
    set(URL "https://dist.nuget.org/win-x86-commandline/v4.9.4/nuget.exe")
    set(ARCHIVE "nuget.exe")
    set(NOEXTRACT ON)
    set(HASH ce3692102cc3563b58f6808c2c29cdc5e3fb252b5e460edee0f525af8ddda0a840b058b73f4fdef92e4c50898fe681e6d6393a9e51a59f2389aff5b60fbaa76f)
  elseif(VAR MATCHES "MESON")
    set(PROGNAME meson)
    set(REQUIRED_INTERPRETER PYTHON3)
    set(BREW_PACKAGE_NAME "meson")
    set(APT_PACKAGE_NAME "meson")
    if(CMAKE_HOST_WIN32)
      set(SCRIPTNAME meson.py)
    else()
      set(SCRIPTNAME meson)
    endif()
    set(PATHS ${DOWNLOADS}/tools/meson/meson-0.51.0)
    set(URL "https://github.com/mesonbuild/meson/archive/0.51.0.zip")
    set(ARCHIVE "meson-0.51.0.zip")
    set(HASH bf1df65cde7e0e0a44e4b4be7d68de9897a77c4ea4c694f1d77fe82cd3c7e7818dc034a3313ce885ba6883b4ba6d282b7a589f665fa499d9eb79fc7a23e415cc)
  elseif(VAR MATCHES "FLEX")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME win_flex)
      set(SUBDIR win_flex-2.5.16)
      set(PATHS ${DOWNLOADS}/tools/win_flex/${SUBDIR})
      set(URL "https://sourceforge.net/projects/winflexbison/files/winflexbison-2.5.16.zip/download")
      set(ARCHIVE "win_flex_bison-2.5.16.zip")
      set(HASH 0a14154bff5d998feb23903c46961528f8ccb4464375d5384db8c4a7d230c0c599da9b68e7a32f3217a0a0735742242eaf3769cb4f03e00931af8640250e9123)
      if(NOT EXISTS "${PATHS}/data/m4sugar/m4sugar.m4")
        file(REMOVE_RECURSE "${PATHS}")
      endif()
    else()
      set(PROGNAME flex)
      set(APT_PACKAGE_NAME flex)
      set(BREW_PACKAGE_NAME flex)
    endif()
  elseif(VAR MATCHES "BISON")
    if(CMAKE_HOST_WIN32)
      set(PROGNAME win_bison)
      set(SUBDIR win_bison-2.5.16)
      set(PATHS ${DOWNLOADS}/tools/win_bison/${SUBDIR})
      set(URL "https://sourceforge.net/projects/winflexbison/files/winflexbison-2.5.16.zip/download")
      set(ARCHIVE "win_flex_bison-2.5.16.zip")
      set(HASH 0a14154bff5d998feb23903c46961528f8ccb4464375d5384db8c4a7d230c0c599da9b68e7a32f3217a0a0735742242eaf3769cb4f03e00931af8640250e9123)
      if(NOT EXISTS "${PATHS}/data/m4sugar/m4sugar.m4")
        file(REMOVE_RECURSE "${PATHS}")
      endif()
    else()
      set(PROGNAME bison)
      set(APT_PACKAGE_NAME bison)
      set(BREW_PACKAGE_NAME bison)
    endif()
  elseif(VAR MATCHES "GPERF")
    set(PROGNAME gperf)
    set(PATHS ${DOWNLOADS}/tools/gperf/bin)
    set(URL "https://sourceforge.net/projects/gnuwin32/files/gperf/3.0.1/gperf-3.0.1-bin.zip/download")
    set(ARCHIVE "gperf-3.0.1-bin.zip")
    set(HASH 3f2d3418304390ecd729b85f65240a9e4d204b218345f82ea466ca3d7467789f43d0d2129fcffc18eaad3513f49963e79775b10cc223979540fa2e502fe7d4d9)
  elseif(VAR MATCHES "GASPREPROCESSOR")
    set(NOEXTRACT true)
    set(PROGNAME gas-preprocessor)
    set(REQUIRED_INTERPRETER PERL)
    set(SCRIPTNAME "gas-preprocessor.pl")
    set(PATHS ${DOWNLOADS}/tools/gas-preprocessor)
    set(URL "https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/cbe88474ec196370161032a3863ec65050f70ba4/gas-preprocessor.pl")
    set(ARCHIVE "gas-preprocessor.pl")
    set(HASH f6965875608bf2a3ee337e00c3f16e06cd9b5d10013da600d2a70887e47a7b4668af87b3524acf73dd122475712af831495a613a2128c1adb5fe0b4a11d96cd3)
  elseif(VAR MATCHES "DARK")
    set(PROGNAME dark)
    set(SUBDIR "wix311-binaries")
    set(PATHS ${DOWNLOADS}/tools/dark/${SUBDIR})
    set(URL "https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip")
    set(ARCHIVE "wix311-binaries.zip")
    set(HASH 74f0fa29b5991ca655e34a9d1000d47d4272e071113fada86727ee943d913177ae96dc3d435eaf494d2158f37560cd4c2c5274176946ebdb17bf2354ced1c516)
  elseif(VAR MATCHES "SCONS")
    set(PROGNAME scons)
    set(REQUIRED_INTERPRETER PYTHON2)
    set(SCRIPTNAME "scons.py")
    set(PATHS ${DOWNLOADS}/tools/scons)
    set(URL "https://sourceforge.net/projects/scons/files/scons-local-3.0.1.zip/download")
    set(ARCHIVE "scons-local-3.0.1.zip")
    set(HASH fe121b67b979a4e9580c7f62cfdbe0c243eba62a05b560d6d513ac7f35816d439b26d92fc2d7b7d7241c9ce2a49ea7949455a17587ef53c04a5f5125ac635727)
  elseif(VAR MATCHES "DOXYGEN")
    set(PROGNAME doxygen)
    set(PATHS ${DOWNLOADS}/tools/doxygen)
    set(URL "http://doxygen.nl/files/doxygen-1.8.15.windows.bin.zip")
    set(ARCHIVE "doxygen-1.8.15.windows.bin.zip")
    set(HASH 89482dcb1863d381d47812c985593e736d703931d49994e09c7c03ef67e064115d0222b8de1563a7930404c9bc2d3be323f3d13a01ef18861be584db3d5a953c)
  elseif(VAR MATCHES "BAZEL")
    set(PROGNAME bazel)
    set(BAZEL_VERSION 0.25.2)
    set(SUBDIR ${BAZEL_VERSION})
    set(PATHS ${DOWNLOADS}/tools/bazel/${SUBDIR})
    set(_vfa_RENAME "bazel")
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
      set(_vfa_SUPPORTED ON)
      set(URL "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64")
      set(ARCHIVE "bazel-${BAZEL_VERSION}-linux-x86_64")
      set(NOEXTRACT ON)
      set(HASH db4a583cf2996aeb29fd008261b12fe39a4a5faf0fbf96f7124e6d3ffeccf6d9655d391378e68dd0915bc91c9e146a51fd9661963743857ca25179547feceab1)
    else()
      set(URL "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-windows-x86_64.zip") 
      set(ARCHIVE "bazel-${BAZEL_VERSION}-windows-x86_64.zip")
      set(HASH 6482f99a0896f55ef65739e7b53452fd9c0adf597b599d0022a5e0c5fa4374f4a958d46f98e8ba25af4b065adacc578bfedced483d8c169ea5cb1777a99eea53)
    endif()
  # Download Tools
  elseif(VAR MATCHES "ARIA2")
    set(PROGNAME aria2c)
    set(PATHS ${DOWNLOADS}/tools/aria2c/aria2-1.34.0-win-64bit-build1)
    set(URL "https://github.com/aria2/aria2/releases/download/release-1.34.0/aria2-1.34.0-win-64bit-build1.zip")
    set(ARCHIVE "aria2-1.34.0-win-64bit-build1.zip")
    set(HASH 54bf617cedee98b2fcbd3f0c4660631f14c519bf89ba7dd1997cde3fb2f69aee3fc1e2740d178f6d9036bb130daf498ec3a394bef41666cc3011f58be6c48198)
  else()
    message(FATAL "unknown tool ${VAR} -- unable to acquire.")
  endif()

  macro(do_find)
    if(NOT DEFINED REQUIRED_INTERPRETER)
      find_program(${VAR} ${PROGNAME} PATHS ${PATHS})
    else()
      vcpkg_find_acquire_program(${REQUIRED_INTERPRETER})
      find_file(SCRIPT ${SCRIPTNAME} PATHS ${PATHS})
      set(${VAR} ${${REQUIRED_INTERPRETER}} ${SCRIPT})
    endif()
  endmacro()

  do_find()
  if("${${VAR}}" MATCHES "-NOTFOUND")
    if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows" AND NOT _vfa_SUPPORTED)
      set(EXAMPLE ".")
      if(DEFINED BREW_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        set(EXAMPLE ":\n    brew install ${BREW_PACKAGE_NAME}")
      elseif(DEFINED APT_PACKAGE_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(EXAMPLE ":\n    sudo apt-get install ${APT_PACKAGE_NAME}")
      endif()
      message(FATAL_ERROR "Could not find ${PROGNAME}. Please install it via your package manager${EXAMPLE}")
    endif()

    vcpkg_download_distfile(ARCHIVE_PATH
        URLS ${URL}
        SHA512 ${HASH}
        FILENAME ${ARCHIVE}
    )

    set(PROG_PATH_SUBDIR "${DOWNLOADS}/tools/${PROGNAME}/${SUBDIR}")
    file(MAKE_DIRECTORY ${PROG_PATH_SUBDIR})
    if(DEFINED NOEXTRACT)
      if(DEFINED _vfa_RENAME)
        file(INSTALL ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} RENAME ${_vfa_RENAME} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
      else()
        file(COPY ${ARCHIVE_PATH} DESTINATION ${PROG_PATH_SUBDIR} PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
      endif()
    else()
      get_filename_component(ARCHIVE_EXTENSION ${ARCHIVE} EXT)
      string(TOLOWER "${ARCHIVE_EXTENSION}" ARCHIVE_EXTENSION)
      if(ARCHIVE_EXTENSION STREQUAL ".msi")
        file(TO_NATIVE_PATH "${ARCHIVE_PATH}" ARCHIVE_NATIVE_PATH)
        file(TO_NATIVE_PATH "${PROG_PATH_SUBDIR}" DESTINATION_NATIVE_PATH)
        execute_process(
          COMMAND msiexec /a ${ARCHIVE_NATIVE_PATH} /qn TARGETDIR=${DESTINATION_NATIVE_PATH}
          WORKING_DIRECTORY ${DOWNLOADS}
        )
      else()
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E tar xzf ${ARCHIVE_PATH}
          WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
        )
      endif()
    endif()

    if(DEFINED POST_INSTALL_COMMAND)
      vcpkg_execute_required_process(
        COMMAND ${POST_INSTALL_COMMAND}
        WORKING_DIRECTORY ${PROG_PATH_SUBDIR}
        LOGNAME ${VAR}-tool-post-install
      )
    endif()

    do_find()
  endif()

  set(${VAR} "${${VAR}}" PARENT_SCOPE)
endfunction()
