defmodule Mix.Tasks.Ash.Gen.Schema do
  @shortdoc "Generates an Ecto schema and migration file"

  @moduledoc """
  Generates an Ecto schema and migration.
  """

  use Mix.Task

  alias Mix.Ash.{Schema}

  @doc false
  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise("mix ash.gen.schema can only be run inside an application directory")
    end

    Mix.Tasks.Phx.Gen.Schema.run(args)

    schema = Mix.Tasks.Phx.Gen.Schema.build(args, [])
    paths = Mix.Ash.generator_paths()

    ctx = create_alt_context(schema)
    binding = [schema: schema, ctx: ctx]

    ctx
    |> copy_new_files(paths, binding)
  end

  def create_alt_context(schema) do
    %{
      base: Module.concat([Mix.Ash.context_base(schema.context_app)]),
      schema: struct(Schema, Map.from_struct(schema)),
      factory_file: "test/support/factory.ex"
    }
  end

  @doc false
  def files_to_be_generated(%Schema{} = schema) do
    [
      { :eex, "resource_factory.ex", "test/support/factories/#{schema.singular}_factory.ex" },
    ]
  end

  @doc false
  def copy_new_files(ctx, paths, binding) do
    files = files_to_be_generated(ctx.schema)
    Mix.Ash.copy_from(paths, "priv/templates/ash.gen.schema", binding, files)
    inject_factory_access(ctx, paths, binding)

    ctx
  end

  defp inject_factory_access(ctx, paths, binding) do
    unless Schema.pre_existing?(ctx.factory_file) do
      Mix.Generator.create_file(
        ctx.factory_file,
        Mix.Ash.eval_from(paths, "priv/templates/ash.gen.schema/factory.ex", binding)
      )
    end

    paths
    |> Mix.Ash.eval_from("priv/templates/ash.gen.schema/factory_access.ex", binding)
    |> Mix.Ash.inject_eex_before_final_end(ctx.factory_file, binding)
  end
end
