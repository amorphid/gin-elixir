alias Gin.Type

defprotocol Type do
  @moduledoc false

  @fallback_to_any true

  def type?(_)

  def built_in_type?(_)

  def struct_type?(_)
end

defimpl Type, for: Atom do
  @built_in_types MapSet.new([
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
                  ])

  def built_in_type?(arg) do
    MapSet.member?(@built_in_types, arg)
  end

  def struct_type?(arg) do
      arg.__struct__().__struct__ == arg
  rescue
    UndefinedFunctionError ->
      try do
        %{__struct__: ^arg} =
          Module.open?(arg) &&
          Module.defines?(arg, {:__struct__, 0}) &&
          Module.get_attribute(arg, :struct)
        true
      rescue
        MatchError ->
          false
      end
  end

  def type?(arg) do
    cond do
      built_in_type?(arg) ->
        true

      struct_type?(arg) ->
        true

      true ->
        false
    end
  end
end

defimpl Type, for: Any do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end

defimpl Type, for: BitString do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end

defimpl Type, for: Float do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end

defimpl Type, for: Function do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end

defimpl Type, for: Integer do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end

defimpl Type, for: List do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end

defimpl Type, for: PID do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end

defimpl Type, for: Port do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end

defimpl Type, for: Tuple do
  def built_in_type?(_), do: false

  def struct_type?(_), do: false

  def type?(_), do: false
end
