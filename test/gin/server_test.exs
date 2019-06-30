defmodule Gin.ServerTest do
  use ExUnit.Case, async: true
  
  # describe "definng the process name" do
  #   test "with invalid GenServer name raises the expected Erlang error", c do
  #     name = "invalid-name"

  #     pattern =
  #       ~r/For local name arg passed into &defname\/\{1,2\}, name must be one of the following types: Atom/

  #     func = fn ->
  #       Code.eval_string("""
  #         defmodule #{c.module_str} do
  #           use Gin.Server

  #           defstruct []

  #           defname #{inspect(name)}
  #         end
  #       """)
  #     end

  #     assert_raise Gin.Error.Compile, pattern, func
  #   end
    
  #   test "using the defname macro", c do
  #     name = PlusOneUpdoot.atom!()

  #     Code.eval_string("""
  #       defmodule #{c.module_str} do
  #         use Gin.Server

  #         defstruct []

  #         defname #{inspect(name)}
  #       end
  #     """)

  #     assert Process.whereis(name) == nil
  #     {:ok, pid} = c.module.start_link()
  #     assert Process.whereis(name) == pid
  #   end
    
  #   test "is module name by default", c do
  #     Code.eval_string("""
  #       defmodule #{c.module_str} do
  #         use Gin.Server

  #         defstruct []
  #       end
  #     """)

  #     assert Process.whereis(c.module) == nil
  #     {:ok, pid} = c.module.start_link()
  #     assert Process.whereis(c.module) == pid
  #   end
  # end
  
  # describe "defining an init callback" do
  #   test "with a timeout action triggers the timeout callback", c do
  #     key = :timed_out?
  #     default = false
  #     type = Atom
  #     value = true

  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct #{key}: %{default: #{inspect(default)}, type: #{inspect(type)}}

  #       definit do
  #         action :timeout, 0
  #       end

  #       def handle_info(:timeout, %__MODULE__{#{key}: #{inspect(default)}} = data) do
  #         {:noreply, struct!(data, [{#{inspect(key)}, #{inspect(value)}}])}
  #       end
  #     end
  #     """)

  #     {:ok, pid} = c.module.start_link()
  #     assert :sys.get_state(pid) == struct(c.module, [{key, value}])
  #   end
    
  #   test "with a stop action stops the process", c do
  #     reason = :stopped

  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct []

  #       definit do
  #         action :stop, #{inspect(reason)}
  #       end
  #     end
  #     """)

  #     false = Process.flag(:trap_exit, true)
  #     {:error, ^reason} = c.module.start_link()
  #     assert_receive {:EXIT, _pid, ^reason}, 500
  #   end
    
  #   test "with an ignore action returns ignore", c do
  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct []

  #       definit do
  #         action :ignore
  #       end
  #     end
  #     """)

  #     assert c.module.start_link() == :ignore
  #   end
    
  #   test "with a hibernate action starts the pid in hibernation", c do
  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct []

  #       definit do
  #         action :hibernate
  #       end
  #     end
  #     """)

  #     {:ok, pid} = c.module.start_link()
  #     assert Process.info(pid)[:current_function] == {:erlang, :hibernate, 3}
  #   end

  #   test "with a continue action calls the handle continue callback", c do
  #     key = :continued?
  #     default = false
  #     type = Atom
  #     value = true

  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct #{key}: %{default: #{inspect(default)}, type: #{inspect(type)}}

  #       definit do
  #         action :continue, {:continued, #{inspect(value)}}
  #       end

  #       def handle_continue({:continued, msg}, %__MODULE__{#{key}: #{inspect(default)}} = data) do
  #         {:noreply, struct!(data, [{#{inspect(key)}, msg}])}
  #       end
  #     end
  #     """)

  #     {:ok, pid} = c.module.start_link()
  #     assert :sys.get_state(pid) == struct(c.module, [{key, value}])
  #   end

  #   test "with no action does not raise an error", c do
  #     key = :error_raised?
  #     default = true
  #     type = Atom
  #     value = false      

  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct #{key}: %{default: #{inspect(default)}, type: #{inspect(type)}}

  #       def handle_info(:no_error, %__MODULE__{#{key}: #{inspect(default)}} = data) do
  #         {:noreply, struct!(data, #{key}: #{inspect(value)})}
  #       end
  #     end
  #     """)

  #     {:ok, pid} = c.module.start_link()
  #     send(pid, :no_error)
  #     assert :sys.get_state(pid) == struct(c.module, [{key, value}])
  #   end
  # end
  
  describe "defining a struct" do
  #   test "with default values", c do
  #     {key1, default1, type1} = {:a_string, "A String :)", BitString}
  #     {key2, default2, type2} = {:an_atom, :hey_look_an_atom, Atom}

  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct #{key1}: %{default: #{inspect(default1)}, type: #{inspect(type1)}},
  #                 #{key2}: %{default: #{inspect(default2)}, type: #{inspect(type2)}}
  #     end
  #     """)

  #     {:ok, pid} = c.module.start_link()

  #     assert :sys.get_state(pid) ==
  #              struct!(c.module, [
  #                {key1, default1},
  #                {key2, default2}
  #              ])
  #   end
    
  #   test "will generate a runtime error when value for key is unsupported type",
  #        c do
  #     key = :uri
  #     types = [BitString, URI]

  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct #{key}: %{types: #{inspect(types)}}
  #     end
  #     """)

  #     false = Process.flag(:trap_exit, true)
  #     invalid_uri = :not_bitstring_or_uri

  #     error = %Gin.Error.Runtime{
  #       message:
  #         "For key #{inspect(key)}, value must have one of these types: #{
  #           Enum.join(Enum.map(types, &inspect/1), ", ")
  #         }"
  #     }

  #     _ = c.module.start_link([{key, invalid_uri}])
  #     assert_receive {:EXIT, _, {^error, _}}, 1_000
  #   end

  #   test "with key w/ 1 struct type and 1 non-struct key type succeeds", c do
  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server, named?: false

  #       defstruct uri: %{types: [BitString, URI]}
  #     end
  #     """)

  #     bitstring_uri = "https://www.google.com"
  #     {:ok, bitstring_uri_pid} = c.module.start_link(uri: bitstring_uri)

  #     assert :sys.get_state(bitstring_uri_pid) ==
  #              struct!(c.module, uri: bitstring_uri)

  #     struct_uri = URI.parse("https://www.google.com")
  #     {:ok, struct_uri_pid} = c.module.start_link(uri: struct_uri)

  #     assert :sys.get_state(struct_uri_pid) ==
  #              struct!(c.module, uri: struct_uri)
  #   end
    
  #   test "with 1 struct key & 1 non-struct key type succeeds", c do
  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct bitstring_uri: %{type: BitString},
  #                 struct_uri: %{type: URI}
            
  #     end
  #     """)

  #     bitstring_uri = "https://www.google.com"
  #     struct_uri = %URI{}

  #     {:ok, pid} =
  #       c.module.start_link(
  #         bitstring_uri: bitstring_uri,
  #         struct_uri: struct_uri
  #       )

  #     assert :sys.get_state(pid) ==
  #              struct!(c.module,
  #                bitstring_uri: bitstring_uri,
  #                struct_uri: struct_uri
  #              )
  #   end
    
  #   test "with a non-struct key type succeeds", c do
  #     key = :just_some_key
  #     type = BitString

  #     Code.eval_string("""
  #       defmodule #{c.module_str} do
  #         use Gin.Server

  #         defstruct #{key}: %{type: #{inspect(type)}}
  #       end
  #     """)

  #     value = "https://www.google.com"
  #     {:ok, pid} = c.module.start_link([{key, value}])
  #     assert :sys.get_state(pid) == struct!(c.module, [{key, value}])
  #   end
    
  #   test "with a struct key type succeeds", c do
  #     key = :just_some_key
  #     struct = %URI{}
  #     %{__struct__: type} = %URI{}
  #     ^type = URI

  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct #{key}: %{type: #{inspect(type)}}
  #     end
  #     """)

  #     value = struct
  #     {:ok, pid} = c.module.start_link([{key, value}])
  #     assert :sys.get_state(pid) == struct!(c.module, [{key, value}])
  #   end
    
  #   test "with no keys autogenerates &init/1, which sets pid state to that struct",
  #        c do
  #     Code.eval_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct []
  #     end
  #     """)

  #     {:ok, pid} = c.module.start_link([])
  #     assert :sys.get_state(pid) == struct!(c.module, [])
  #   end
    
  #   test "autogenerates &start_link/1 w/ guard to ensure arg is map or list",
  #        c do
  #     Code.compile_string("""
  #     defmodule #{c.module_str} do
  #       use Gin.Server

  #       defstruct []
  #     end
  #     """)

  #     assert c.module.start_link([])
  #     assert c.module.start_link(%{})

  #     func = fn ->
  #       c.module.start_link("not_a_list_or_map")
  #     end

  #     assert_raise FunctionClauseError, func
  #   end
    
    test "w/ key that has with 2 unsupported types raises a compile error for first unsupported type" do
      module = PlusOneUpdoot.module!()
      key = :oh_no_two_unsupported_types!
      unsupported_type0 = PlusOneUpdoot.module!()
      unsupported_type1 = PlusOneUpdoot.module!()
      types = [unsupported_type0, unsupported_type1]
      error = Gin.Error.Compile
      message = "For struct key #{inspect(key)}, the type #{inspect(unsupported_type0)} is not supported"

      func = fn ->
        Code.eval_string("""
        defmodule #{inspect(module)} do
          use Gin.Server

          defstruct #{key}: %{types: #{inspect(types)}}
        end
        """)
      end

      assert_raise error, message, func
    end

    test "w/ key that has with 1 supported type & 1 unsupported type raises a compile error" do
      module = PlusOneUpdoot.module!()
      key = :one_good_type_but_oops_da_other_one_busted
      supported_type = BitString
      unsupported_type = PlusOneUpdoot.module!()
      types = [supported_type, unsupported_type]
      error = Gin.Error.Compile
      message = "For struct key #{inspect(key)}, the type #{inspect(unsupported_type)} is not supported"

      func = fn ->
        Code.eval_string("""
        defmodule #{inspect(module)} do
          use Gin.Server

          defstruct #{key}: %{types: #{inspect(types)}}
        end
        """)
      end

      assert_raise error, message, func
    end
  
    test "w/ with an unsupported value type raises a compile error" do
      module = PlusOneUpdoot.module!()
      key = :me_no_have_supported_type
      unsupported_type = PlusOneUpdoot.module!()
      error = Gin.Error.Compile
      message = "For struct key #{inspect(key)}, the type #{inspect(unsupported_type)} is not supported"

      func = fn ->
        Code.eval_string("""
        defmodule #{inspect(module)} do
          use Gin.Server

          defstruct #{key}: %{type: #{inspect(unsupported_type)}}

        end
        """)
      end

      assert_raise error, message, func
    end

    test "with both :type and :types opts raises a compile time error" do
      module = PlusOneUpdoot.module!()
      key = :oops_have_type_and_types
      type = Atom
      types = [Atom, BitString]
      error = Gin.Error.Compile
      message = "For struct key #{inspect(key)}, both type and types declared"

      func = fn ->
        Code.eval_string("""
        defmodule #{inspect(module)} do
          use Gin.Server

          defstruct #{key}: %{type: #{inspect(type)}, types: #{inspect(types)}}
        end
        """)
      end

      assert_raise error, message, func
    end

    test "w/o declaring a type for every key raises a compile error" do
      module = PlusOneUpdoot.module!()
      key = :me_have_no_type
      error = Gin.Error.Compile
      message = "For struct key #{inspect(key)}, no type(s) declared"

      func = fn ->
        Code.eval_string("""
        defmodule #{inspect(module)} do
          use Gin.Server

          defstruct #{key}: %{}
        end
        """)
      end

      assert_raise error, message, func
    end

    test "with no keys" do
      module = PlusOneUpdoot.module!()

      Code.eval_string("""
        defmodule #{inspect(module)} do
          use Gin.Server

          defstruct []
        end
      """)

      assert struct!(module, [])
    end
  end

  describe "Using a Gin.Server" do
    test "creates boilerplate functions which raises errors when not implemented" do
      module = PlusOneUpdoot.module!()
      error = Gin.Error.Runtime
      message = "not implemented"

      Code.eval_string("""
        defmodule #{inspect(module)} do
          use Gin.Server
        end
      """) 

      # GenServer functions
      assert_raise error, message, fn -> module.abcast(nil, nil, nil) end
      assert_raise error, message, fn -> module.call(nil, nil, nil) end
      assert_raise error, message, fn -> module.cast(nil, nil) end
      assert_raise error, message, fn -> module.multi_call(nil, nil, nil, nil) end
      assert_raise error, message, fn -> module.reply(nil, nil) end
      assert_raise error, message, fn -> module.start(nil, nil, nil) end
      assert_raise error, message, fn -> module.start_link(nil, nil, nil) end
      assert_raise error, message, fn -> module.stop(nil, nil, nil) end
      assert_raise error, message, fn -> module.whereis(nil) end

      # GenServer callbacks
      assert_raise error, message, fn -> module.code_change(nil, nil, nil) end
      assert_raise error, message, fn -> module.format_status(nil, nil) end
      assert_raise error, message, fn -> module.handle_call(nil, nil, nil) end
      assert_raise error, message, fn -> module.handle_cast(nil, nil) end
      assert_raise error, message, fn -> module.handle_continue(nil, nil) end
      assert_raise error, message, fn -> module.init(nil) end
      assert_raise error, message, fn -> module.terminate(nil, nil) end
    end

    test "creates boilerplate functions which can be overridden" do
      module = PlusOneUpdoot.module!()
      message = "implemented :)"

      Code.eval_string("""
        defmodule #{inspect(module)} do
          use Gin.Server

          def abcast(_, _, _), do: #{inspect(message)}
          def call(_, _, _), do: #{inspect(message)}
          def cast(_, _) , do: #{inspect(message)}
          def multi_call(_, _, _, _), do: #{inspect(message)}
          def reply(_, _), do: #{inspect(message)}
          def start(_, _, _), do: #{inspect(message)}
          def start_link(_, _, _), do: #{inspect(message)}
          def stop(_, _, _), do: #{inspect(message)}
          def whereis(_), do: #{inspect(message)}

          def code_change(_, _, _), do: #{inspect(message)}
          def format_status(_, _), do: #{inspect(message)}
          def handle_call(_, _, _), do: #{inspect(message)}
          def handle_cast(_, _), do: #{inspect(message)}
          def handle_continue(_, _), do: #{inspect(message)}
          def handle_info(_, _), do: #{inspect(message)}
          def init(_), do: #{inspect(message)}
          def terminate(_, _), do: #{inspect(message)}
        end
      """) 

      # GenServer functions
      assert module.abcast(nil, nil, nil) == message
      assert module.call(nil, nil, nil) == message
      assert module.cast(nil, nil) == message
      assert module.multi_call(nil, nil, nil, nil) == message
      assert module.reply(nil, nil) == message
      assert module.start(nil, nil, nil) == message
      assert module.start_link(nil, nil, nil) == message
      assert module.stop(nil, nil, nil) == message
      assert module.whereis(nil) == message

      # GenServer callbacks
      assert module.code_change(nil, nil, nil) == message
      assert module.format_status(nil, nil) == message
      assert module.handle_call(nil, nil, nil) == message
      assert module.handle_cast(nil, nil) == message
      assert module.handle_continue(nil, nil) == message
      assert module.init(nil) == message
      assert module.terminate(nil, nil) == message
    end
  end
end
