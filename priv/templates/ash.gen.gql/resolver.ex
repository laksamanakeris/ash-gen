defmodule <%= inspect gql.schema_alias %>Resolver do
  alias <%= inspect context.base_module %>.Accounts.User
  alias <%= inspect context.module %>

  def all(args, _info) do
    {:ok, <%= inspect context.alias %>.list_<%= schema.plural %>(args)}
  end

  def find(%{id: id}, _info) do
    <%= inspect context.alias %>.fetch_<%= schema.singular %>(id)
  end

  def create(%{<%= schema.singular %>: <%= schema.singular %>}, _info) do
    case <%= inspect context.alias %>.create_<%= schema.singular %>(<%= schema.singular %>) do
      {:ok, <%= schema.singular %>} -> {:ok, <%= schema.singular %>}
      {:error, error} -> {:error, error}
    end
  end

  def update(%{id: id, <%= schema.singular %>: <%= schema.singular %>_params}, info) do
    with %{current_user: %User{} = current_user} = info.context,
    {:ok, <%= schema.singular %>} <- <%= inspect context.alias %>.fetch_<%= schema.singular %>(id),
    :ok <- <%= inspect context.alias %>.permit(:update_<%= schema.singular %>, current_user, <%= schema.singular %>) do
      <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>, <%= schema.singular %>_params)
    else
      {:error, error} -> {:error, error}
      _ -> {:error, "Something went wrong"}
    end
  end

  def delete(%{id: id}, info) do
    with %{current_user: %User{} = current_user} = info.context,
    {:ok, <%= schema.singular %>} <- <%= inspect context.alias %>.fetch_<%= schema.singular %>(id),
    :ok <- <%= inspect context.alias %>.permit(:delete_<%= schema.singular %>, current_user, <%= schema.singular %>) do
      <%= inspect context.alias %>.delete_<%= schema.singular %>(<%= schema.singular %>)
    else
      {:error, error} -> {:error, error}
      _ -> {:error, "Something went wrong"}
    end
  end
end
