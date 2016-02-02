exometer_influxdb_test
=====

A small tool to get started with metrics and InfluxDB in Erlang.

Requirements
-----------

- [rebar3](https://github.com/rebar/rebar3)
- [InfluxDB](https://influxdata.com/downloads/)
- [Grafana](http://grafana.org/download/) (optional)

Build
-----

    $ rebar3 compile

Quick Start
-----------
    
Install and start InfluxDB on your local machine (alter priv/app.config
accordingly) and then execute

    $ erl -pa _build/default/lib/*/ebin \
          -config priv/app.config \
          -eval "application:ensure_all_started(exometer_influxdb_test)"

A metric called "my_counter" should appear in your InfluxDB database. This
counter in incremented every second and resetted randomly within 60 seconds. The
counter can be visualized with e.g. Grafana. 
