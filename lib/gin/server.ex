defmodule Gin.Server do
  defmacro __using__(_) do
    quote do
      use GenServer
      import Kernel, except: [defstruct: 1]
      import unquote(__MODULE__)
    end
  end

  defmacro defstruct(opts) do
    quote do
      Kernel.defstruct(unquote(opts))
    end
  end
end
