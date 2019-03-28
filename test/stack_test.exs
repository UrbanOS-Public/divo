defmodule Divo.StackTest do
  use ExUnit.Case
  require TemporaryEnv

  test "behaviour returns the service definition" do
    services = [
      {DivoFoobar, [db_password: "we-are-divo", db_name: "foobar-db", something: "else"]}
    ]

    expected = %{
      version: "3.4",
      services: %{
        foobar: %{
          image: "foobar:latest",
          ports: ["8080:8080"],
          command: ["/bin/server", "foreground"]
        },
        db: %{
          image: "cooldb:5.0.9",
          environment: [
            "PASSWORD=we-are-divo",
            "DB=foobar-db"
          ]
        }
      }
    }

    actual = Divo.Stack.concat_compose(services)

    assert expected == actual
  end
end

defmodule DivoFoobar do
  @behaviour Divo.Stack

  @impl Divo.Stack
  def gen_stack(envars) do
    password = envars[:db_password]
    db_name = envars[:db_name]

    %{
      foobar: %{
        image: "foobar:latest",
        ports: ["8080:8080"],
        command: ["/bin/server", "foreground"]
      },
      db: %{
        image: "cooldb:5.0.9",
        environment: [
          "PASSWORD=#{password}",
          "DB=#{db_name}"
        ]
      }
    }
  end
end
