defmodule Gin.Server do
  @__native_types__ [
    Tuple,
    Atom,
    List,
    BitString,
    Integer,
    Float,
    Function,
    PID,
    Map,
    Port
  ]

  @__native_type_guard_index__ %{
    Atom => :is_atom,
    BitString => :is_bitstring,
    Float => :is_float,
    Function => :is_function,
    Integer => :is_integer,
    List => :is_list,
    Map => :is_map,
    PID => :is_pid,
    Port => :is_port,
    Reference => :is_reference,
    Tuple => :is_tuple
  }

  defmacro __using__(_opts) do
    quote do
      use GenServer
      import Kernel, except: [defstruct: 1]
      import unquote(__MODULE__)

      @__init_actions__ [
        :init_continue,
        :init_timeout
      ]
      Module.register_attribute(__MODULE__, :__struct_keys__, accumulate: true)
    end
  end

  defmacro defkey(key, opts) when is_atom(key) do
    quote do
      @__struct_keys__ {unquote(key), unquote(opts)}
    end
  end

  defmacro defstruct(opts) do
    quote do
      unquote(opts)

      @__struct_keys__
      |> Enum.map(fn {key, opts} ->
        {key, Keyword.get(opts, :default, nil)}
      end)
      |> case do
        opts ->
          Kernel.defstruct(opts)
      end

      def start_link(otps \\ %{})

      def start_link([]) do
        start_link()
      end

      def start_link(%{} = opts) do
        data = struct!(__MODULE__, opts)
        GenServer.start_link(__MODULE__, data, name: data.name)
      end

      @__struct_keys__
      |> Enum.with_index()
      |> Enum.map(&build_guards/1)
      |> case do
        guards ->
          [
            "def init(%__MODULE__{",
            guards
            |> List.flatten()
            |> Enum.map(fn
              %{type: type} = guard when type == :built_in or type == :struct ->
                Map.fetch!(guard, :key_value_pair_str)
            end)
            |> Enum.uniq()
            |> Enum.join(", "),
            "} = data) ",
            guards
            |> Enum.filter(fn
              %{type: type} ->
                type == :built_in

              [_ | _] = guards ->
                Enum.all?(guards, fn %{type: type} ->
                  type == :built_in
                end)
            end)
            |> case do
              built_ins when length(built_ins) != [] ->
                [
                  "when ",
                  built_ins
                  |> Enum.map(fn
                    %{} = built_in ->
                      Map.fetch!(built_in, :guard_str)

                    [_ | _] = built_ins ->
                      built_ins
                      |> Enum.map(fn built_in ->
                        Map.fetch!(built_in, :guard_str)
                      end)
                      |> Enum.join(" or ")
                      |> case do
                        built_ins ->
                          [
                            "(",
                            built_ins,
                            ")"
                          ]
                          |> Enum.join("")
                      end
                  end)
                  |> Enum.join(" and "),
                  ","
                ]

              _ ->
                ","
            end,
            " do: {:ok, data",
            cond do
              for(
                action <- @__init_actions__,
                do: Enum.count(Keyword.get_values(@__struct_keys__, action))
              )
              |> Enum.sum() > 1 ->
                raise Gin.CompileTimeError,
                  message:
                    "struct may only contain one of the following keys: #{
                      String.slice(inspect(@__init_actions__), 1..-2)
                    }"

              Keyword.has_key?(@__struct_keys__, :init_timeout) &&
                  is_integer(
                    Keyword.fetch!(@__struct_keys__, :init_timeout)[:default]
                  ) ->
                ", data.init_timeout}"

              Keyword.has_key?(@__struct_keys__, :init_timeout) &&
                  Keyword.fetch!(@__struct_keys__, :init_timeout)[:type] !=
                    Integer ->
                raise Gin.CompileTimeError,
                  message:
                    "for init_timeout, expected Integer type, got: #{
                      inspect(
                        Keyword.fetch!(@__struct_keys__, :init_timeout)[:type]
                      )
                    }"

              Keyword.has_key?(@__struct_keys__, :init_continue) ->
                ", {:continue, data.init_continue}}"

              true ->
                "}"
            end
          ]
      end
      |> Enum.join("")
      |> Code.string_to_quoted()
      |> case do
        quoted ->
          Module.eval_quoted(__MODULE__, quoted)
      end
    end
  end

  def build_guard(key, type, index, _opts) do
    if type in @__native_types__ do
      %{
        guard_str: "#{@__native_type_guard_index__[type]}(arg#{index})",
        key_value_pair_str: "#{inspect(key)} => arg#{index}",
        type: :built_in
      }
    else
      %{
        key_value_pair_str:
          "#{inspect(key)} => %#{inspect(type)}{} = _arg#{index}",
        type: :struct
      }
    end
  end

  def build_guards({{key, opts}, index}) do
    cond do
      Keyword.has_key?(opts, :types) &&
          Enum.all?(opts[:types], &is_protocol_compatible_type?/1) ->
        Enum.map(opts[:types], fn type ->
          opts
          |> Keyword.delete(:types)
          |> case do
            opts ->
              build_guard(key, type, index, opts)
          end
        end)

      Keyword.has_key?(opts, :type) && is_protocol_compatible_type?(opts[:type]) ->
        build_guard(key, opts[:type], index, Keyword.delete(opts, :type))

      true ->
        raise Gin.CompileTimeError,
          message: "valid type(s) not defined for key #{inspect(key)}"
    end
  end

  def is_protocol_compatible_type?(arg) when arg in @__native_types__ do
    true
  end

  def is_protocol_compatible_type?(arg) when is_atom(arg) do
    arg.module_info[:module] == arg && arg.__struct__().__struct__ == arg
  rescue
    UndefinedFunctionError ->
      false
  end

  def is_protocol_compatible_type?(_) do
    false
  end
end
