#pragma once

#include <sstream>
#include <string>
#include <iostream>
#include <stdexcept>
#include <limits>
#include <cmath>
#include <algorithm>
#include <functional>

namespace jest
{
  namespace detail
  {
    struct no_exception
    { };

    /* TODO: suffix for types? 'f' for float, 'i' for int */
    template <typename T>
    void render_component(std::stringstream &ss, T const &t)
    { ss << t << ", "; }
    template <>
    inline void render_component<std::string>(std::stringstream &ss,
                                              std::string const &s)
    { ss << "\"" << s << "\", "; }
    template <size_t N>
    void render_component(std::stringstream &ss, char const (&s)[N])
    { ss << "\"" << s << "\", "; }
    template <>
    inline void render_component<std::nullptr_t>(std::stringstream &ss,
                                                 std::nullptr_t const&)
    { ss << "nullptr, "; }

    template <typename... Args>
    void fail(std::string const &msg, Args const &... args)
    {
      std::stringstream ss;
      ss << std::boolalpha;
      int const _[]{ (render_component(ss, args), 0)... };
      static_cast<void>(_);
      throw std::runtime_error
      {
        "failed '" + msg + "' (" +
        ss.str().substr(0, ss.str().size() - 2) + ")"
      };
    }

    template <typename C, typename T, typename... Args>
    void expect_equal_impl(C const &comp, size_t const n,
                           T const &t, Args const &... args)
    {
      int const _[]
      { (comp(t, args), 0)... };
      (void)_;
      if(n != sizeof...(Args))
      { expect_equal_impl(comp, n + 1, args..., t); }
    }

    template <typename... Ts>
    struct filter_exception;
    template <>
    struct filter_exception<>
    {
      void operator ()() const
      try
      { std::rethrow_exception(std::current_exception()); }
      catch(std::exception const &e)
      { throw std::runtime_error{ std::string{"unexpected exception: "} + e.what() }; }
    };
    template <typename T, typename... Ts>
    struct filter_exception<T, Ts...>
    {
      void operator ()() const
      try
      { throw; }
      catch(T const &)
      { }
      catch(...)
      { filter_exception<Ts...>{}(); }
    };
  }

  template <typename... Ts>
  void expect_exception(std::function<void ()> const &f)
  try
  {
    f();
    throw detail::no_exception{};
  }
  catch(detail::no_exception const &)
  { throw std::runtime_error{ "expected exception, none was thrown" }; }
  catch(...)
  { detail::filter_exception<Ts...>{}(); }

  template <typename... Args>
  void expect_equal(Args const &... args)
  {
    detail::expect_equal_impl([](auto const &t1, auto const &t2)
    {
      if(t1 != t2)
      { detail::fail("not equal", t1, t2); }
    },
    0, args...);
  }

  template <typename... Args>
  void expect_not_equal(Args const &... args)
  {
    detail::expect_equal_impl([](auto const &t1, auto const &t2)
    {
      if(t1 == t2)
      { detail::fail("equal", t1, t2); }
    },
    0, args...);
  }

  template <typename... Args>
  void expect_almost_equal(Args const &... args)
  {
    detail::expect_equal_impl([](auto const &t1, auto const &t2)
    {
      using common = std::decay_t<std::common_type_t<decltype(t1), decltype(t2)>>;
      common const max
      {
        std::max({ common{ 1.0 }, std::fabs(common{ t1 }),
                   std::fabs(common{ t2 }) })
      };
      if(std::fabs(common{ t1 - t2 }) > 0.0000001 * max)
      { detail::fail("not almost equal", t1, t2); }
    },
    0, args...);
  }

  template <typename... Args>
  void expect(bool const b)
  {
    if(!b)
    { detail::fail("unexpected", b); }
  }

  inline void fail(std::string const &msg)
  { detail::fail("explicit fail", msg); }
  inline void fail()
  { fail(""); }
}
