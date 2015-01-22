-module(xcmd_sup).

-behaviour(supervisor).

%% API
-export([start_link/3]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type, Args), {I, {I, start_link, Args}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

-spec start_link(string(), [node()], [{atom(), term()}]) -> {ok, pid()}.
start_link(DataDirPath, MemberList, Options) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [DataDirPath, MemberList, Options]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([DataDirPath, MemberList, Options]) ->
    DataDirArg = {data_dir, DataDirPath},
    ManagerArgs = case lists:keyfind(storage_namespace, 1, Options) of
                      false ->
                          [[DataDirArg]];
                      {storage_namespace, _} = Val ->
                          [[DataDirArg, Val]]
                  end,

    HashtreeArgs = [DataDirPath],

    Mods = case lists:keyfind(broadcast_mods, 1, Options) of
               false ->
                   [xcmd_manager];
               {broadcast_mods, M} ->
                   M
           end,
    BroadcastArgs = [MemberList, Mods],

    ChildSpecs = [
                  ?CHILD(xcmd_manager, worker, ManagerArgs),
                  ?CHILD(xcmd_hashtree, worker, HashtreeArgs),
                  ?CHILD(xcmd_broadcast, worker, BroadcastArgs)
                 ],
    {ok, {{one_for_one, 5, 10}, ChildSpecs}}.

