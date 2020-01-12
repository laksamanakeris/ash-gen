defmodule <%= inspect context.module %> do
  @moduledoc """
  The <%= context.name %> context.
  """

  import Ecto.Query, warn: false
  use Ash.Helpers.UsePolicy
  alias <%= inspect schema.repo %>
end
