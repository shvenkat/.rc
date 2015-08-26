#pragma once

#include <vector>
#include <string>

#include "env/environment.hpp"

namespace color_coded
{
  namespace conf
  {
    using args_t = std::vector<std::string>;

    /* Prefixed onto every set of args to make life easier. */
    inline args_t constants()
    {
      return
      {
        "-x", "c++",
        environment<env::tag>::clang_include,
        environment<env::tag>::clang_include_cpp,
        environment<env::tag>::clang_lib_include,
        "-I/usr/local/include",
        "-I/opt/local/include",
        "-I/usr/include",
        "-w"
      };
    }

    /* If no .color_coded file is provided, these are used. */
    inline args_t defaults()
    {
      static auto const additions(constants());
      args_t args{ "-std=c++1y", "-I.", "-Iinclude" };
      std::copy(std::begin(additions), std::end(additions),
                std::back_inserter(args));
      return args;
    }
  }
}
