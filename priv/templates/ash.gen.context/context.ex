defmodule <%= inspect context.module %> do
  @moduledoc """
  The <%= context.name %> context.
  """

  import Ecto.Query, warn: false
  use <%= inspect context.base_module %>.Helpers.UsePolicy
  alias <%= inspect schema.repo %>
  alias <%= inspect context.base_module %>
end
