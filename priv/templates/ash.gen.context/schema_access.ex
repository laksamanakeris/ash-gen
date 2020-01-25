
  alias <%= inspect schema.module %>

  @doc """
  Returns the list of <%= schema.plural %>.

  ## Examples

      iex> list_<%= schema.plural %>()
      [%<%= inspect schema.alias %>{}, ...]

  """
  def list_<%= schema.plural %>(args) do
    args
    |> Enum.reduce(<%= inspect schema.alias %>, fn
      {:filter, filter}, query ->
        filter_<%= schema.plural %>_with(query, filter)
      {:order_by, order}, query ->
        QueryHelpers.order_list_by(query, order)
    end)
    |> Repo.all
  end

  @doc """
  Gets a single <%= schema.singular %> and returns a tuple with result.

  ## Examples
  s
      iex> fetch_<%= schema.singular %>(123)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> fetch_<%= schema.singular %>(456)
      {:error, %EctoQuery{}}

  """
  def fetch_<%= schema.singular %>(id), do: Repo.fetch(<%= inspect schema.alias %>, id)

  @doc """
  Gets a single <%= schema.singular %>.

  Raises `Ecto.NoResultsError` if the <%= schema.human_singular %> does not exist.

  ## Examples

      iex> get_<%= schema.singular %>!(123)
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>!(456)
      ** (Ecto.NoResultsError)

  """
  def get_<%= schema.singular %>!(id), do: Repo.get!(<%= inspect schema.alias %>, id)

  @doc """
  Gets a single <%= schema.singular %> by specified criteria.

  Raises `Ecto.NoResultsError` if the <%= inspect schema.alias %> does not exist.

  ## Examples

      iex> get_<%= schema.singular %>_by(%{field: "good_val"})
      %<%= inspect schema.alias %>{}

      iex> get_<%= schema.singular %>_by(%{field: "bad_val"})
      ** (Ecto.NoResultsError)s

  """
  def get_<%= schema.singular %>_by(args \\ %{}) do
    <%= inspect schema.alias %>
    |> QueryHelpers.build_query(args)
    |> first
    |> Repo.one
  end

  @doc """
  Creates a <%= schema.singular %>.

  ## Examples

      iex> create_<%= schema.singular %>(%{field: value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> create_<%= schema.singular %>(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_<%= schema.singular %>(attrs \\ %{}) do
    %<%= inspect schema.alias %>{}
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a <%= schema.singular %>.

  ## Examples

      iex> update_<%= schema.singular %>(<%= schema.singular %>, %{field: new_value})
      {:ok, %<%= inspect schema.alias %>{}}

      iex> update_<%= schema.singular %>(<%= schema.singular %>, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>, attrs) do
    <%= schema.singular %>
    |> <%= inspect schema.alias %>.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a <%= inspect schema.alias %>.

  ## Examples

      iex> delete_<%= schema.singular %>(<%= schema.singular %>)
      {:ok, %<%= inspect schema.alias %>{}}

      iex> delete_<%= schema.singular %>(<%= schema.singular %>)
      {:error, %Ecto.Changeset{}}

  """
  def delete_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>) do
    Repo.delete(<%= schema.singular %>)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking <%= schema.singular %> changes.

  ## Examples

      iex> change_<%= schema.singular %>(<%= schema.singular %>)
      %Ecto.Changeset{source: %<%= inspect schema.alias %>{}}

  """
  def change_<%= schema.singular %>(%<%= inspect schema.alias %>{} = <%= schema.singular %>) do
    <%= inspect schema.alias %>.changeset(<%= schema.singular %>, %{})
  end
