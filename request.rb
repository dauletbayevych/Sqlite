require 'csv'

class MySqliteRequest
    def initialize
        @type_of_request_params   = :none
        @type_of_request = @type_of_request_params
        @select_columns_req    = []
        @select_columns = @select_columns_req
        @where_params_oren      = []
        @where_params = @where_params_oren
        @insert_attributes_pra = {}
        @insert_attributes = @insert_attributes_pra
        @table_name        = nil
        @order_por             = :asc
        @order = @order_por

    end

    def from(table_name)
        @table_name = table_name
        self
    end

    def select(columns)
        if(columns.is_a?(Array))
            @select_columns += columns.collect { |row| row.to_s}
        else
            @select_columns << columns.to_s
        end
        self._setTypeOfRequest_req(:select)
        self
    end

    def where(column_name, criteria)
        @where_params << [column_name, criteria]
        self
    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)
        self
    end

    def order(order, column_name)
        self
    end

    def insert(table_name)
        self._setTypeOfRequest_req(:insert)
        @table_name = table_name
        self
    end

    def values(data)
        if(@type_of_request == :insert)
            @insert_attributes = data
        else
           @insert_attributes = data
        end 
        self
    end

    def update(table_name)
        self._setTypeOfRequest_req(:update)
        @table_name = table_name
        self
    end

    def set(data)
        @insert_attributes = data
        self
    end

    def delete
        self._setTypeOfRequest_req(:delete)
        self
    end

    def update_delete_file_request(result)
        CSV.open(@table_name, "w", headers: true) do |n| 
            n << result[0].to_hash.keys
            result.each do |nba|
                n << CSV::Row.new(nba.to_hash.keys, nba.to_hash.values)
            end
        end
    end

    def print_select_type
        select_attrib()
        puts "Where Attributes #{@where_params}"
    end

    def select_attrib() 
        puts "Select Attributes #{@select_columns}"
    end

    def print_insert_type
        puts "Insert Attributes #{@select_columns}"
    end

    def no_infor()
        puts "No information found"
    end

    def print_select_type(result = nil)
    
        if !result
            return
        end
        if result.length == 0
            no_infor()
        else
            puts result.first.keys.join(' | ')
            len = result.first.keys.join(' | ').length
            puts "-_" * len
            result.each do |line|
                puts line.values.join(' | ')
            end
            puts "-_" * len
        end
    end

    def print
        puts "Type of request #{@type_of_request}"
        puts "Table name #{@table_name}"
        if(@type_of_request == :select)
            print_select_type()
        elsif(@type_of_request == :insert)
            print_insert_type
        end
    end

    def run
        print
        if(@type_of_request == :select)
            param_12 = _run_select_req
            param = param_12
            print_select_type(param)
        elsif(@type_of_request == :insert)
            _run_insert_request
        elsif(@type_of_request == :update)
            update_params = _run_update_req_sqlite
            update = update_params
            update_delete_file_request(update)
        elsif(@type_of_request == :delete)
            delete_por = _run_delete_req
            delete = delete_por
            update_delete_file_request(delete)
        end
    end

    def _setTypeOfRequest_req(new_type)
        if(@type_of_request == :none || @type_of_request == new_type)
            @type_of_request_param = new_type
            @type_of_request = @type_of_request_param
        else
            invalid_R()
        end
    end

    def invalid_R()
        raise 'Invalid request'
    end

    def _run_select_req
        req_data = CSV.parse(File.read(@table_name), headers: true)
        data = req_data
        result_oop = []
        result = result_oop
        if(@select_columns != [] && @where_params != [])
            data.each do |row|
                @where_params.each do |where_attribute|
                    if(row[where_attribute[0]] == where_attribute[1])
                        result << row.to_hash.slice(*@select_columns)
                    end
                end
            end
        elsif(@select_columns != [] && @where_params == [])
            data.each do |row|
                @select_columns.each do |sel_col|
                    if row[sel_col]
                        result << row.to_hash.slice(*@select_columns)
                    else
                        result << row.to_hash
                    end
                end
            end
        end
        result
    end

    def _run_insert_request
        File.open(@table_name, 'a') do |n|
            n.puts @insert_attributes.values.join(',')
        end 
    end

    def _run_update_req_sqlite
        data_param_1 = CSV.parse(File.read(@table_name), headers: true)
        data = data_param_1
        result = []
        data.each do |row|
            @where_params.each do |header, body|
                if body == row[header]
                    @insert_attributes.each do |header, body|
                        row[header] = body
                    end
                    result << row
                else
                    result << row
                end
            end
        end
        return result
    end

    def _run_delete_req
        data_param_ = CSV.parse(File.read(@table_name), headers: true)
        data = data_param_
        result_params = []
        result = result_params
        data.each do |row|
            @where_params.each do |header, body|
                if body == row[header]
                    next
                else
                    result << row
                end
            end
        end
        return result
    end 
end