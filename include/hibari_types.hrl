-ifndef(_hibari_types_included).
-define(_hibari_types_included, yeah).

-define(HIBARI_KEEPORREPLACE_KEEP, 1).
-define(HIBARI_KEEPORREPLACE_REPLACE, 2).

-define(HIBARI_DORESULTCODE_DELETIONOK, 10).
-define(HIBARI_DORESULTCODE_MUTATIONOK, 11).
-define(HIBARI_DORESULTCODE_GETOK, 12).
-define(HIBARI_DORESULTCODE_GETMANYOK, 13).
-define(HIBARI_DORESULTCODE_TSERROR, 21).
-define(HIBARI_DORESULTCODE_KEYEXISTSEXCEPTION, 22).
-define(HIBARI_DORESULTCODE_KEYNOTEXISTSEXCEPTION, 23).
-define(HIBARI_DORESULTCODE_INVALIDOPTIONPRESENTEXCEPTION, 24).

%% struct 'Property'

-record('Property', {'key' :: string() | binary(),
                     'value' :: string() | binary()}).
-type 'Property'() :: #'Property'{}.

%% struct 'AddOptions'

-record('AddOptions', {'exp_time' :: integer(),
                       'value_in_ram' :: boolean()}).
-type 'AddOptions'() :: #'AddOptions'{}.

%% struct 'UpdateOptions'

-record('UpdateOptions', {'exp_time' :: integer(),
                          'test_set' :: integer(),
                          'exp_time_directive' :: integer(),
                          'attrib_directive' :: integer(),
                          'value_in_ram' :: boolean()}).
-type 'UpdateOptions'() :: #'UpdateOptions'{}.

%% struct 'DeleteOptions'

-record('DeleteOptions', {'test_set' :: integer(),
                          'must_exist' :: boolean(),
                          'must_not_exist' :: boolean()}).
-type 'DeleteOptions'() :: #'DeleteOptions'{}.

%% struct 'GetOptions'

-record('GetOptions', {'test_set' :: integer(),
                       'is_witness' :: boolean(),
                       'get_all_attribs' :: boolean(),
                       'must_exist' :: boolean(),
                       'must_not_exist' :: boolean()}).
-type 'GetOptions'() :: #'GetOptions'{}.

%% struct 'GetManyOptions'

-record('GetManyOptions', {'is_witness' :: boolean(),
                           'get_all_attribs' :: boolean(),
                           'binary_prefix' :: string() | binary(),
                           'max_bytes' :: integer(),
                           'max_num' :: integer()}).
-type 'GetManyOptions'() :: #'GetManyOptions'{}.

%% struct 'DoOptions'

-record('DoOptions', {'fail_if_wrong_role' :: boolean(),
                      'ignore_role' :: boolean()}).
-type 'DoOptions'() :: #'DoOptions'{}.

%% struct 'DoTransaction'

-record('DoTransaction', {}).
-type 'DoTransaction'() :: #'DoTransaction'{}.

%% struct 'DoAdd'

-record('DoAdd', {'key' :: string() | binary(),
                  'value' :: string() | binary(),
                  'properties' :: list(),
                  'options' :: 'AddOptions'()}).
-type 'DoAdd'() :: #'DoAdd'{}.

%% struct 'DoReplace'

-record('DoReplace', {'key' :: string() | binary(),
                      'value' :: string() | binary(),
                      'properties' :: list(),
                      'options' :: 'UpdateOptions'()}).
-type 'DoReplace'() :: #'DoReplace'{}.

%% struct 'DoRename'

-record('DoRename', {'key' :: string() | binary(),
                     'new_key' :: string() | binary(),
                     'properties' :: list(),
                     'options' :: 'UpdateOptions'()}).
-type 'DoRename'() :: #'DoRename'{}.

%% struct 'DoSet'

-record('DoSet', {'key' :: string() | binary(),
                  'value' :: string() | binary(),
                  'properties' :: list(),
                  'options' = #'UpdateOptions'{} :: 'UpdateOptions'()}).
-type 'DoSet'() :: #'DoSet'{}.

%% struct 'DoDelete'

-record('DoDelete', {'key' :: string() | binary(),
                     'options' :: 'DeleteOptions'()}).
-type 'DoDelete'() :: #'DoDelete'{}.

%% struct 'DoGet'

-record('DoGet', {'key' :: string() | binary(),
                  'options' :: 'GetOptions'()}).
-type 'DoGet'() :: #'DoGet'{}.

%% struct 'DoGetMany'

-record('DoGetMany', {'key' :: string() | binary(),
                      'max_keys' :: integer(),
                      'options' :: 'GetManyOptions'()}).
-type 'DoGetMany'() :: #'DoGetMany'{}.

%% struct 'Op'

-record('Op', {'txn' :: 'DoTransaction'(),
               'add_kv' :: 'DoAdd'(),
               'replace_kv' :: 'DoReplace'(),
               'set_kv' :: 'DoSet'(),
               'rename_kv' :: 'DoRename'(),
               'delete_kv' :: 'DoDelete'(),
               'get_kv' :: 'DoGet'(),
               'get_many' :: 'DoGetMany'()}).
-type 'Op'() :: #'Op'{}.

%% struct 'GetResponse'

-record('GetResponse', {'timestamp' :: integer(),
                        'value' :: string() | binary(),
                        'exp_time' :: integer(),
                        'proplist' :: list()}).
-type 'GetResponse'() :: #'GetResponse'{}.

%% struct 'KeyValue'

-record('KeyValue', {'key' :: string() | binary(),
                     'timestamp' :: integer(),
                     'value' :: string() | binary(),
                     'exp_time' :: integer(),
                     'proplist' :: list()}).
-type 'KeyValue'() :: #'KeyValue'{}.

%% struct 'GetManyResponse'

-record('GetManyResponse', {'key_values' = [] :: list(),
                            'is_truncated' :: boolean()}).
-type 'GetManyResponse'() :: #'GetManyResponse'{}.

%% struct 'MutationResult'

-record('MutationResult', {'timestamp' :: integer()}).
-type 'MutationResult'() :: #'MutationResult'{}.

%% struct 'TSErrorResult'

-record('TSErrorResult', {'timestamp' :: integer()}).
-type 'TSErrorResult'() :: #'TSErrorResult'{}.

%% struct 'KeyExistsResult'

-record('KeyExistsResult', {'timestamp' :: integer()}).
-type 'KeyExistsResult'() :: #'KeyExistsResult'{}.

%% struct 'DoResult'

-record('DoResult', {'result_code' :: integer(),
                     'mutate_kv' :: 'MutationResult'(),
                     'get_kv' :: 'GetResponse'(),
                     'get_many' :: 'GetManyResponse'(),
                     'ts_error' :: 'TSErrorResult'(),
                     'key_exists' :: 'KeyExistsResult'()}).
-type 'DoResult'() :: #'DoResult'{}.

%% struct 'DoResponse'

-record('DoResponse', {'results' = [] :: list()}).
-type 'DoResponse'() :: #'DoResponse'{}.

%% struct 'TxnFailure'

-record('TxnFailure', {}).
-type 'TxnFailure'() :: #'TxnFailure'{}.

%% struct 'ServiceNotAvailableException'

-record('ServiceNotAvailableException', {}).
-type 'ServiceNotAvailableException'() :: #'ServiceNotAvailableException'{}.

%% struct 'TimedOutException'

-record('TimedOutException', {}).
-type 'TimedOutException'() :: #'TimedOutException'{}.

%% struct 'TableNotFoundException'

-record('TableNotFoundException', {}).
-type 'TableNotFoundException'() :: #'TableNotFoundException'{}.

%% struct 'TSErrorException'

-record('TSErrorException', {'timestamp' :: integer()}).
-type 'TSErrorException'() :: #'TSErrorException'{}.

%% struct 'KeyExistsException'

-record('KeyExistsException', {'timestamp' :: integer()}).
-type 'KeyExistsException'() :: #'KeyExistsException'{}.

%% struct 'KeyNotExistsException'

-record('KeyNotExistsException', {}).
-type 'KeyNotExistsException'() :: #'KeyNotExistsException'{}.

%% struct 'InvalidOptionPresentException'

-record('InvalidOptionPresentException', {}).
-type 'InvalidOptionPresentException'() :: #'InvalidOptionPresentException'{}.

%% struct 'TransactionFailureException'

-record('TransactionFailureException', {'do_op_index' :: integer(),
                                        'do_result' = #'DoResult'{} :: 'DoResult'()}).
-type 'TransactionFailureException'() :: #'TransactionFailureException'{}.

%% struct 'UnexpectedError'

-record('UnexpectedError', {'error' :: string() | binary()}).
-type 'UnexpectedError'() :: #'UnexpectedError'{}.

-endif.
