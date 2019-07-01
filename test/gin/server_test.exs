defmodule Gin.ServerTest do
  use ExUnit.Case, async: true

  describe "the init action" do
    test "is set to nil when defining a struct" do
      module = PlusOneUpdoot.module!()

      {{_, _, _, {before_struct, after_struct}}, _} = 
        Code.eval_string("""
          defmodule #{inspect(module)} do
            use Gin.Server

            before_struct = Module.get_attribute(__MODULE__, :__init_action__)

            defstruct []

            after_struct = Module.get_attribute(__MODULE__, :__init_action__)
            
            {before_struct, after_struct}
          end
        """)

      arg = struct!(module, [])

      assert before_struct == {:init_action, :undefined}
      assert after_struct == {:init_action, {:defined, nil}}
      # init_return_with_action simply returns {:ok, arg}
      #   when defined init init_action is nil
      assert module.init_return_with_action(arg) == {:ok, arg}
    end

    test "can be a timeout in milliseconds" do
      module = PlusOneUpdoot.module!()
      timeout_in_milliseconds = 1234

      {{_, _, _, {before_init_action, after_init_action}}, _} = 
        Code.eval_string("""
          defmodule #{inspect(module)} do
            use Gin.Server

            defstruct []

            before_init_action = Module.get_attribute(__MODULE__, :__init_action__)

            init_action timeout_in_milliseconds: #{inspect(timeout_in_milliseconds)}

            after_init_action = Module.get_attribute(__MODULE__, :__init_action__)
            
            {before_init_action, after_init_action}
          end
        """)

      arg = struct!(module, [])

      assert before_init_action == {:init_action, {:defined, nil}}
      assert after_init_action == {:init_action, {:defined, {:timeout_in_milliseconds, 1234}}}
      assert module.init_return_with_action(arg) == {:ok, arg, 1234}
    end

    test "can be a continue w/ value" do
      module = PlusOneUpdoot.module!()
      value = "I am a value lol :)"
      init_action = [continue: value]

      {{_, _, _, {before_init_action, after_init_action}}, _} = 
        Code.eval_string("""
          defmodule #{inspect(module)} do
            use Gin.Server

            defstruct []

            before_init_action = Module.get_attribute(__MODULE__, :__init_action__)

            init_action #{inspect(init_action)}

            after_init_action = Module.get_attribute(__MODULE__, :__init_action__)
            
            {before_init_action, after_init_action}
          end
        """)

      arg = struct!(module, [])

      assert before_init_action == {:init_action, {:defined, nil}}
      assert after_init_action == {:init_action, {:defined, {:continue, value}}}
      assert module.init_return_with_action(arg) == {:ok, arg, {:continue, value}}
    end

    test "can be to hibernate" do
      module = PlusOneUpdoot.module!()
      init_action = :hibernate

      {{_, _, _, {before_init_action, after_init_action}}, _} = 
        Code.eval_string("""
          defmodule #{inspect(module)} do
            use Gin.Server

            defstruct []

            before_init_action = Module.get_attribute(__MODULE__, :__init_action__)

            init_action #{inspect(init_action)}

            after_init_action = Module.get_attribute(__MODULE__, :__init_action__)
            
            {before_init_action, after_init_action}
          end
        """)

      arg = struct!(module, [])

      assert before_init_action == {:init_action, {:defined, nil}}
      assert after_init_action == {:init_action, {:defined, :hibernate}}
      assert module.init_return_with_action(arg) == {:ok, arg, :hibernate}
    end

    test "can be ignore" do
      module = PlusOneUpdoot.module!()
      init_action = :ignore

      {{_, _, _, {before_init_action, after_init_action}}, _} = 
        Code.eval_string("""
          defmodule #{inspect(module)} do
            use Gin.Server

            defstruct []

            before_init_action = Module.get_attribute(__MODULE__, :__init_action__)

            init_action #{inspect(init_action)}

            after_init_action = Module.get_attribute(__MODULE__, :__init_action__)
            
            {before_init_action, after_init_action}
          end
        """)

      arg = struct!(module, [])

      assert before_init_action == {:init_action, {:defined, nil}}
      assert after_init_action == {:init_action, {:defined, :ignore}}
      assert module.init_return_with_action(arg) == :ignore
    end

    test "can be to stop w/ reason" do
      module = PlusOneUpdoot.module!()
      reason = "This reason is not terribly impressive, but hey, whatever"
      init_action = [stop: reason]

      {{_, _, _, {before_init_action, after_init_action}}, _} = 
        Code.eval_string("""
          defmodule #{inspect(module)} do
            use Gin.Server

            defstruct []

            before_init_action = Module.get_attribute(__MODULE__, :__init_action__)

            init_action #{inspect(init_action)}

            after_init_action = Module.get_attribute(__MODULE__, :__init_action__)
            
            {before_init_action, after_init_action}
          end
        """)

      arg = struct!(module, [])

      assert before_init_action == {:init_action, {:defined, nil}}
      assert after_init_action == {:init_action, {:defined, {:stop, reason}}}
      assert module.init_return_with_action(arg) == {:stop, reason}
    end
  end

  describe "defining a struct" do
    test "w/ key that has with 2 unsupported types raises a compile error for first unsupported type" do
      module = PlusOneUpdoot.module!()
      key = :oh_no_two_unsupported_types!
      unsupported_type0 = PlusOneUpdoot.module!()
      unsupported_type1 = PlusOneUpdoot.module!()
      types = [unsupported_type0, unsupported_type1]
      error = Gin.Error.Compile

      message =
        "For struct key #{inspect(key)}, the type #{inspect(unsupported_type0)} is not supported"

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

      message =
        "For struct key #{inspect(key)}, the type #{inspect(unsupported_type)} is not supported"

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

      message =
        "For struct key #{inspect(key)}, the type #{inspect(unsupported_type)} is not supported"

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

          defstruct []
        end
      """)

      # GenServer functions
      assert_raise error, message, fn -> module.abcast(nil, nil, nil) end
      assert_raise error, message, fn -> module.call(nil, nil, nil) end
      assert_raise error, message, fn -> module.cast(nil, nil) end

      assert_raise error, message, fn ->
        module.multi_call(nil, nil, nil, nil)
      end

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

          defstruct []

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

  describe "using a Gin.Server" do
    test "raises a compile error if a struct defined before using Gin.Server" do
      module = PlusOneUpdoot.module!()
      error = Gin.Error.Compile
      message = "For module #{inspect(module)}, struct defined before 'use Gin.Server'"

      func = fn ->
        Code.eval_string("""
          defmodule #{inspect(module)} do
            defstruct []

            use Gin.Server
          end
        """)
      end

      assert_raise error, message, func
    end

    test "raises a compile error if a struct has not been defined" do
      module = PlusOneUpdoot.module!()
      error = Gin.Error.Compile
      message = "For module #{inspect(module)}, no struct defined"

      func = fn ->
        Code.eval_string("""
          defmodule #{inspect(module)} do
            use Gin.Server
          end
        """)
      end

      assert_raise error, message, func
    end
  end
end
