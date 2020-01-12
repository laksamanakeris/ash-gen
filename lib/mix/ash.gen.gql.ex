defmodule Mix.Tasks.Ash.Gen.Gql do
  @shortdoc "Generates a context with functions around an Ecto schema"

  @moduledoc """
  Generates schema resources.
  """

  use Mix.Task

  alias Mix.Ash.{Context, Schema}
  alias Mix.Tasks.Ash.Gen

  @switches [
    binary_id: :boolean,
    table: :string,
    web: :string,
    schema: :boolean,
    context: :boolean,
    context_app: :string
  ]

  @default_opts [schema: true, context: true]

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise("mix ash.gen.context can only be run inside an application directory")
    end

    {context, schema} = Gen.Context.build(args)
    binding = [context: context, schema: schema]
    paths = Mix.Ash.generator_paths() ++ [:ash]

    Gen.Context.run(args)

    context
    |> copy_new_files(paths, binding)
    |> print_shell_instructions()
  end

  @doc false
  def copy_new_files(context, paths, binding) do
    inject_schema_access(context, paths, binding)
    inject_policy(context, paths, binding)

    context
  end

  @doc false
  def print_shell_instructions(%Context{schema: schema}) do
    if schema.generate? do
      Gen.Schema.print_shell_instructions(schema)
    else
      :ok
    end
  end
end
