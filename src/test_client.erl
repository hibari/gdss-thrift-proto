%%----------------------------------------------------------------------
%% Copyright (c) 2015 Hibari developers.  All rights reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%----------------------------------------------------------------------

-module(test_client).

-compile(export_all).

-include("hibari_thrift.hrl").

-define(KEEP,    ?HIBARI_KEEPORREPLACE_KEEP).
-define(REPLACE, ?HIBARI_KEEPORREPLACE_REPLACE).

%% 1> {ok, C0} = thrift_client_util:new("localhost", 9090, thrift_test_thrift, []), ok.
%% ok
%% 2> {C1, R1} = thrift_client:call(C0, testVoid, []), R1.
%% {ok,ok}
%% 3> {C2, R2} = thrift_client:call(C1, testVoid, [asdf]), R2.
%% {error,{bad_args,testVoid,[asdf]}}
%% 4> {C3, R3} = thrift_client:call(C2, testI32, [123]), R3.
%% {ok,123}
%% 5> {C4, R4} = thrift_client:call(C3, testOneway, [1]), R4.
%% {ok,ok}
%% 6> {C5, R5} = thrift_client:call(C4, testXception, ["foo"]), R5.
%% {error,{no_function,testXception}}
%% 7> {C6, R6} = thrift_client:call(C5, testException, ["foo"]), R6.
%% {ok,ok}
%% 8> {C7, R7} = (catch thrift_client:call(C6, testException, ["Xception"])), R7.
%% {exception,{xception,1001,<<"Xception">>}}

t1() ->
    t1(7601).

t1(Port) ->
    {ok, C0} = thrift_client_util:new("localhost", Port, hibari_thrift, []),
    PropList = [],
    WriteOptions0 = #'AddOptions'{exp_time=1234567890, value_in_ram=true},
    {C1, R1} = thrift_client:call(C0, add_kv, ["tab1", <<"key1">>, <<"val1">>,
                                               PropList, WriteOptions0]),
    io:format("R1: ~p~n", [R1]),

    Txn  = #'Op'{txn=#'DoTransaction'{}},
    Add1 = #'Op'{replace_kv=#'DoReplace'{key= <<"key1">>, value= <<"val1">>,
                                         properties=[#'Property'{key= <<"color">>, value= <<"blue">>}],
                                         options=#'UpdateOptions'{exp_time_directive=?KEEP}
                                    }},
    Add2 = #'Op'{add_kv=#'DoAdd'{key= <<"key2">>, value= <<"val2">>}},
    {_C2, R2} = thrift_client:call(C1, do_ops, ["tab1", [Txn, Add1, Add2], #'DoOptions'{}]),
    io:format("R2: ~p~n", [R2]),
    ok.
