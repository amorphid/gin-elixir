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

  def random_name() do
    for _ <- 1..20 do
      Enum.random(?a..?z)
    end
    |> to_string()
    |> String.to_atom()
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
