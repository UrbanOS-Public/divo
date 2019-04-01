defmodule Divo.StackTest do
  use ExUnit.Case
  require TemporaryEnv

  test "behaviour returns the service definition of a single stack" do
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

  test "behaviour returns the service definition of a stack with no parameters" do
    services = [
      DivoBarbaz
    ]

    expected = %{
      version: "3.4",
      services: %{
        barbaz: %{
          image: "library/barbaz",
          ports: ["2345:2345", "7777:7777"],
          healthcheck: %{
            test: ["CMD-SHELL", "/bin/true || exit 1"]
          }
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

defmodule DivoBarbaz do
  @behaviour Divo.Stack

  @impl Divo.Stack
  def gen_stack(_envars) do
    %{
      barbaz: %{
        image: "library/barbaz",
        healthcheck: %{
          test: ["CMD-SHELL", "/bin/true || exit 1"]
        },
        ports: ["2345:2345", "7777:7777"]
      }
    }
  end
end
