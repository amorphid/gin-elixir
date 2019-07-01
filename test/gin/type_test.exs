defmodule Gin.TypeTest do
  use ExUnit.Case, async: true
  alias Gin.Type

  describe "&struct_type?/1" do
    test "while module is open, returns true if struct already defined" do
      module = PlusOneUpdoot.module!()

      {{_, ^module, _, maybe_true}, []} =
        Code.eval_string("""
          defmodule #{inspect(module)} do
            defstruct []

            Gin.Type.struct_type?(__MODULE__)
          end
        """)

      assert maybe_true == true
    end

    test "while module is open, returns false if struct notalready defined" do
      module = PlusOneUpdoot.module!()

      {{_, ^module, _, maybe_true}, []} =
        Code.eval_string("""
          defmodule #{inspect(module)} do
            maybe_true = Gin.Type.struct_type?(__MODULE__)

            defstruct []

            maybe_true
          end
        """)

      assert maybe_true == false
    end

    test "returns false for actual structs" do
      module = PlusOneUpdoot.module!()

      Code.eval_string("""
        defmodule #{inspect(module)} do
          defstruct []
        end
      """)

      struct0 = struct!(module, [])
      struct1 = %MapSet{}
      struct2 = %URI{}

      structs = [
        struct0,
        struct1,
        struct2
      ]

      for struct <- structs do
        assert Type.struct_type?(struct) == false
      end
    end
  end

  describe "&type?/1" do
    test "built in types return true" do
      built_in_types = [
        Atom,
        BitString,
        Float,
        Function,
        Integer,
        List,
        Map,
        PID,
        Port,
        Reference,
        Tuple
      ]

      for built_in_type <- built_in_types do
        assert Type.type?(built_in_type)
      end
    end

    test "w/ a defined struct returns true" do
      module = PlusOneUpdoot.module!()

      Code.eval_string("""
        defmodule #{inspect(module)} do
          defstruct []
        end
      """)

      struct_types = [
        module,
        MapSet,
        URI
      ]

      for struct_type <- struct_types do
        assert Type.type?(struct_type)
      end
    end

    test "modules w/o a struct type return false" do
      module = PlusOneUpdoot.module!()

      Code.eval_string("""
        defmodule #{inspect(module)} do
        end
      """)

      assert Type.type?(module) == false
    end
  end
end
