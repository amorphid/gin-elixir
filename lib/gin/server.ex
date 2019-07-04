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
      :ok = register_init_action_with_undefined_placeholder()
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

  defmacro define_default_init_action() do
    quote do
      {:init_action, :undefined} = @__init_action__
      @__init_action__ {:init_action, {:defined, nil}}
      :ok
    end
  end

  defmacro define_init_return_with_action() do
    quote do
      case @__init_action__ do
        {:init_action, {:defined, nil}} ->
          def init_return_with_action(%__MODULE__{} = data) do
            {:ok, data}
          end

        {:init_action, {:defined, {:continue, _}}} -> 
          def init_return_with_action(%__MODULE__{} = data) do
            {:init_action, {:defined, {:continue, value}}} = @__init_action__
            {:ok, data, {:continue, value}}
          end

        {:init_action, {:defined, :hibernate}} -> 
          def init_return_with_action(%__MODULE__{} = data) do
            {:init_action, {:defined, :hibernate}} = @__init_action__
            {:ok, data, :hibernate}
          end

        {:init_action, {:defined, :ignore}} -> 
          def init_return_with_action(%__MODULE__{} = _data) do
            {:init_action, {:defined, :ignore}} = @__init_action__
            :ignore
          end

        {:init_action, {:defined, {:stop, reason}}} ->
          def init_return_with_action(%__MODULE__{} = _data) do
            {:init_action, {:defined, {:stop, reason}}} = @__init_action__
            {:stop, reason}
          end

        {:init_action, {:defined, {:timeout_in_milliseconds, _}}} ->
          def init_return_with_action(%__MODULE__{} = data) do
            {:init_action, {:defined, {:timeout_in_milliseconds, ms}}} = @__init_action__
            {:ok, data, ms}
          end
      end

      defoverridable init_return_with_action: 1
      :ok
    end
  end

  defmacro defstruct(opts) do
    quote do
      opts = unquote(opts)
      :ok = validate_struct_opts!(opts)
      :ok = register_struct_opts!(opts)
      :ok = define_validate_data!()
      :ok = define_default_init_action() 
      Kernel.defstruct(opts)
      :ok = define_init_return_with_action()
    end
  end

  defmacro init_action(action) do
    quote do
      action = unquote(action)

      case action do
        [continue: value] -> 
          {:init_action, {:defined, _}} = @__init_action__
          @__init_action__ {:init_action, {:defined, {:continue, value}}}

        :hibernate -> 
          {:init_action, {:defined, _}} = @__init_action__
          @__init_action__ {:init_action, {:defined, :hibernate}}

        :ignore -> 
          {:init_action, {:defined, _}} = @__init_action__
          @__init_action__ {:init_action, {:defined, :ignore}}

        [stop: reason] -> 
          {:init_action, {:defined, _}} = @__init_action__
          @__init_action__ {:init_action, {:defined, {:stop, reason}}}

        [timeout_in_milliseconds: ms] when is_integer(ms) -> 
          {:init_action, {:defined, _}} = @__init_action__
          @__init_action__ {:init_action, {:defined, {:timeout_in_milliseconds, ms}}}
      end

      define_init_return_with_action()
    end
  end

  defmacro register_init_action_with_undefined_placeholder() do
    quote do
      @__init_action__ {:init_action, :undefined}
      :ok
    end
  end

  def register_struct_opts(opts) do
    quote do
      opts = unquote(opts)
      @__struct_opts__ opts
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
