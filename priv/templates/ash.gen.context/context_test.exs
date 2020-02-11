defmodule <%= inspect context.module %>Test do
  use <%= inspect context.base_module %>.DataCase
  import Ash.Factory

  alias <%= inspect context.module %>
end
