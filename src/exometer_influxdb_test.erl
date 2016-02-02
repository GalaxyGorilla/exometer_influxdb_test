-module(exometer_influxdb_test).

-behaviour(application).

-export([start/2, stop/1, incr_each_sec/1]).

%%====================================================================
%% Application callbacks
%%====================================================================
start(_StartType, _StartArgs) ->
    Pid = start_counter(),
    {ok, self(), Pid}.

stop(Pid) ->
    Pid ! stop.

%%====================================================================
%% Internal functions
%%====================================================================
start_counter() ->
    %% STEP 1: define a Metric
    MetricId = [my_counter],    %% the exometer ID of the metric, a list of atoms
    MetricType = counter,       %% which kind of metric?
    MetricOptions = [],         %% possible options?
    ok = exometer:new(MetricId, MetricType, MetricOptions),
    %% the counter is set to 0 by default.

    %% STEP 2: subscribe the metric reporter to the metric such that metrics are
    %% sent to some aggregator, e.g. InfluxDB.
    Reporters = exometer_report:list_reporters(),
    [subscribe_to_counter(Reporter, MetricId) || {Reporter, _Pid} <- Reporters],

    %% start incrementing the counter
    send_random_reset(),
    spawn(?MODULE, incr_each_sec, [MetricId]).


subscribe_to_counter(Reporter, MetricId) ->
    ReportInterval = 1000,                              %% reporting interval in ms 
    Datapoints = [value, ms_since_reset],               %% datapoints we are subscribing to
    ReportOptions = [],                                 %% possible options?
    ok = exometer_report:subscribe(Reporter, MetricId, Datapoints, ReportInterval, ReportOptions).


%% increment the counter each second and randomly reset counter to 0
incr_each_sec(MetricId) ->
    receive
        stop -> 
            ok;
        reset ->
            send_random_reset(),
            io:format("Resetting counter ...~n", []),
            exometer:reset(MetricId),
            incr_each_sec(MetricId)
    after 
        1000 -> 
            {ok, Value} = exometer:get_value(MetricId),
            io:format("Counter Status: ~p~n", [Value]),
            exometer:update(MetricId, 1),
            incr_each_sec(MetricId)
    end.
    
send_random_reset() ->
    NextReset = random:uniform(60000),
    spawn(erlang, send_after, [NextReset, self(), reset]).
