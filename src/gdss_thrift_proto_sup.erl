%%%----------------------------------------------------------------------
%%% Copyright (c) 2015 Hibari developers.  All rights reserved.
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%----------------------------------------------------------------------

-module(gdss_thrift_proto_sup).

-behaviour(supervisor).

%% External exports
-export([start_link/1]).

%% supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%----------------------------------------------------------------------
%%% API
%%%----------------------------------------------------------------------
start_link(_Args) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%----------------------------------------------------------------------
%%% Callback functions from supervisor
%%%----------------------------------------------------------------------

%%----------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%%----------------------------------------------------------------------
%% @spec(_Args::term()) -> {ok, {supervisor_flags(), child_spec_list()}}
%% @doc The main GDSS UBF supervisor.

init(_Args) ->
    %% Child_spec = [Name, {M, F, A},
    %%               Restart, Shutdown_time, Type, Modules_used]

    Thrift = case application:get_env(gdss_thrift_proto, thrift_tcp_port) of
                 {ok, 0} ->
                     [];
                 {ok, Port} ->
                     %% {ok, MaxConn}   = application:get_env(gdss_thrift_proto, thrift_maxconn),
                     %% {ok, IdleTimer} = application:get_env(gdss_thrift_proto, thrift_timeout),
                     %% {ok, POTerm}    = application:get_env(gdss_thrift_proto, thrift_process_options),
                     %% ProcessOptions  = gmt_util:proplists_int_copy([], POTerm, [fullsweep_after, min_heap_size]),

                     [{hibari_thrift_server,
                       {hibari_thrift_server, start_link, [gmt_util:node_localid_port(Port)]},
                       permanent, 2000, worker, [hibari_thrift_server]}]
            end,

    {ok, {{one_for_one, 2, 60}, Thrift}}.

%%%----------------------------------------------------------------------
%%% Internal functions
%%%----------------------------------------------------------------------
