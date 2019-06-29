defmodule Gin.Server do
  defmacro __using__(_) do
    quote do
      use GenServer
      import Kernel, except: [defstruct: 1]
      import unquote(__MODULE__)


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
      Kernel.defstruct(opts)
    end
  end
end
