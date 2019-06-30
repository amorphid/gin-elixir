alias Gin.Type

defprotocol Type do
  def type?(_)
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
      false
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
  def type?(_arg) do
    false
  end
end
   
defimpl Type, for: BitString do
  def type?(_arg) do
    false
  end
end

defimpl Type, for: Float do
  def type?(_arg) do
    false
  end
end

defimpl Type, for: Function do
  def type?(_arg) do
    false
  end
end

defimpl Type, for: Integer do
  def type?(_arg) do
    false
  end
end

defimpl Type, for: List do
  def type?(_arg) do
    false
  end
end

defimpl Type, for: PID do
  def type?(_arg) do
    false
  end
end

defimpl Type, for: Port do
  def type?(_arg) do
    false
  end
end

defimpl Type, for: Tuple do
  def type?(_arg) do
    false
  end
end
