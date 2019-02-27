use Mix.Config

config :divo,
  divo: [
    busybox: %{
      image: "busybox:latest",
      env: [
        val1: "foo",
        val2: "bar"
      ],
      ports: [
        {9092, 9092}
      ],
      command: "ls",
      wait_for: %{
        log: "home",
        dwell: 400
      }
    },
    alpine: %{
      image: "alpine:latest",
      env: [
        val1: "foo",
        val2: "bar"
      ],
      ports: [
        {9092, 9092}
      ],
      command: ~S{ls /home && echo "Yodel"}
    }
  ]
