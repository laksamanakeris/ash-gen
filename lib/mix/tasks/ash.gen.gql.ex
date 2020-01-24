defmodule Mix.Tasks.Ash.Gen.Gql do
  @shortdoc "Generates a context with functions around an Ecto schema"

  @moduledoc """
  Generates schema resources.
  """

  use Mix.Task

  alias Mix.Ash.Gql
  alias Mix.Tasks.Ash.Gen

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise("mix ash.gen.context can only be run inside an application directory")
    end

    {gql, context, schema} = build(args)
    binding = [gql: gql, context: context, schema: schema]
    paths = Mix.Ash.generator_paths()

    Gen.Context.run(args)

    gql
    |> copy_new_files(paths, binding)
    |> print_shell_instructions()
  end

  @doc false
  def build(args) do
    {context, schema} = Gen.Context.build(args)
    gql = Gql.new(context, schema)
    {gql, context, schema}
  end

  def files_to_be_generated(%Gql{} = gql) do
    [
      {:eex, "resolver.ex", gql.resolver_file},
      {:eex, "resolver_test.ex", gql.resolver_test_file},
      {:eex, "types.ex", gql.types_file}
    ]
  end

  @doc false
  def copy_new_files(%Gql{} = gql, paths, binding) do
    files = files_to_be_generated(gql)
    Mix.Ash.copy_from(paths, "priv/templates/ash.gen.gql", binding, files)

    gql
  end

  def print_shell_instructions(%Gql{schema: schema, context: context} = gql) do
    Mix.shell.info """

      Import the #{schema.singular} types and fields into #{Mix.Phoenix.web_path(context.context_app)}/schema.ex :

        import_types(#{inspect gql.schema_alias}Types)

        query do
          import_fields(:#{schema.singular}_queries)
        end

        mutation do
          import_fields(:#{schema.singular}_mutations)
        end

      Keep in mind that you will need to update authorization policies, resolvers and relationships as you progress with your app.
    """
  end
end
