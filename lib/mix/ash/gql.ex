defmodule Mix.Ash.Gql do
  @moduledoc false

  alias Mix.Ash.{Gql, Context, Schema}

  defstruct context: nil,
            schema: nil,
            schema_alias: nil,
            resolver_file: nil,
            resolver_test_file: nil,
            types_file: nil

  def new(%Context{} = context, %Schema{} = schema) do
    web_prefix = Mix.Ash.web_path(context.context_app)
    test_prefix = Mix.Ash.web_test_path(context.context_app)
    web_path = to_string(schema.web_path)

    schema_alias       = Module.concat([context.web_module, "Schema", schema.alias])
    resolver_file      = Path.join([web_prefix, "schema", web_path, schema.singular, "#{schema.singular}_resolver.ex"])
    resolver_test_file = Path.join([test_prefix, "schema", web_path, schema.singular, "#{schema.singular}_resolver_test.exs"])
    types_file         = Path.join([web_prefix, "schema", web_path, schema.singular, "#{schema.singular}_types.ex"])

    %Gql{
      context: context,
      schema: schema,
      schema_alias: schema_alias,
      resolver_file: resolver_file,
      resolver_test_file: resolver_test_file,
      types_file: types_file,
    }
  end
end
