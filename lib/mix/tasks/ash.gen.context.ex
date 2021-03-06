defmodule Mix.Tasks.Ash.Gen.Context do
  @shortdoc "Generates a context with functions around an Ecto schema"

  @moduledoc """
  Generates a context with functions around an Ecto schema.
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

    {context, schema} = build(args)
    binding = [context: context, schema: schema]
    paths = Mix.Ash.generator_paths()

    prompt_for_conflicts(context)
    prompt_for_code_injection(context)

    context
    |> copy_new_files(paths, binding)
    |> print_shell_instructions()
  end

  defp prompt_for_conflicts(context) do
    context
    |> files_to_be_generated()
    |> Mix.Ash.prompt_for_conflicts()
  end

  @doc false
  def build(args) do
    {opts, parsed, _} = parse_opts(args)
    [context_name, schema_name, plural | schema_args] = validate_args!(parsed)
    schema_module = inspect(Module.concat(context_name, schema_name))
    schema = Mix.Tasks.Phx.Gen.Schema.build([schema_module, plural | schema_args], opts, __MODULE__)
    schema = struct(Schema, Map.from_struct(schema))
    context = Context.new(context_name, schema, opts)
    {context, schema}
  end

  defp parse_opts(args) do
    {opts, parsed, invalid} = OptionParser.parse(args, switches: @switches)

    merged_opts =
      @default_opts
      |> Keyword.merge(opts)
      |> put_context_app(opts[:context_app])

    {merged_opts, parsed, invalid}
  end

  defp put_context_app(opts, nil), do: opts

  defp put_context_app(opts, string) do
    Keyword.put(opts, :context_app, String.to_atom(string))
  end

  @doc false
  def files_to_be_generated(%Context{schema: schema}) do
    if schema.generate? do
      Gen.Schema.files_to_be_generated(schema)
    else
      []
    end
  end

  @doc false
  def copy_new_files(%Context{schema: schema} = context, paths, binding) do
    if schema.generate? do
      ctx = Gen.Schema.create_alt_context(schema)
      Gen.Schema.copy_new_files(ctx, paths, binding ++ [ctx: ctx])
    end

    inject_schema_access(context, paths, binding)
    inject_tests(context, paths, binding)
    inject_loader(context, paths, binding)
    inject_policy(context, paths, binding)

    context
  end

  defp inject_schema_access(%Context{file: file} = context, paths, binding) do
    unless Context.pre_existing?(context) do
      Mix.Generator.create_file(
        file,
        Mix.Ash.eval_from(paths, "priv/templates/ash.gen.context/context.ex", binding)
      )
    end

    paths
    |> Mix.Ash.eval_from(
      "priv/templates/ash.gen.context/#{schema_access_template(context)}",
      binding
    )
    |> Mix.Ash.inject_eex_before_final_end(file, binding)
  end

  defp inject_tests(%Context{test_file: test_file} = context, paths, binding) do
    unless Context.pre_existing_tests?(context) do
      Mix.Generator.create_file(
        test_file,
        Mix.Ash.eval_from(paths, "priv/templates/ash.gen.context/context_test.exs", binding)
      )
    end

    paths
    |> Mix.Ash.eval_from("priv/templates/ash.gen.context/test_cases.exs", binding)
    |> Mix.Ash.inject_eex_before_final_end(test_file, binding)
  end

  defp inject_loader(%Context{loader_file: loader_file} = context, paths, binding) do
    unless Context.pre_existing_loader?(context) do
      Mix.Generator.create_file(
        loader_file,
        Mix.Ash.eval_from(paths, "priv/templates/ash.gen.context/loader.ex", binding)
      )
    end
  end

  defp inject_policy(%Context{policy_file: policy_file} = context, paths, binding) do
    unless Context.pre_existing_policy?(context) do
      Mix.Generator.create_file(
        policy_file,
        Mix.Ash.eval_from(paths, "priv/templates/ash.gen.context/policy.ex", binding)
      )
    end
  end

  @doc false
  def print_shell_instructions(%Context{schema: schema}) do
    if schema.generate? do
      schema = struct(Mix.Phoenix.Schema, Map.from_struct(schema))
      Mix.Tasks.Phx.Gen.Schema.print_shell_instructions(schema)
    else
      :ok
    end
  end

  defp schema_access_template(%Context{schema: schema}) do
    if schema.generate? do
      "schema_access.ex"
    else
      "access_no_schema.ex"
    end
  end

  defp validate_args!([context, schema, _plural | _] = args) do
    cond do
      not Context.valid?(context) ->
        raise_with_help("Expected the context, #{inspect(context)}, to be a valid module name")

      not Schema.valid?(schema) ->
        raise_with_help("Expected the schema, #{inspect(schema)}, to be a valid module name")

      context == schema ->
        raise_with_help("The context and schema should have different names")

      context == Mix.Ash.base() ->
        raise_with_help("Cannot generate context #{context} because it has the same name as the application")

      schema == Mix.Ash.base() ->
        raise_with_help("Cannot generate schema #{schema} because it has the same name as the application")

      true ->
        args
    end
  end

  defp validate_args!(_) do
    raise_with_help("Invalid arguments")
  end

  @doc false
  @spec raise_with_help(String.t()) :: no_return()
  def raise_with_help(msg) do
    Mix.raise("""
    #{msg}

    mix ash.gen.context expect a context module name, followed by singular and
    plural names of the generated resource, ending with any number of attributes.
    For example:

        mix ash.gen.context Accounts User users name:string

    The context serves as the API boundary for the given resource.
    Multiple resources may belong to a context and a resource may be
    split over distinct contexts (such as Accounts.User and Payments.User).
    """)
  end

  def prompt_for_code_injection(%Context{} = context) do
    if Context.pre_existing?(context) do
      function_count = Context.function_count(context)
      file_count = Context.file_count(context)

      Mix.shell().info("""
      You are generating into an existing context.

      The #{inspect(context.module)} context currently has #{function_count} functions and \
      #{file_count} files in its directory.

        * It's OK to have multiple resources in the same context as \
      long as they are closely related. But if a context grows too \
      large, consider breaking it apart

        * If they are not closely related, another context probably works better

      The fact two entities are related in the database does not mean they belong \
      to the same context.

      If you are not sure, prefer creating a new context over adding to the existing one.
      """)

      unless Mix.shell().yes?("Would you like to proceed?") do
        System.halt()
      end
    end
  end
end
