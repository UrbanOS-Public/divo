use Mix.Config

config :divo,
  divo: %{
    version: "3.4",
    services: %{
      busybox: %{
        image: "busybox:latest",
        environment: [
          "VAL1=foo",
          "VAL2=bar"
        ],
        ports: ["8888:8888"],
        command: "sleep 1000",
        healthcheck: %{test: ["CMD-shell", "ls / | grep home || exit 1"]}
      },
      alpine: %{
        image: "alpine:latest",
        environment: [
          "VAL1=foo",
          "VAL2=bar"
        ],
        ports: ["5432:5432"],
        command: ~S{ls /home && echo "Yodel"}
      }
    }
  }
