#!/usr/local/bin/thrift --gen erl --gen go --gen hs --gen java --gen js:node --gen php --gen py --gen rb
#----------------------------------------------------------------------
# Copyright (c) 2008-2017 Hibari developers.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#----------------------------------------------------------------------

namespace java org.hibaridb.hibari.thrift
namespace cpp org.hibaridb.hibari
namespace csharp HibariDB.Hibari
namespace py hibari
namespace php hibari
namespace perl Hibari

# Thrift.rb has a bug where top-level modules that include modules
# with the same name are not properly referenced, so we can't do
# Hibari::Hibari::Client.
namespace rb HibariThrift


typedef i64 ExpTime
typedef i64 Timestamp

/* ************************* *
 * Options
 * ************************* */

struct Property {
  1: required string key,
  2: optional string value,
}

enum KeepOrReplace {
  Keep    = 1,
  Replace = 2,
}

struct AddOptions {
  1: optional ExpTime       exp_time,
  2: optional bool          value_in_ram,
}

struct UpdateOptions {
  1: optional ExpTime       exp_time,
  2: optional Timestamp     test_set,
  3: optional KeepOrReplace exp_time_directive,
  4: optional KeepOrReplace attrib_directive,
  5: optional bool          value_in_ram,
}

struct DeleteOptions {
  1: optional Timestamp     test_set,
  2: optional bool          must_exist,
  3: optional bool          must_not_exist,
}

struct GetOptions {
  1: optional Timestamp     test_set,
  2: optional bool          is_witness,
  3: optional bool          get_all_attribs,
  4: optional bool          must_exist,
  5: optional bool          must_not_exist,
}

struct GetManyOptions {
  1: optional bool          is_witness,
  2: optional bool          get_all_attribs,
  3: optional binary        binary_prefix,
  4: optional i64           max_bytes,
  5: optional i32           max_num,
}

struct DoOptions {
  1: optional bool fail_if_wrong_role,
  2: optional bool ignore_role,
}


/* ************************* *
 * Do Operations
 * ************************* */

struct DoTransaction { }

struct DoAdd {
  1: required binary key,
  2: required binary value,
  3: optional list<Property> properties,   // @TODO Change to map<binary, binary> ?
  4: optional AddOptions     options,
}

struct DoReplace {
  1: required binary key,
  2: required binary value,
  3: optional list<Property> properties,
  4: optional UpdateOptions  options,
}

struct DoRename {
  1: required binary key,
  2: required binary new_key,
  3: optional list<Property> properties,
  4: optional UpdateOptions  options,
}

struct DoSet {
  1: required binary key,
  2: required binary value,
  3: optional list<Property> properties,
  4: required UpdateOptions  options,
}

struct DoDelete {
  1: required binary key,
  2: optional DeleteOptions options,
}

struct DoGet {
  1: required binary key,
  2: optional GetOptions options,
}

struct DoGetMany {
  1: required binary key,
  2: required i32    max_keys,
  3: optional GetManyOptions options,
}

union Op {
    1: optional DoTransaction txn,
    2: optional DoAdd         add_kv,
    3: optional DoReplace     replace_kv,
    4: optional DoSet         set_kv,
//  5: optional DoCopy        copy_kv,     // Reserved for Hibari v0.3
    6: optional DoRename      rename_kv,
    7: optional DoDelete      delete_kv,
    8: optional DoGet         get_kv,
    9: optional DoGetMany     get_many,
}


/* ************************* *
 * Responses
 * ************************* */

struct GetResponse {
  1: required Timestamp      timestamp,
  2: optional binary         value,
  3: optional ExpTime        exp_time,
  4: optional list<Property> proplist,
}

struct KeyValue {
  1: required binary         key,
  2: required Timestamp      timestamp,
  3: optional binary         value,
  4: optional ExpTime        exp_time,
  5: optional list<Property> proplist,
}

struct GetManyResponse {
  1: required list<KeyValue> key_values,
  2: required bool is_truncated,
}


/* ************************* *
 * Do Results/Response
 * ************************* */

enum DoResultCode {
  DeletionOK                    = 10,
  MutationOK                    = 11,
  GetOK                         = 12,
  GetManyOK                     = 13,
  TSError                       = 21,
  KeyExistsException            = 22,
  KeyNotExistsException         = 23,
  InvalidOptionPresentException = 24,
}

// DoResult for add, replace, set, and rename
struct MutationResult {
  1: required Timestamp timestamp,
}

struct TSErrorResult {
  1: required Timestamp timestamp,
}

struct KeyExistsResult {
  1: required Timestamp timestamp,
}

struct DoResult {
    1: required DoResultCode      result_code,
    2: optional MutationResult    mutate_kv, // add, replace, set, rename
    3: optional GetResponse       get_kv,
    4: optional GetManyResponse   get_many,
   11: optional TSErrorResult     ts_error,
   12: optional KeyExistsResult   key_exists,
}

struct DoResponse {
  1: required list<DoResult> results
}

struct TxnFailure {
  // TODO
}


/* ************************* *
 * Exceptions
 * ************************* */

exception ServiceNotAvailableException {}

exception TimedOutException {}

exception TableNotFoundException {}

exception TSErrorException {
  1: required Timestamp timestamp,
}

exception KeyExistsException {
  1: required Timestamp timestamp,
}

exception KeyNotExistsException {}

exception InvalidOptionPresentException {}

exception TransactionFailureException {
  1: required i32        do_op_index,
  2: required DoResult   do_result,
}

exception UnexpectedError {
  1: optional string error,
}


/* ************************* *
 * Service
 * ************************* */

service Hibari {

  /**
   * add
   */
  Timestamp add_kv(1: required string table,
                   2: required binary key,
                   3: required binary value,
                   4: required list<Property> properties,
                   5: required AddOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TableNotFoundException table_not_found,
              4: InvalidOptionPresentException invalid_opt,
              5: KeyExistsException key_exsits,
              6: UnexpectedError unexpected)

  /**
   * replace
   */
  Timestamp replace_kv(1: required string table,
                       2: required binary key,
                       3: required binary value,
                       4: required list<Property> properties,
                       5: required UpdateOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TableNotFoundException table_not_found,
              4: InvalidOptionPresentException invalid_opt,
              5: KeyNotExistsException key_exsits,
              6: TSErrorException ts_error,
              7: UnexpectedError unexpected)

  /**
   * rename
   */
  Timestamp rename_kv(1: required string table,
                      2: required binary key,
                      3: required binary new_key,
                      4: required list<Property> properties,
                      5: required UpdateOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TableNotFoundException table_not_found,
              4: InvalidOptionPresentException invalid_opt,
              5: KeyNotExistsException key_not_exsits,
              6: TSErrorException ts_error,
              7: UnexpectedError unexpected)

  /**
   * set
   */
  Timestamp set_kv(1: required string table,
                   2: required binary key,
                   3: required binary value,
                   4: required list<Property> properties,
                   5: required UpdateOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TableNotFoundException table_not_found,
              4: InvalidOptionPresentException invalid_opt,
              5: TSErrorException ts_error)

  /**
   * delete
   */
  void delete_kv(1: required string table,
                 2: required binary key,
                 3: required DeleteOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TableNotFoundException table_not_found,
              4: InvalidOptionPresentException invalid_opt,
              5: KeyNotExistsException key_not_exsits,
              6: TSErrorException ts_error,
              7: UnexpectedError unexpected)

  /**
   * get
   */
  GetResponse get_kv(1: required string table,
                     2: required binary key,
                     3: required GetOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TableNotFoundException table_not_found,
              4: KeyNotExistsException key_not_exsits,
              5: TSErrorException ts_error,
              6: UnexpectedError unexpected)

  /**
   * get_many
   */
  GetManyResponse get_many(1: required string table,
                           2: required binary key,
                           3: required i32    max_keys,
                           4: required GetManyOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TableNotFoundException table_not_found,
              4: TSErrorException ts_error,
              5: UnexpectedError unexpected)

  /**
   * do
   */
  DoResponse do_ops(1: required string    table,
                    2: required list<Op>  do_operations,
                    3: required DoOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TableNotFoundException table_not_found,
              4: TransactionFailureException txn_fail,
              5: UnexpectedError unexpected)

}
