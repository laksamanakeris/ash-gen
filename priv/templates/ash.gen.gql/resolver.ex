defmodule <%= inspect gql.schema_alias %>Resolver do
  alias AshServer.Accounts

  def all(args, _info) do
    {:ok, Accounts.list_<%= schema.singular %>s(args)}
  end

  def find(%{id: id}, _info) do
    Accounts.fetch_<%= schema.singular %>(id)
  end

  def find(args, _info) do
    case Accounts.get_<%= schema.singular %>_by(args) do
      nil -> {:error, "Can't find a <%= schema.singular %> with given parameters."}
      <%= schema.singular %> -> {:ok, <%= schema.singular %>}
    end
  end

  def create(args, _info) do
    case Accounts.create_<%= schema.singular %>(args) do
      {:ok, <%= schema.singular %>} -> {:ok, <%= schema.singular %>}
      error -> error
    end
  end

  def update(%{id: id, <%= schema.singular %>: <%= schema.singular %>_params}, info) do
    %{current_user: current_user} = info.context

    with {:ok, <%= schema.singular %>} <- Accounts.fetch_<%= schema.singular %>(id) do
      case Accounts.permit(:update_<%= schema.singular %>, current_user, <%= schema.singular %>) do
        :ok -> Accounts.update_<%= schema.singular %>(<%= schema.singular %>, <%= schema.singular %>_params)
        error -> error
      end
    end
  end

  def delete(%{id: id}, info) do
    %{current_user: current_user} = info.context

    with {:ok, <%= schema.singular %>} <- Accounts.fetch_<%= schema.singular %>(id) do
      case Accounts.permit(:delete_<%= schema.singular %>, current_user, <%= schema.singular %>) do
        :ok -> Accounts.delete_<%= schema.singular %>(<%= schema.singular %>)
        error -> error
      end
    end
  end
end
