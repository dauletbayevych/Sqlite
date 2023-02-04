require 'readline'
require_relative "request"

def request_cli_params
    files = Readline.readline('my_sqlite_cli>> ', true)
    file = files
    return file
end

def va_set_type_params(arr)
    result_1 = Hash.new
    result = result_1 
    i = 0
    while i < arr.length 
        header, body = arr[i].split("=")
        result[header] = body
        i += 1
    end
    return result
end



def type_request_cli_sqlite(action, args, request)
    if(action == "from")
        request.from(*args)
    elsif(action == "select")
        request.select(args)
    elsif(action == "where")
        col, val = args[0].split("=")
        request.where(col, val)
    elsif(action == "insert")
        request.insert(*args)
    elsif(action == "values")
        request.values(va_set_type_params(args))
    elsif(action == "update")
        request.update(*args)
    elsif(action == "set")
        request.set(va_set_type_params(args)) 
    elsif(action == "delete")
        request.delete 
    else
        err_method() 
    end
end


def err_method() 
    puts "Undefined method!"
end

def type_cli_sqlite_pr(sql)
    valid_actions_e = ["SELECT", "FROM", "WHERE", "INSERT", "VALUES", "UPDATE", "SET", "DELETE"]
    valid_actions = valid_actions_e
    command_req = nil
    command = command_req
    args = []
    request = MySqliteRequest.new
    splited_command_param = sql.split(" ")
    splited_command = splited_command_param
    
    0.upto splited_command.length - 1 do |arg|
        if valid_actions.include?(splited_command[arg].upcase())
            if (command != nil) 
                if command != "..."
                    args = args.join(" ").split(", ")
                end
                type_request_cli_sqlite(command, args, request)
                command = nil
                args = []
            end
            command = splited_command[arg].downcase()
        else
            args << splited_command[arg]
        end
    end
    if args[-1].end_with?(";")
        args[-1] = args[-1].chomp(";")
        type_request_cli_sqlite(command, args, request)
        request.run
    else
        request_with_err() 
    end
end

def request_with_err() 
    p "Finish your request with -> ';' "
end

def run
    puts "MySQLite version 6.0.0 2022.12.08\n';' do not forget to put a mark\n"
    while command = request_cli_params
        if command == "exit"
            break
        else
            type_cli_sqlite_pr(command)
        end
    end
end

run()
