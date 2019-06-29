defmodule Gin.Error do
  defmacro __using__(_opts) do
    quote do
      defdelegate raise_compile_error(msg), to: Gin.Error.Compile, as: :raise

      defdelegate raise_runtime_error(msg), to: Gin.Error.Runtime, as: :raise
    end
  end

  defmodule Base do
    defmacro __using__(_opts) do
      quote do
        defexception message: nil

        def raise(
              msg \\ "something went wrong (or right, if you're into this sort of thing)"
            ) do
          raise __MODULE__, message: msg
        end
      end
    end
  end

  defmodule Compile do
    use Base
  end

  defmodule Runtime do
    use Base
  end
end
