import Config

config :divo,
  divo: %{
    version: "3.4",
    services: %{
      redis: %{
        image: "redis:5.0.3",
        command: ["redis", "start", "--foreground"],
        ports: ["2181:2181"],
        volumes: ["/tmp:/opt/redis"]
      },
      kafka: %{
        image: "wurstmeister/kafka",
        depends_on: ["zookeeper"],
        ports: ["9094:9094"],
        environment: [
          "VAL1=foo",
          "VAL2=bar"
        ]
      }
    }
  }
