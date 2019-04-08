#pragma once

#include <vcpkg/base/cstringview.h>
#include <vcpkg/base/lineinfo.h>
#include <vcpkg/base/strings.h>

#ifdef __GNUC__
#include <backtrace.h>
#include <cxxabi.h>
#endif

namespace vcpkg::Checks
{
#ifdef __GNUC__
    static int full_callback(
        void* data __attribute__((unused)), uintptr_t pc, const char* filename, int lineno, const char* function)
    {
        char* realname = nullptr;
        int demangle_status;

        realname = abi::__cxa_demangle(function, 0, 0, &demangle_status);

        if (demangle_status != 0)
        {
            realname = ::strdup(function);
        }

        printf("0x%lx %s \t%s:%d\n",
               (unsigned long)pc,
               realname == nullptr ? "???" : realname,
               filename == nullptr ? "???" : filename,
               lineno);

        free(realname);

        return strcmp(function, "main") == 0 ? 1 : 0;
    }

    static void error_callback(void* data, const char* msg, int errnum)
    {
        printf("Something went wrong in libbacktrace: %s\n", msg);
    }
#endif

    void register_console_ctrl_handler();

    // Indicate that an internal error has occurred and exit the tool. This should be used when invariants have been
    // broken.
    [[noreturn]] void unreachable(const LineInfo& line_info);

    [[noreturn]] void exit_with_code(const LineInfo& line_info, const int exit_code);

    // Exit the tool without an error message.
    [[noreturn]] inline void exit_fail(const LineInfo& line_info)
	{
#ifdef __GNUC__
        auto lbstate = backtrace_create_state(nullptr, 1, error_callback, nullptr);
        backtrace_full(lbstate, 0, full_callback, error_callback, 0);
#endif
		exit_with_code(line_info, EXIT_FAILURE);
	}

    // Exit the tool successfully.
    [[noreturn]] inline void exit_success(const LineInfo& line_info) { exit_with_code(line_info, EXIT_SUCCESS); }

    // Display an error message to the user and exit the tool.
    [[noreturn]] void exit_with_message(const LineInfo& line_info, const CStringView error_message);

    template<class Arg1, class... Args>
    // Display an error message to the user and exit the tool.
    [[noreturn]] void exit_with_message(const LineInfo& line_info,
                                        const char* error_message_template,
                                        const Arg1& error_message_arg1,
                                        const Args&... error_message_args)
    {
        exit_with_message(line_info,
                          Strings::format(error_message_template, error_message_arg1, error_message_args...));
    }

    void check_exit(const LineInfo& line_info, bool expression);

    void check_exit(const LineInfo& line_info, bool expression, const CStringView error_message);

    template<class Conditional, class Arg1, class... Args>
    void check_exit(const LineInfo& line_info,
                    Conditional&& expression,
                    const char* error_message_template,
                    const Arg1& error_message_arg1,
                    const Args&... error_message_args)
    {
        if (!expression)
        {
            // Only create the string if the expression is false
            exit_with_message(line_info,
                              Strings::format(error_message_template, error_message_arg1, error_message_args...));
        }
    }
}
