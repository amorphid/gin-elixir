defmodule Gin.Server do
  alias Gin.Type

  def __after_compile__(env, _) do
    :ok = validate_struct_defined!(env.module)
  end

  defmacro __using__(_) do
    quote do
      use GenServer
      import Kernel, except: [defstruct: 1]
      import unquote(__MODULE__)

      :ok = validate_struct_not_defined!()
      @after_compile unquote(__MODULE__)

      #######
      # API #
      #######

      def abcast(_, _, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable abcast: 3

      def call(_, _, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable call: 3

      def cast(_, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable cast: 2

      def multi_call(_, _, _, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable multi_call: 4

      def reply(_, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable reply: 2

      def start(_, _, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable start: 3

      def start_link(_, _, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable start_link: 3

      def stop(_, _, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable stop: 3

      def whereis(_), do: Gin.raise_runtime_error("not implemented")

      defoverridable whereis: 1

      #############
      # Callbacks #
      #############

      def code_change(_, _, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable code_change: 3

      def format_status(_, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable format_status: 2

      def handle_call(_, _, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable handle_call: 3

      def handle_cast(_, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable handle_cast: 2

      def handle_continue(_, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable handle_continue: 2

      def handle_info(_, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable handle_info: 2

      def init(_), do: Gin.raise_runtime_error("not implemented")

      defoverridable init: 1

      def terminate(_, _), do: Gin.raise_runtime_error("not implemented")

      defoverridable terminate: 2
    end
  end

  defmacro defstruct(opts) do
    quote do
      opts = unquote(opts)
      :ok = validate_struct_opts!(opts)
      Kernel.defstruct(opts)
    end
  end

  defmacro validate_struct_not_defined!() do
    quote do
      if Type.struct_type?(__MODULE__) == false do
        :ok
      else
        msg = "For module #{inspect(__MODULE__)}, struct defined before 'use Gin.Server'"
        Gin.raise_compile_error(msg)
      end
    end
  end

  def validate_struct_defined!(module) do
    if Type.struct_type?(module) do
      :ok
    else
      msg = "For module #{inspect(module)}, no struct defined"
      Gin.raise_compile_error(msg)
    end
  end

  def validate_struct_opt!(opt) do
    :ok = validate_struct_opt_type_or_types!(opt)
    :ok
  end

  def validate_struct_opt_type_or_types!({key, %{type: _, types: _}}) do
    msg = "For struct key #{inspect(key)}, both type and types declared"
    Gin.raise_compile_error(msg)
  end

  def validate_struct_opt_type_or_types!({key, %{types: types} = key_opts})
      when is_list(types) do
    for type <- types do
      key_opts
      |> Map.delete(:types)
      |> Map.put(:type, type)
      |> case do
        key_opts ->
          validate_struct_opt_type_or_types!({key, key_opts})
      end
    end
  end

  def validate_struct_opt_type_or_types!({key, %{type: maybe_type}}) do
    if Type.type?(maybe_type) do
      true
    else
      msg =
        "For struct key #{inspect(key)}, the type #{inspect(maybe_type)} is not supported"

      Gin.raise_compile_error(msg)
    end
  end

  def validate_struct_opt_type_or_types!({key, %{}}) do
    msg = "For struct key #{inspect(key)}, no type(s) declared"
    Gin.raise_compile_error(msg)
  end

  def validate_struct_opts!([]), do: :ok

  def validate_struct_opts!([h | t]) do
    :ok = validate_struct_opt!(h)
    validate_struct_opts!(t)
  end
end
