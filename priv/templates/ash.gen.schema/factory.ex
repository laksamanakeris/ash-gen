defmodule <%= inspect ctx.base %>.Factory do
  use ExMachina.Ecto, repo: <%= inspect ctx.base %>.Repo

end
