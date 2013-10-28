-module(config_to_json).

-export([main/1]).

main([]) ->
    usage();

main(Args) ->
    case getopt:parse(option_spec_list(), Args) of
        {ok, {Options, _}} ->
            ConfigFile = proplists:get_value(config_file, Options),
						case file:consult(ConfigFile) of
						    {ok, [Terms]} ->
										% riak app.config format
								 		Config = eth:convert(Terms);
							  {ok, Terms} ->
								    % basho_bench .config format
								 		Config = eth:convert([Terms])
						end,
            Json = jsx:encode(Config),
            Output = case proplists:get_value(prettify, Options) of
                true -> jsx:prettify(Json);
                _ -> Json
            end,
            io:format("~s", [Output]);
        {error, {Reason, Data}} ->
            io:format("Error: ~s ~p~n~n", [Reason, Data]),
            usage()
    end.

usage() ->
    getopt:usage(option_spec_list(), filename:basename(escript:script_name())),                    
    halt(1).

option_spec_list() ->
    [
        {prettify, $p, "prettify", boolean, "Prettify JSON output"},
        {config_file, undefined, undefined, string, "Config file to parse"}
    ].
