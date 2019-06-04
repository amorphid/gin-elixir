defmodule Gin.ServerTest do
  use ExUnit.Case, async: true

  defmodule MyStruct do
    use Gin.Server

    defstruct do
      defkey(:name,
        default: __MODULE__,
        type: Atom
      )

      defkey(:pid,
        default: EC2OfferDownloader,
        types: [Atom, PID]
      )

      defkey(:poll_interval,
        default: 3_600_000,
        type: Integer
      )

      defkey(:uri,
        default: %URI{
          authority: "pricing.us-east-1.amazonaws.com",
          fragment: nil,
          host: "pricing.us-east-1.amazonaws.com",
          path: "/offers/v1.0/aws/index.json",
          port: 443,
          query: nil,
          scheme: "https",
          userinfo: nil
        },
        type: URI
      )
    end
  end

  defmodule TimesOutOnInitServer do
    use Gin.Server

    defstruct do
      defkey(:init_timeout, default: 0, type: Integer)
      defkey(:name, type: Atom)
      defkey(:state, default: :off, type: Atom)
    end

    def handle_info(:timeout, %__MODULE__{state: :off} = data) do
      {:noreply, struct!(data, state: :on)}
    end
  end

  defmodule ContinuesOnInitServer do
    use Gin.Server

    defstruct do
      defkey(:init_continue, default: :turn_on, type: Atom)
      defkey(:name, type: Atom)
      defkey(:state, default: :off, type: Atom)
    end

    def handle_continue(:turn_on, %__MODULE__{state: :off} = data) do
      {:noreply, struct!(data, state: :on)}
    end
  end

  def random_name() do
    for _ <- 1..20 do
      Enum.random(?a..?z)
    end
    |> to_string()
    |> String.to_atom()
  end

  describe "defining a struct w/ multiple init actions" do
    test "raises a compile time error" do
      pattern = ~r/struct may only contain one of the following keys/

      func = fn ->
        Code.eval_string("""
        defmodule MultipleInitActionsRaisesCompileTimeErrorServer do
          use Gin.Server

          defstruct do
            defkey(:init_continue, default: :some_action, type: Atom)
            defkey(:init_timeout, default: 0, type: Integer)
          end

          def handle_continue(:some_action, %__MODULE__{} = data), do: {:noreply, data}

          def handle_info(:timeout, %__MODULE__{} = data), do: {:noreply, data}
        end
        """)
      end

      assert_raise Gin.CompileTimeError, pattern, func
    end
  end

  describe "defining a struct" do
    test "enables use of only module name as supervisor child spec" do
      name = random_name()

      Code.eval_string("""
      defmodule StartUsingOnlyModuleNameServer do
        use Gin.Server

        defstruct do
          defkey(:name, default: #{inspect(name)}, type: Atom)
        end
      end
      """)

      child_specs = [
        StartUsingOnlyModuleNameServer
      ]

      opts = [strategy: :one_for_one]
      assert Process.whereis(name) |> is_nil()
      {:ok, pid} = Supervisor.start_link(child_specs, opts)
      child = Process.whereis(name)

      expected_children = [
        {
          StartUsingOnlyModuleNameServer,
          child,
          :worker,
          [StartUsingOnlyModuleNameServer]
        }
      ]

      assert Supervisor.which_children(pid) == expected_children
    end
  end

  describe "defining a struct w/o declaring a type for every key" do
    test "raises a compile time error" do
      key = inspect(:my_key)
      pattern = ~r/for key #{key}, no type\(s\) declared/

      func = fn ->
        Code.eval_string("""
        defmodule NoTypeDeclarationRaisesCompileTimeErrorServer do
          use Gin.Server

          defstruct do
            defkey(#{key}, [])
          end
        end
        """)
      end

      assert_raise Gin.CompileTimeError, pattern, func
    end
  end

  describe "defining a struct with both :type and :types opts" do
    test "raises a compile time error" do
      key = inspect(:my_key)
      pattern = ~r/For key #{key}, cannot declare both :type & :types/

      func = fn ->
        Code.eval_string("""
        defmodule TypeAndTypesRaisesCompileTimeErrorServer do
          use Gin.Server

          defstruct do
            defkey(#{key}, type: Atom, types: [Atom, BitString])
          end
        end
        """)
      end

      assert_raise Gin.CompileTimeError, pattern, func
    end
  end

  describe "defining a struct w/ non-integer type for key init_timeout" do
    test "raises a compile time error" do
      pattern = ~r/for init_timeout, expected Integer type, got:/

      func = fn ->
        Code.eval_string("""
        defmodule NonIntegerTypeForInitTimeoutRaisesCompileTimeErrorServer do
          use Gin.Server

          defstruct do
            defkey(:init_timeout, type: BitString)
          end
        end
        """)
      end

      assert_raise Gin.CompileTimeError, pattern, func
    end
  end

  describe "defining a struct with an init continue action" do
    test "triggers the appropriate handle_continue callback on start" do
      {:ok, pid} = ContinuesOnInitServer.start_link(%{name: random_name()})
      assert :sys.get_state(pid).state == :on
    end
  end

  describe "defining a struct with an init timeout of 0" do
    test "triggers timeout callback on start" do
      {:ok, pid} = TimesOutOnInitServer.start_link(%{name: random_name()})
      assert :sys.get_state(pid).state == :on
    end
  end

  describe "defining a struct w/ &defstruct/1" do
    test "autogenerates &start_link/1 & sets state to the struct" do
      {:ok, pid} = MyStruct.start_link(%{name: random_name()})
      assert is_pid(pid)
      assert %MyStruct{} = :sys.get_state(pid)
    end

    test "autogenerates &init/1 w/ type guards for struct values" do
      assert {:ok, %MyStruct{}} = MyStruct.init(%MyStruct{})

      # :name is Atom
      atom_name = random_name()
      string_name = Atom.to_string(atom_name)

      assert {:ok, %MyStruct{name: atom_name}} =
               MyStruct.init(%MyStruct{name: atom_name})

      assert_raise FunctionClauseError, fn ->
        MyStruct.init(%MyStruct{name: string_name})
      end

      # :pid is Atom or PID
      atom_pid = MyStruct
      pid_pid = self()
      string_pid = "MyStruct"

      assert {:ok, %MyStruct{pid: atom_pid}} =
               MyStruct.init(%MyStruct{pid: atom_pid})

      assert {:ok, %MyStruct{pid: pid_pid}} =
               MyStruct.init(%MyStruct{pid: pid_pid})

      assert_raise FunctionClauseError, fn ->
        MyStruct.init(%MyStruct{pid: string_pid})
      end

      # :polling_interval is Integer
      integer_number = 123
      string_number = "123"

      assert {:ok, %MyStruct{poll_interval: integer_number}} =
               MyStruct.init(%MyStruct{poll_interval: integer_number})

      assert_raise FunctionClauseError, fn ->
        MyStruct.init(%MyStruct{pid: string_number})
      end

      # :uri is URI struct
      uri_uri = %URI{
        authority: "www.googlle.com",
        fragment: nil,
        host: "www.googlle.com",
        path: nil,
        port: 443,
        query: nil,
        scheme: "https",
        userinfo: nil
      }

      string_uri = "https://www.google.com"

      assert {:ok, %MyStruct{uri: uri_uri}} =
               MyStruct.init(%MyStruct{uri: uri_uri})

      assert_raise FunctionClauseError, fn ->
        MyStruct.init(%MyStruct{uri: string_uri})
      end
    end
  end
end
