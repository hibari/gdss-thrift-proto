#!/usr/local/bin/thrift --gen erl --gen go --gen hs --gen java --gen js:node --gen php --gen py --gen rb
#----------------------------------------------------------------------
# Copyright (c) 2008-2015 Hibari developers.  All rights reserved.
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

namespace java org.hibaridb.thrift

typedef i64 ExpTime
typedef i64 Timestamp

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

struct DoTransaction { }

struct DoAdd {
  1: required binary key,
  2: required binary value,
  3: optional list<Property> properties,   // @TODO Change to map<binary, binary> ?
  4: required AddOptions     options,
}

struct DoReplace {
  1: required binary key,
  2: required binary value,
  3: optional list<Property> properties,
  4: required UpdateOptions  options,
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
   51: optional DoDelete      delete_kv,
  101: optional DoGet         get_kv,
  102: optional DoGetMany     get_many,
}

struct DoOptions {
  1: optional bool fail_if_wrong_role,
  2: optional bool ignore_role,
}

struct GetResponse {
  1: required Timestamp      timestamp,
  2: optional binary         value,
  3: optional ExpTime        exp_time,
  4: optional list<Property> proplist,
}

struct GetManyResponse {
  1: required list<GetResponse> records,
  2: required bool is_truncated,
}

struct DoResult {
  1: required bool            is_success,
  2: optional Timestamp       timestamp,   // add, replace, set, rename
  3: optional GetResponse     get_res,
  4: optional GetManyResponse get_many_res,
}

struct DoResponse {
  1: required list<DoResult> results
}

struct TxnFailure {
  // TODO
}

exception ServiceNotAvailableException {}

exception NotImplementedException {}

exception TimedOutException {}

exception TSErrorException {
  1: required binary key,
  2: required Timestamp timestamp,
}

exception KeyExistsException {
  1: required binary key,
  2: required Timestamp timestamp,
}

exception KeyNotExistsException {
  1: required binary key,
}

exception InvalidOptionPresentException {}

exception TransactionFailureException {
  1: required i32        do_op_index,
  2: required TxnFailure failure,       // @TODO: Change to "reason"
}

exception UnexpectedError {
  1: optional string error,
}

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
              3: InvalidOptionPresentException invalid_opt,
              4: KeyExistsException key_exsits)

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
              3: InvalidOptionPresentException invalid_opt,
              4: KeyNotExistsException key_exsits,
              5: TSErrorException ts_error)

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
              3: InvalidOptionPresentException invalid_opt,
              4: KeyNotExistsException key_not_exsits,
              5: TSErrorException ts_error)

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
              3: InvalidOptionPresentException invalid_opt,
              4: TSErrorException ts_error)

  /**
   * delete
   */
  void delete_kv(1: required string table,
                 2: required binary key,
                 3: required DeleteOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: InvalidOptionPresentException invalid_opt,
              4: KeyNotExistsException key_not_exsits,
              5: TSErrorException ts_error)

  /**
   * get
   */
  GetResponse get_kv(1: required string table,
                     2: required binary key,
                     3: required GetOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: KeyNotExistsException key_not_exsits,
              4: TSErrorException ts_error)

  /**
   * get_many
   */
  GetManyResponse get_many(1: required string table,
                           2: required binary key,
                           3: required i32    max_keys,
                           4: required GetManyOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TSErrorException ts_error)

  /**
   * do
   */
  DoResponse do_ops(1: required string    table,
                    2: required list<Op>  do_operations,
                    3: required DoOptions options)
      throws (1: ServiceNotAvailableException not_avail,
              2: TimedOutException timeout,
              3: TransactionFailureException txn_fail)

}
