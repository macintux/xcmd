-module(xcmd_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, [DataDirPath, MemberList]) ->
    xcmd_sup:start_link(DataDirPath, MemberList, []);
start(_StartType, [DataDirPath, MemberList, Options]) ->
    xcmd_sup:start_link(DataDirPath, MemberList, Options).

stop(_State) ->
    ok.
