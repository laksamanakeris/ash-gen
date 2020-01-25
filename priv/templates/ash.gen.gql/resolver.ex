defmodule <%= inspect gql.schema_alias %>Resolver do
  alias <%= inspect context.module %>

  def all(args, _info) do
    {:ok, <%= inspect context.alias %>.list_<%= schema.singular %>s(args)}
  end

  def find(%{id: id}, _info) do
    <%= inspect context.alias %>.fetch_<%= schema.singular %>(id)
  end

  def find(args, _info) do
    case <%= inspect context.alias %>.get_<%= schema.singular %>_by(args) do
      nil -> {:error, "Can't find a <%= schema.singular %> with given parameters."}
      <%= schema.singular %> -> {:ok, <%= schema.singular %>}
    end
  end

  def create(args, _info) do
    case <%= inspect context.alias %>.create_<%= schema.singular %>(args) do
      {:ok, <%= schema.singular %>} -> {:ok, <%= schema.singular %>}
      error -> error
    end
  end

  def update(%{id: id, <%= schema.singular %>: <%= schema.singular %>_params}, info) do
    %{current_user: current_user} = info.context

    with {:ok, <%= schema.singular %>} <- <%= inspect context.alias %>.fetch_<%= schema.singular %>(id) do
      case <%= inspect context.alias %>.permit(:update_<%= schema.singular %>, current_user, <%= schema.singular %>) do
        :ok -> <%= inspect context.alias %>.update_<%= schema.singular %>(<%= schema.singular %>, <%= schema.singular %>_params)
        error -> error
      end
    end
  end

  def delete(%{id: id}, info) do
    %{current_user: current_user} = info.context

    with {:ok, <%= schema.singular %>} <- <%= inspect context.alias %>.fetch_<%= schema.singular %>(id) do
      case <%= inspect context.alias %>.permit(:delete_<%= schema.singular %>, current_user, <%= schema.singular %>) do
        :ok -> <%= inspect context.alias %>.delete_<%= schema.singular %>(<%= schema.singular %>)
        error -> error
      end
    end
  end
end
