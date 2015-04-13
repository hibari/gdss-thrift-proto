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

-module(hibari_thrift_server).

%% Thrift server callbacks
-export([start_link/1,
         handle_function/2
        ]).

-export([add_kv/5,
         replace_kv/5,
         rename_kv/5,
         set_kv/5,
         get_kv/3,
         get_many/4,
         delete_kv/3,
         do_ops/3
        ]).

-include("hibari_thrift.hrl").

%%--------------------------------------------------------------------
%% defines, types, records
%%--------------------------------------------------------------------

-define(KEEP,    ?HIBARI_KEEPORREPLACE_KEEP).
-define(REPLACE, ?HIBARI_KEEPORREPLACE_REPLACE).

-define(TIMEOUT, 15000).

%%--------------------------------------------------------------------
%% API
%%--------------------------------------------------------------------

%% -spec
start_link(Port) ->
    thrift_server:start_link(Port, hibari_thrift, ?MODULE).

%% -spec
handle_function(Function, Args) ->
    case apply(?MODULE, Function, tuple_to_list(Args)) of
        ok ->
            ok;
        Else ->
            {reply, Else}
    end.

%%--------------------------------------------------------------------
%% Internal functions - Single op handlers
%%--------------------------------------------------------------------

-spec add_kv(binary(), binary(), binary(), ['Property'()], 'AddOptions'()) -> integer() | term().
add_kv(Table, Key, Value, PropList, #'AddOptions'{}=Opts) ->
    case table(Table) of
        undefined ->
            error;
        TableAtom ->
            Properties = properties(PropList),
            {ExpTime, WriteOptions} = parse_add_options(Opts),
            case catch brick_simple:add(TableAtom, Key, Value, ExpTime,
                                        Properties ++ WriteOptions, ?TIMEOUT) of
                {ok, TS} ->
                    TS;
                {key_exists, TS} ->
                    throw(#'KeyExistsException'{key=Key, timestamp=TS});
                {txn_fail, [{_Integer, brick_not_available}]} ->
                    brick_not_available;
                {'EXIT', {timeout, _}} ->
                    throw(#'TimedOutException'{});
                Unknown ->
                    Error = lists:flatten(io_lib:format("~p", [Unknown])),
                    throw(#'UnexpectedError'{error=Error})
            end
    end.

-spec replace_kv(binary(), binary(), binary(), ['Property'()], 'UpdateOptions'()) -> integer() | term().
replace_kv(Table, Key, Value, PropList, #'UpdateOptions'{}=Opts) ->
    case table(Table) of
        undefined ->
            error;
        TableAtom ->
            Properties = properties(PropList),
            {ExpTime, WriteOptions} = parse_update_options(Opts),
            case catch brick_simple:replace(TableAtom, Key, Value, ExpTime,
                                            Properties ++ WriteOptions, ?TIMEOUT) of
                {ok, TS} ->
                    TS;
                key_not_exists ->
                    throw(#'KeyNotExistsException'{key=Key});
                {ts_error, TS} ->
                    throw(#'TSErrorException'{key=Key, timestamp=TS});
                {txn_fail, [{_Integer, brick_not_available}]} ->
                    brick_not_available;
                {'EXIT', {timeout, _}} ->
                    throw(#'TimedOutException'{});
                Unknown ->
                    Error = lists:flatten(io_lib:format("~p", [Unknown])),
                    throw(#'UnexpectedError'{error=Error})
            end
    end.

-spec rename_kv(binary(), binary(), binary(), ['Property'()], 'UpdateOptions'()) -> integer() | term().
rename_kv(Table, Key, NewKey, PropList, #'UpdateOptions'{}=Opts) ->
    case table(Table) of
        undefined ->
            error;
        TableAtom ->
            Properties = properties(PropList),
            {ExpTime, WriteOptions} = parse_update_options(Opts),
            case catch brick_simple:rename(TableAtom, Key, NewKey, ExpTime,
                                           Properties ++ WriteOptions, ?TIMEOUT) of
                {ok, TS} ->
                    TS;
                {ts_error, TS} ->
                    {ts_error, TS};
                {txn_fail, [{_Integer, brick_not_available}]} ->
                    brick_not_available;
                {'EXIT', {timeout, _}} ->
                    throw(#'TimedOutException'{});
                Unknown ->
                    Error = lists:flatten(io_lib:format("~p", [Unknown])),
                    throw(#'UnexpectedError'{error=Error})
            end
    end.

-spec set_kv(binary(), binary(), binary(), ['Property'()], 'UpdateOptions'()) -> integer() | term().
set_kv(Table, Key, Value, PropList, #'UpdateOptions'{}=Opts) ->
    case table(Table) of
        undefined ->
            error;
        TableAtom ->
            Properties = properties(PropList),
            {ExpTime, WriteOptions} = parse_update_options(Opts),
            case catch brick_simple:set(TableAtom, Key, Value, ExpTime,
                                        Properties ++ WriteOptions, ?TIMEOUT) of
                {ok, TS} ->
                    TS;
                {ts_error, TS} ->
                    throw(#'TSErrorException'{key=Key, timestamp=TS});
                {txn_fail, [{_Integer, brick_not_available}]} ->
                    brick_not_available;
                {'EXIT', {timeout, _}} ->
                    throw(#'TimedOutException'{});
                Unknown ->
                    Error = lists:flatten(io_lib:format("~p", [Unknown])),
                    throw(#'UnexpectedError'{error=Error})
            end
    end.

-spec delete_kv(binary(), binary(), 'DeleteOptions'()) -> term().
delete_kv(Table, Key, #'DeleteOptions'{}=Opts) ->
    case table(Table) of
        undefined ->
            error;
        TableAtom ->
            DeleteOptions = parse_delete_options(Opts),
            case catch brick_simple:delete(TableAtom, Key, DeleteOptions, ?TIMEOUT) of
                ok ->
                    {ok, ok};
                key_not_exist ->
                    throw(#'KeyNotExistsException'{key=Key});
                {ts_error, TS} ->
                    throw(#'TSErrorException'{key=Key, timestamp=TS});
                {txn_fail, [{_Integer, brick_not_available}]} ->
                    brick_not_available;
                {'EXIT', {timeout, _}} ->
                    throw(#'TimedOutException'{});
                Unknown ->
                    Error = lists:flatten(io_lib:format("~p", [Unknown])),
                    throw(#'UnexpectedError'{error=Error})
            end
    end.

-spec get_kv(binary(), binary(), 'GetOptions'()) -> term().
get_kv(Table, Key, #'GetOptions'{}=Opts) ->
    case table(Table) of
        undefined ->
            error;
        TableAtom ->
            ReadOptions = parse_get_options(Opts),
            case catch brick_simple:get(TableAtom, Key, ReadOptions, ?TIMEOUT) of
                {ok, TS, Val} ->
                    #'GetResponse'{timestamp=TS, value=Val};
                {ok, TS} ->
                    #'GetResponse'{timestamp=TS};
                {ok, TS, ExpTime, Properties} ->
                    #'GetResponse'{timestamp=TS, exp_time=ExpTime,
                                   proplist=to_prop_list(Properties)};
                {ok, TS, Val, ExpTime, Properties} ->
                    #'GetResponse'{timestamp=TS, value=Val, exp_time=ExpTime,
                                   proplist=to_prop_list(Properties)};
                key_not_exist ->
                    throw(#'KeyNotExistsException'{key=Key});
                {ts_error, TS} ->
                    throw(#'TSErrorException'{key=Key, timestamp=TS});
                {txn_fail, [{_Integer, brick_not_available}]} ->
                    brick_not_available;
                {'EXIT', {timeout, _}} ->
                    throw(#'TimedOutException'{});
                Unknown ->
                    Error = lists:flatten(io_lib:format("~p", [Unknown])),
                    throw(#'UnexpectedError'{error=Error})
            end
    end.

-spec get_many(binary(), binary(), non_neg_integer(), 'GetManyOptions'()) -> term().
get_many(Table, Key, MaxKeys, #'GetManyOptions'{}=Opts) ->
    case table(Table) of
        undefined ->
            error;
        TableAtom ->
            ReadOptions = parse_get_many_options(Opts),
            case catch brick_simple:get_many(TableAtom, Key, MaxKeys, ReadOptions, ?TIMEOUT) of
                ok ->
                    {ok, ok};
                invalid_flag_present ->
                    throw(#'InvalidOptionPresentException'{});
                {txn_fail, [{_Integer, brick_not_available}]} ->
                    brick_not_available;
                {'EXIT', {timeout, _}} ->
                    throw(#'TimedOutException'{});
                Unknown ->
                    Error = lists:flatten(io_lib:format("~p", [Unknown])),
                    throw(#'UnexpectedError'{error=Error})
            end
    end.

%%--------------------------------------------------------------------
%% Internal functions - Do op list handlers
%%--------------------------------------------------------------------

-spec do_ops(binary(), ['Op'()], 'DoOptions'()) -> ok.
do_ops(Table, DoOpList, #'DoOptions'{}=Opts) ->
    case table(Table) of
        undefined ->
            error;
        TableAtom ->
            DoOpList1 = lists:map(fun do_op/1, DoOpList),
            DoOptions = parse_do_options(Opts),
            case catch brick_simple:do(TableAtom, DoOpList1, DoOptions, ?TIMEOUT) of
                DoRes when is_list(DoRes) ->
                    io:format("DoRes: ~p~n", [DoRes]),
                    %% DoRes;
                    undefined;
                {txn_fail, [{_Integer, brick_not_available}]} ->
                    brick_not_available;
                {txn_fail, [{Index, {key_exists, _TS}}]} ->
                    throw(#'TransactionFailureException'{do_op_index=Index,
                                                         failure= <<"KeyExists">>});
                {'EXIT', {timeout, _}} ->
                    throw(#'TimedOutException'{});
                Unknown ->
                    Error = lists:flatten(io_lib:format("~p", [Unknown])),
                    throw(#'UnexpectedError'{error=Error})
            end
    end.

-spec do_op('Op'()) -> term().
do_op(#'Op'{txn=#'DoTransaction'{},
          add_kv=undefined, replace_kv=undefined, set_kv=undefined, rename_kv=undefined,
          get_kv=undefined, get_many=undefined, delete_kv=undefined}) ->
    brick_server:make_txn();
do_op(#'Op'{add_kv=#'DoAdd'{key=Key, value=Value, properties=PropList, options=Opts},
          txn=undefined, replace_kv=undefined, set_kv=undefined, rename_kv=undefined,
          get_kv=undefined, get_many=undefined, delete_kv=undefined}) ->
    Properties = properties(PropList),
    {ExpTime, WriteOptions} = parse_add_options(Opts),
    brick_server:make_add(Key, Value, ExpTime, Properties ++ WriteOptions);
do_op(#'Op'{replace_kv=#'DoReplace'{key=Key, value=Value, properties=PropList, options=Opts},
          txn=undefined, add_kv=undefined, set_kv=undefined, rename_kv=undefined,
          get_kv=undefined, get_many=undefined, delete_kv=undefined}) ->
    Properties = properties(PropList),
    {ExpTime, WriteOptions} = parse_update_options(Opts),
    brick_server:make_replace(Key, Value, ExpTime, Properties ++ WriteOptions);
do_op(#'Op'{rename_kv=#'DoRename'{key=Key, new_key=NewKey, properties=PropList, options=Opts},
          txn=undefined, add_kv=undefined, replace_kv=undefined, set_kv=undefined,
          get_kv=undefined, get_many=undefined, delete_kv=undefined}) ->
    Properties = properties(PropList),
    {ExpTime, WriteOptions} = parse_update_options(Opts),
    brick_server:make_rename(Key, NewKey, ExpTime, Properties ++ WriteOptions);
do_op(#'Op'{set_kv=#'DoSet'{key=Key, value=Value, properties=PropList, options=Opts},
          txn=undefined, add_kv=undefined, replace_kv=undefined, rename_kv=undefined,
          get_kv=undefined, get_many=undefined, delete_kv=undefined}) ->
    Properties = properties(PropList),
    {ExpTime, WriteOptions} = parse_update_options(Opts),
    brick_server:make_set(Key, Value, ExpTime, Properties ++ WriteOptions);
do_op(#'Op'{delete_kv=#'DoDelete'{key=Key, options=Opts},
          txn=undefined, add_kv=undefined, replace_kv=undefined, set_kv=undefined,
          rename_kv=undefined, get_kv=undefined, get_many=undefined}) ->
    DeleteOptions = parse_delete_options(Opts),
    brick_server:make_delete(Key, DeleteOptions);
do_op(#'Op'{get_kv=#'DoGet'{key=Key, options=Opts},
          txn=undefined, add_kv=undefined, replace_kv=undefined, set_kv=undefined,
          rename_kv=undefined, get_many=undefined, delete_kv=undefined}) ->
    GetOptions = parse_get_options(Opts),
    brick_server:make_get(Key, GetOptions);
do_op(#'Op'{get_many=#'DoGetMany'{key=Key, max_keys=MaxKeys, options=Opts},
          txn=undefined, add_kv=undefined, replace_kv=undefined, set_kv=undefined,
          rename_kv=undefined, get_kv=undefined, delete_kv=undefined}) ->
    GetManyOptions = parse_get_many_options(Opts),
    brick_server:make_get_many(Key, MaxKeys, GetManyOptions).

%%--------------------------------------------------------------------
%% Internal functions - Common utilities
%%--------------------------------------------------------------------

%% @TODO
-type add_option()      :: term().
-type delete_option()   :: term().
-type do_option()       :: term().
-type get_many_option() :: term().
-type get_option()      :: term().
-type update_option()   :: term().
-type exp_time()        :: integer().

-spec table(binary()) -> atom() | 'undefined'.
table(Table) ->
    try
        list_to_existing_atom(binary_to_list(Table)) of
        Atom ->
            Atom
    catch
        _:_ ->
            undefined
    end.

-spec parse_add_options(#'AddOptions'{}) -> {exp_time(), [add_option()]}.
parse_add_options(#'AddOptions'{exp_time=ExpTime, value_in_ram=ValueInRam}) ->
    Opts = [ value_in_ram || ValueInRam ],
    {exp_time(ExpTime), Opts}.

-spec parse_update_options(#'UpdateOptions'{}) -> {exp_time(), [update_option()]}.
parse_update_options(#'UpdateOptions'{exp_time=ExpTime,
                                      test_set=TestSet,
                                      exp_time_directive=ExpTimeDirect,
                                      attrib_directive=AttrbDirect,
                                      value_in_ram=ValueInRam}) ->
    Opts = [ {test_set, TestSet} || TestSet =/= undefined ]
        ++ [ {exp_time_directive, keep_or_replace(ExpTimeDirect)} || ExpTimeDirect =/= undefined ]
        ++ [ {attrb_directive,    keep_or_replace(AttrbDirect)}   || AttrbDirect =/= undefined ]
        ++ [ value_in_ram || ValueInRam ],
    {exp_time(ExpTime), Opts}.

-spec parse_delete_options('DeleteOptions'()) -> [delete_option()].
parse_delete_options(#'DeleteOptions'{test_set=TestSet,
                                      must_exist=MustExist,
                                      must_not_exist=MustNotExist}) ->
    [ {test_set, TestSet} || TestSet =/= undefined ]
        ++ [ must_exist || MustExist ]
        ++ [ must_not_exist || MustNotExist ].

-spec parse_get_options('GetOptions'()) -> [get_option()].
parse_get_options(#'GetOptions'{test_set=TestSet,
                                is_witness=IsWitness,
                                get_all_attribs=GetAllAttribs,
                                must_exist=MustExist,
                                must_not_exist=MustNotExist}) ->
    [ {test_set, TestSet} || TestSet =/= undefined ]
        ++ [ is_witness || IsWitness ]
        ++ [ get_all_attribs || GetAllAttribs ]
        ++ [ must_exist || MustExist ]
        ++ [ must_not_exist || MustNotExist ].

-spec parse_get_many_options('GetManyOptions'()) -> [get_many_option()].
parse_get_many_options(#'GetManyOptions'{is_witness=IsWitness,
                                         get_all_attribs=GetAllAttribs,
                                         max_bytes=MaxBytes,
                                         max_num=MaxNum}) ->
    [ is_witness || IsWitness ]
        ++ [ get_all_attribs || GetAllAttribs ]
        ++ [ {max_bytes, MaxBytes} || MaxBytes =/= undefined ]
        ++ [ {max_num, MaxNum} || MaxNum =/= undefined ].

-spec parse_do_options('DoOptions'()) -> [do_option()].
parse_do_options(#'DoOptions'{fail_if_wrong_role=FailIfWrongRole,
                              ignore_role=IgnoreRole}) ->
    [ fail_if_wrong_role || FailIfWrongRole ]
        ++ [ ignore_role || IgnoreRole ].

-spec exp_time('undefined' | non_neg_integer()) -> non_neg_integer().
exp_time(undefined) ->
    0;
exp_time(Int) ->
    Int.

-spec keep_or_replace(?KEEP..?REPLACE) -> 'keep' | 'replace'.
keep_or_replace(?KEEP) ->
    keep;
keep_or_replace(?REPLACE) ->
    replace.

-spec properties('undefined' | ['Property'()]) -> [{binary(), binary()}].
properties(undefined) ->
    [];
properties(PropList) ->
    [ {to_binary(K), to_binary(V)} || #'Property'{key=K, value=V} <- PropList ].

-spec to_prop_list([atom() | {atom() | binary(), atom() | binary() | integer()}]) -> ['Property'()].
to_prop_list(Attribs) ->
    lists:map(fun(Atom) when is_atom(Atom) ->
                      #'Property'{key=to_binary(Atom)};
                 ({K, V}) ->
                      #'Property'{key=to_binary(K), value=to_binary(V)}
              end, Attribs).

-spec to_binary(string() | binary() | integer() | atom()) -> binary().
to_binary(Bin) when is_binary(Bin) ->
    Bin;
to_binary(Str) when is_list(Str) ->
    list_to_binary(Str);
to_binary(Int) when is_integer(Int) ->
    list_to_binary(integer_to_list(Int));
to_binary(Atom) when is_atom(Atom) ->
    list_to_binary(atom_to_list(Atom)).
