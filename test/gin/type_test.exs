defmodule Gin.TypeTest do
  use ExUnit.Case, async: true
  alias Gin.Type

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

    test "struct types return true" do
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
