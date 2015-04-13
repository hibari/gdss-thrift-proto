-ifndef(_hibari_types_included).
-define(_hibari_types_included, yeah).

-define(HIBARI_KEEPORREPLACE_KEEP, 1).
-define(HIBARI_KEEPORREPLACE_REPLACE, 2).

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

%% struct 'DoTransaction'

-record('DoTransaction', {}).
-type 'DoTransaction'() :: #'DoTransaction'{}.

%% struct 'DoAdd'

-record('DoAdd', {'key' :: string() | binary(),
                  'value' :: string() | binary(),
                  'properties' :: list(),
                  'options' = #'AddOptions'{} :: 'AddOptions'()}).
-type 'DoAdd'() :: #'DoAdd'{}.

%% struct 'DoReplace'

-record('DoReplace', {'key' :: string() | binary(),
                      'value' :: string() | binary(),
                      'properties' :: list(),
                      'options' = #'UpdateOptions'{} :: 'UpdateOptions'()}).
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

%% struct 'DoOptions'

-record('DoOptions', {'fail_if_wrong_role' :: boolean(),
                      'ignore_role' :: boolean()}).
-type 'DoOptions'() :: #'DoOptions'{}.

%% struct 'GetResponse'

-record('GetResponse', {'timestamp' :: integer(),
                        'value' :: string() | binary(),
                        'exp_time' :: integer(),
                        'proplist' :: list()}).
-type 'GetResponse'() :: #'GetResponse'{}.

%% struct 'GetManyResponse'

-record('GetManyResponse', {'records' = [] :: list(),
                            'is_truncated' :: boolean()}).
-type 'GetManyResponse'() :: #'GetManyResponse'{}.

%% struct 'DoResult'

-record('DoResult', {'is_success' :: boolean(),
                     'timestamp' :: integer(),
                     'get_res' :: 'GetResponse'(),
                     'get_many_res' :: 'GetManyResponse'()}).
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

%% struct 'NotImplementedException'

-record('NotImplementedException', {}).
-type 'NotImplementedException'() :: #'NotImplementedException'{}.

%% struct 'TimedOutException'

-record('TimedOutException', {}).
-type 'TimedOutException'() :: #'TimedOutException'{}.

%% struct 'TSErrorException'

-record('TSErrorException', {'key' :: string() | binary(),
                             'timestamp' :: integer()}).
-type 'TSErrorException'() :: #'TSErrorException'{}.

%% struct 'KeyExistsException'

-record('KeyExistsException', {'key' :: string() | binary(),
                               'timestamp' :: integer()}).
-type 'KeyExistsException'() :: #'KeyExistsException'{}.

%% struct 'KeyNotExistsException'

-record('KeyNotExistsException', {'key' :: string() | binary()}).
-type 'KeyNotExistsException'() :: #'KeyNotExistsException'{}.

%% struct 'InvalidOptionPresentException'

-record('InvalidOptionPresentException', {}).
-type 'InvalidOptionPresentException'() :: #'InvalidOptionPresentException'{}.

%% struct 'TransactionFailureException'

-record('TransactionFailureException', {'do_op_index' :: integer(),
                                        'failure' = #'TxnFailure'{} :: 'TxnFailure'()}).
-type 'TransactionFailureException'() :: #'TransactionFailureException'{}.

%% struct 'UnexpectedError'

-record('UnexpectedError', {'error' :: string() | binary()}).
-type 'UnexpectedError'() :: #'UnexpectedError'{}.

-endif.
