# Copyright (c) 2015 Cinchapi, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative 'base'

class RubyClientDriverTest < IntegrationBaseTest

    def test_abort
        @client.stage
        key = TestUtils.random_string
        value = "some value"
        record = 1
        @client.add key, value, record
        @client.abort
        assert_equal(nil, @client.get(key:key, record:record))
    end

    def test_add_key_value
        key = TestUtils.random_string
        value = "some value"
        record = @client.add key, value
        assert_not_nil record
        stored = @client.get key, record
        assert_equal(value, stored)
    end

    def test_add_key_value_record
        key = "foo"
        value = "static value"
        record = 17
        assert @client.add key, value, record
        stored = @client.get key, record
        assert_equal(value, stored)
    end

    def test_add_key_value_records
        key = TestUtils.random_string
        value = "static value"
        records = [1, 2, 3]
        result = @client.add key, value, records
        assert result.is_a? Hash
        assert result[1]
        assert result[2]
        assert result[3]
    end

    def test_audit_key_record
        key = TestUtils.random_string
        values = ["one", "two", "three"]
        record = 1000
        for value in values do
            @client.set key, value, record
        end
        audit = @client.audit key, record
        assert_equal(5, audit.length)
        expected = "ADD"
        audit.each do |k, v|
            assert(v.start_with? expected)
            expected = expected == "ADD" ? "REMOVE" : "ADD"
        end
    end

    def test_audit_key_record_start
        key = TestUtils.random_string
        values = ["one", "two", "three"]
        record = 1000
        for value in values do
            @client.set key, value, record
        end
        start = @client.time
        values = [4, 5, 6]
        for value in values do
            @client.set key, value, record
        end
        audit = @client.audit key, record, start:start
        assert_equal 6, audit.length
    end

    def test_audit_key_record_start_end
        key = TestUtils.random_string
        values = ["one", "two", "three"]
        record = 1000
        for value in values do
            @client.set key, value, record
        end
        start = @client.time
        values = [4, 5, 6]
        for value in values do
            @client.set key, value, record
        end
        tend = @client.time
        values = [true, false]
        for value in values do
            @client.set key, value, record
        end
        audit = @client.audit key, record, start:start, end:tend
        assert_equal 6, audit.length
    end

    def test_audit_key_record_startstr
        key = TestUtils.random_string
        values = ["one", "two", "three"]
        record = 1000
        for value in values do
            @client.set key, value, record
        end
        anchor = get_time_anchor
        values = [4, 5, 6]
        for value in values do
            @client.set key, value, record
        end
        start = get_elapsed_millis_string anchor
        audit = @client.audit key, record, start:start
        assert_equal 6, audit.length
    end

    def test_adit_key_record_startstr_endstr
        key = TestUtils.random_string
        values = ["one", "two", "three"]
        record = 1000
        for value in values do
            @client.set key, value, record
        end
        sanchor = get_time_anchor
        values = [4, 5, 6]
        for value in values do
            @client.set key, value, record
        end
        eanchor = get_time_anchor
        values = [true, false]
        for value in values do
            @client.set key, value, record
        end
        start = get_elapsed_millis_string sanchor
        tend = get_elapsed_millis_string eanchor
        audit = @client.audit key, record, start:start, end:tend
        assert_equal 6, audit.length
    end

    def test_audit_record
        key1 = TestUtils.random_string
        key2 = TestUtils.random_string
        key3 = TestUtils.random_string
        value = "foo"
        record = 1002
        @client.add key1, value, record
        @client.add key2, value, record
        @client.add key3, value, record
        audit = @client.audit record
        assert_equal 3, audit.length
    end

    def test_audit_record_start
        key1 = TestUtils.random_string
        key2 = TestUtils.random_string
        key3 = TestUtils.random_string
        value = "bar"
        record = 344
        @client.add key1, value, record
        @client.add key2, value, record
        @client.add key3, value, record
        start = @client.time
        @client.remove key1, value, record
        @client.remove key2, value, record
        @client.remove key3, value, record
        audit = @client.audit record, start:start
        assert_equal 3, audit.length
    end

    def test_audit_record_start_end
        key1 = TestUtils.random_string
        key2 = TestUtils.random_string
        key3 = TestUtils.random_string
        value = "bar"
        record = 344
        @client.add key1, value, record
        @client.add key2, value, record
        @client.add key3, value, record
        start = @client.time
        @client.remove key1, value, record
        @client.remove key2, value, record
        @client.remove key3, value, record
        tend = @client.time
        @client.add key1, value, record
        @client.add key2, value, record
        @client.add key3, value, record
        audit = @client.audit record, start:start, end:tend
        assert_equal 3, audit.length
    end

    def test_audit_record_startstr
        key1 = TestUtils.random_string
        key2 = TestUtils.random_string
        key3 = TestUtils.random_string
        value = "bar"
        record = 344
        @client.add key1, value, record
        @client.add key2, value, record
        @client.add key3, value, record
        anchor = get_time_anchor
        @client.remove key1, value, record
        @client.remove key2, value, record
        @client.remove key3, value, record
        start = get_elapsed_millis_string anchor
        audit = @client.audit record, start:start
        assert_equal 3, audit.length
    end

    def test_audit_record_startstr_endstr
        key1 = TestUtils.random_string
        key2 = TestUtils.random_string
        key3 = TestUtils.random_string
        value = "bar"
        record = 344
        @client.add key1, value, record
        @client.add key2, value, record
        @client.add key3, value, record
        sanchor = get_time_anchor
        @client.remove key1, value, record
        @client.remove key2, value, record
        @client.remove key3, value, record
        eanchor = get_time_anchor
        @client.add key1, value, record
        @client.add key2, value, record
        @client.add key3, value, record
        start = get_elapsed_millis_string sanchor
        tend = get_elapsed_millis_string eanchor
        audit = @client.audit record, start:start, end:tend
        assert_equal 3, audit.length
    end

    def test_browse_key
        key = TestUtils.random_string
        value = 10
        @client.add key, value, [1, 2, 3]
        value = TestUtils.random_string
        @client.add key, value, [10, 20, 30]
        data = @client.browse key
        assert_equal [1, 2, 3].sort!, data[10].sort!
        assert_equal [10, 20, 30].sort!, data[value.to_sym].sort!
    end

    def test_browse_key_time
        key = TestUtils.random_string
        value = 10
        @client.add key, value, [1, 2, 3]
        value = TestUtils.random_string
        @client.add key, value, [10, 20, 30]
        time = @client.time
        @client.add key, value, [100, 200, 300]
        data = @client.browse key, time:time
        assert_equal [10, 20, 30].sort!, data[value.to_sym].sort!
    end

    def test_browse_key_timestr
        key = TestUtils.random_string
        value = 10
        @client.add key, value, [1, 2, 3]
        value = TestUtils.random_string
        @client.add key, value, [10, 20, 30]
        anchor = get_time_anchor
        @client.add key, value, [100, 200, 300]
        time = get_elapsed_millis_string anchor
        data = @client.browse key, time:time
        assert_equal [10, 20, 30].sort!, data[value.to_sym].sort!
    end

    def test_browse_keys
        key1 = TestUtils.random_string
        key2 = TestUtils.random_string
        key3 = TestUtils.random_string
        value1 = "A"
        value2 = "B"
        value3 = "C"
        record1 = 1
        record2 = 2
        record3 = 3
        @client.add key1, value1, record1
        @client.add key2, value2, record2
        @client.add key3, value3, record3
        data = @client.browse [key1, key2, key3]
        assert_equal({value1.to_sym => [record1]}, data[key1.to_sym])
        assert_equal({value2.to_sym => [record2]}, data[key2.to_sym])
        assert_equal({value3.to_sym => [record3]}, data[key3.to_sym])
    end

    def test_browse_keys_time
        key1 = TestUtils.random_string
        key2 = TestUtils.random_string
        key3 = TestUtils.random_string
        value1 = "A"
        value2 = "B"
        value3 = "C"
        record1 = 1
        record2 = 2
        record3 = 3
        @client.add key1, value1, record1
        @client.add key2, value2, record2
        @client.add key3, value3, record3
        time = @client.time
        @client.add key1, "Foo"
        @client.add key2, "Foo"
        @client.add key3, "Foo"
        data = @client.browse [key1, key2, key3], time:time
        assert_equal({value1.to_sym => [record1]}, data[key1.to_sym])
        assert_equal({value2.to_sym => [record2]}, data[key2.to_sym])
        assert_equal({value3.to_sym => [record3]}, data[key3.to_sym])
    end

    def test_browse_keys_timestr
        key1 = TestUtils.random_string
        key2 = TestUtils.random_string
        key3 = TestUtils.random_string
        value1 = "A"
        value2 = "B"
        value3 = "C"
        record1 = 1
        record2 = 2
        record3 = 3
        @client.add key1, value1, record1
        @client.add key2, value2, record2
        @client.add key3, value3, record3
        anchor = get_time_anchor
        @client.add key1, "Foo"
        @client.add key2, "Foo"
        @client.add key3, "Foo"
        time = get_elapsed_millis_string anchor
        data = @client.browse [key1, key2, key3], time:time
        assert_equal({value1.to_sym => [record1]}, data[key1.to_sym])
        assert_equal({value2.to_sym => [record2]}, data[key2.to_sym])
        assert_equal({value3.to_sym => [record3]}, data[key3.to_sym])
    end

    def test_chronologize_key_record
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        @client.add key, 2, record
        @client.add key, 3, record
        @client.remove key, 1, record
        @client.remove key, 2, record
        @client.remove key, 3, record
        data = @client.chronologize key:key, record:record
        assert_equal [[1], [1, 2], [1, 2, 3], [2, 3], [3]], data.values
    end

    def test_chronologize_key_record_start
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        @client.add key, 2, record
        @client.add key, 3, record
        start = @client.time
        @client.remove key, 1, record
        @client.remove key, 2, record
        @client.remove key, 3, record
        data = @client.chronologize key:key, record:record, start:start
        assert_equal [[2, 3], [3]], data.values
    end

    def test_chronologize_key_record_startstr
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        @client.add key, 2, record
        @client.add key, 3, record
        anchor = get_time_anchor
        @client.remove key, 1, record
        @client.remove key, 2, record
        @client.remove key, 3, record
        start = get_elapsed_millis_string anchor
        data = @client.chronologize key:key, record:record, start:start
        assert_equal [[2, 3], [3]], data.values
    end

    def test_chronologize_key_record_start_end
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        @client.add key, 2, record
        @client.add key, 3, record
        start = @client.time
        @client.remove key, 1, record
        tend = @client.time
        @client.remove key, 2, record
        @client.remove key, 3, record
        data = @client.chronologize key:key, record:record, time:start, end:tend
        assert_equal [[2, 3]], data.values
    end

    def test_chronologize_key_record_startstr_endstr
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        @client.add key, 2, record
        @client.add key, 3, record
        sanchor = get_time_anchor
        @client.remove key, 1, record
        eanchor = get_time_anchor
        @client.remove key, 2, record
        @client.remove key, 3, record
        start = get_elapsed_millis_string sanchor
        tend = get_elapsed_millis_string eanchor
        data = @client.chronologize key:key, record:record, time:start, end:tend
        assert_equal [[2, 3]], data.values
    end

    def test_clear_key_record
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        @client.add key, 2, record
        @client.add key, 3, record
        @client.clear key, record
        data = @client.select key:key, record:record
        assert_equal([], data)
    end

    def test_clear_key_records
        key = TestUtils.random_string
        records = [1, 2, 3]
        @client.add key, 1, records
        @client.add key, 2, records
        @client.add key, 3, records
        @client.clear key, records
        data = @client.select key:key, record:records
        assert_equal({}, data)
    end

    def test_clear_keys_record
        key1 = TestUtils.random_string 6
        key2 = TestUtils.random_string 7
        key3 = TestUtils.random_string 8
        record = TestUtils.random_integer
        @client.add key1, 1, record
        @client.add key2, 2, record
        @client.add key3, 3, record
        @client.clear [key1, key2, key3], record
        data = @client.select keys:[key1, key2, key3], record:record
        assert_equal({}, data)
    end

    def test_clear_keys_records
        data = {"a" => "A", "b" => "B", "c" => ["C", true], "d" => "D"}
        records = [1, 2, 3]
        @client.insert(data, records)
        @client.clear ['a', 'b', 'c'], records
        data = @client.get key:"d", records: records
        assert_equal({1 => "D", 2 => "D", 3 => "D"}, data)
    end

    def test_clear_record
        data = {
            "a" => "A",
            "B" => "B",
            "C" => ["C", true]
        }
        record = @client.insert(data)[0]
        @client.clear record
        data = @client.select record:record
        assert_equal({}, data)
    end

    def test_clear_records
        data = {
            'a'=> 'A',
            'b'=> 'B',
            'c'=> ['C', true],
            'd'=> 'D'
        }
        records = [1, 2, 3]
        @client.insert data, records
        @client.clear records
        data = @client.select records
        assert_equal({1=> {}, 2 => {}, 3 => {}}, data)
    end

    def test_commit
        @client.stage
        record = @client.add "name", "jeff nelson"
        @client.commit
        assert_equal(["name"], @client.describe(record))
    end

    def test_describe_record
        @client.set "name", "tom brady", 1
        @client.set "age", 100, 1
        @client.set "team", "new england patriots", 1
        keys = @client.describe 1
        assert_equal ["name", "age", "team"].sort!, keys.sort!
    end

    def test_describe_record_time
        @client.set "name", "tom brady", 1
        @client.set "age", 100, 1
        @client.set "team", "new england patriots", 1
        time = @client.time
        @client.clear "name", 1
        keys = @client.describe 1, time
        assert_equal ["name", "age", "team"].sort!, keys.sort!
    end

    def test_describe_record_timestr
        @client.set "name", "tom brady", 1
        @client.set "age", 100, 1
        @client.set "team", "new england patriots", 1
        anchor = get_time_anchor
        @client.clear "name", 1
        time = get_elapsed_millis_string anchor
        keys = @client.describe 1, time
        assert_equal ["name", "age", "team"].sort!, keys.sort!
    end

    def test_describe_records
        records = [1, 2, 3]
        @client.set "name", "tom brady", records
        @client.set "age", 100, records
        @client.set "team", "new england patriots", records
        keys = @client.describe records
        assert_equal ["name", "age", "team"].sort!, keys[1].sort!
        assert_equal ["name", "age", "team"].sort!, keys[2].sort!
        assert_equal ["name", "age", "team"].sort!, keys[3].sort!
    end

    def test_describe_records_time
        records = [1, 2, 3]
        @client.set "name", "tom brady", records
        @client.set "age", 100, records
        @client.set "team", "new england patriots", records
        time = @client.time
        @client.clear records
        keys = @client.describe records, time
        assert_equal ["name", "age", "team"].sort!, keys[1].sort!
        assert_equal ["name", "age", "team"].sort!, keys[2].sort!
        assert_equal ["name", "age", "team"].sort!, keys[3].sort!
    end

    def test_describe_records_timestr
        records = [1, 2, 3]
        @client.set "name", "tom brady", records
        @client.set "age", 100, records
        @client.set "team", "new england patriots", records
        anchor = get_time_anchor
        @client.clear records
        time = get_elapsed_millis_string anchor
        keys = @client.describe records, time
        assert_equal ["name", "age", "team"].sort!, keys[1].sort!
        assert_equal ["name", "age", "team"].sort!, keys[2].sort!
        assert_equal ["name", "age", "team"].sort!, keys[3].sort!
    end

    def test_diff_key_record_start
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        start = @client.time
        @client.add key, 2, record
        @client.remove key, 1, record
        diff = @client.diff key, record, start
        assert_equal [2], diff[Diff::ADDED]
        assert_equal [1], diff[Diff::REMOVED]
    end

    def test_diff_key_record_startstr
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        anchor = get_time_anchor
        @client.add key, 2, record
        @client.remove key, 1, record
        start = get_elapsed_millis_string anchor
        diff = @client.diff key, record, start
        assert_equal [2], diff[Diff::ADDED]
        assert_equal [1], diff[Diff::REMOVED]
    end

    def test_diff_key_record_start_end
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        start = @client.time
        @client.add key, 2, record
        @client.remove key, 1, record
        tend = @client.time
        @client.set key, 3, record
        diff = @client.diff key, record, start, tend
        assert_equal [2], diff[Diff::ADDED]
        assert_equal [1], diff[Diff::REMOVED]
    end

    def test_diff_key_record_startstr_endstr
        key = TestUtils.random_string
        record = TestUtils.random_integer
        @client.add key, 1, record
        sanchor = get_time_anchor
        @client.add key, 2, record
        @client.remove key, 1, record
        eanchor = get_time_anchor
        @client.set key, 3, record
        start = get_elapsed_millis_string sanchor
        tend = get_elapsed_millis_string eanchor
        diff = @client.diff key, record, start, tend
        assert_equal [2], diff[Diff::ADDED]
        assert_equal [1], diff[Diff::REMOVED]
    end

    def test_diff_key_start
        key = TestUtils.random_string
        @client.add key, 1, 1
        start = @client.time
        @client.add key, 2, 1
        @client.add key, 1, 2
        @client.add key, 3, 3
        @client.remove key, 1, 2
        diff = @client.diff key:key, start:start
        assert_equal 2, diff.length
        diff2 = diff[2]
        diff3 = diff[3]
        assert_equal [1], diff2[Diff::ADDED]
        assert_equal [3], diff3[Diff::ADDED]
        assert_equal nil, diff2[Diff::REMOVED]
        assert_equal nil, diff3[Diff::REMOVED]
    end

    def test_diff_key_startstr
        key = TestUtils.random_string
        @client.add key, 1, 1
        anchor = get_time_anchor
        @client.add key, 2, 1
        @client.add key, 1, 2
        @client.add key, 3, 3
        @client.remove key, 1, 2
        start = get_elapsed_millis_string anchor
        diff = @client.diff key:key, start:start
        assert_equal 2, diff.length
        diff2 = diff[2]
        diff3 = diff[3]
        assert_equal [1], diff2[Diff::ADDED]
        assert_equal [3], diff3[Diff::ADDED]
        assert_equal nil, diff2[Diff::REMOVED]
        assert_equal nil, diff3[Diff::REMOVED]
    end

    def test_diff_key_start_end
        key = TestUtils.random_string
        @client.add key, 1, 1
        start = @client.time
        @client.add key, 2, 1
        @client.add key, 1, 2
        @client.add key, 3, 3
        @client.remove key, 1, 2
        tend = @client.time
        @client.add key, 4, 1
        diff = @client.diff key:key, start:start, end:tend
        assert_equal 2, diff.length
        diff2 = diff[2]
        diff3 = diff[3]
        assert_equal [1], diff2[Diff::ADDED]
        assert_equal [3], diff3[Diff::ADDED]
        assert_equal nil, diff2[Diff::REMOVED]
        assert_equal nil, diff3[Diff::REMOVED]
    end

    def test_diff_key_startstr_endstr
        key = TestUtils.random_string
        @client.add key, 1, 1
        sanchor = get_time_anchor
        @client.add key, 2, 1
        @client.add key, 1, 2
        @client.add key, 3, 3
        @client.remove key, 1, 2
        eanchor = get_time_anchor
        @client.add key, 4, 1
        start = get_elapsed_millis_string sanchor
        tend = get_elapsed_millis_string eanchor
        diff = @client.diff key:key, start:start, end:tend
        assert_equal 2, diff.length
        diff2 = diff[2]
        diff3 = diff[3]
        assert_equal [1], diff2[Diff::ADDED]
        assert_equal [3], diff3[Diff::ADDED]
        assert_equal nil, diff2[Diff::REMOVED]
        assert_equal nil, diff3[Diff::REMOVED]
    end

    def test_diff_record_start
        @client.add "foo", 1, 1
        start = @client.time
        @client.set "foo", 2, 1
        @client.add "bar", true, 1
        diff = @client.diff record:1, time:start
        assert_equal [1], diff[:foo][Diff::REMOVED]
        assert_equal [2], diff[:foo][Diff::ADDED]
        assert_equal [true], diff[:bar][Diff::ADDED]
    end

    def test_diff_record_startstr
        @client.add "foo", 1, 1
        anchor = get_time_anchor
        @client.set "foo", 2, 1
        @client.add "bar", true, 1
        start = get_elapsed_millis_string anchor
        diff = @client.diff record:1, time:start
        assert_equal [1], diff[:foo][Diff::REMOVED]
        assert_equal [2], diff[:foo][Diff::ADDED]
        assert_equal [true], diff[:bar][Diff::ADDED]
    end

    def test_diff_record_start_end
        @client.add "foo", 1, 1
        start = @client.time
        @client.set "foo", 2, 1
        @client.add "bar", true, 1
        tend = @client.time
        @client.set "car", 100, 1
        diff = @client.diff record:1, time:start, end:tend
        assert_equal [1], diff[:foo][Diff::REMOVED]
        assert_equal [2], diff[:foo][Diff::ADDED]
        assert_equal [true], diff[:bar][Diff::ADDED]
    end

    def test_diff_record_startstr_endstr
        @client.add "foo", 1, 1
        sanchor = get_time_anchor
        @client.set "foo", 2, 1
        @client.add "bar", true, 1
        eanchor = get_time_anchor
        @client.set "car", 100, 1
        start = get_elapsed_millis_string sanchor
        tend = get_elapsed_millis_string eanchor
        diff = @client.diff record:1, time:start, end:tend
        assert_equal [1], diff[:foo][Diff::REMOVED]
        assert_equal [2], diff[:foo][Diff::ADDED]
        assert_equal [true], diff[:bar][Diff::ADDED]
    end

    def test_find_ccl
        
    end

end
