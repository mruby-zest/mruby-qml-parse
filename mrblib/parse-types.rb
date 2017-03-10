class TParseType
    attr_reader :line, :file
end

class TImport
    def initialize(file, line)
    end
    def inspect
        "(TImport)"
    end
end

class TExtend
    attr_reader :name
    def initialize(name, file, line)
        @name = name
    end
end

class TFunc < TParseType
    attr_accessor :name, :arg_list, :code
    def initialize(name, args, code, file, line)
        @name     = name
        @arg_list = args
        @file     = file
        @line     = line

        if(code[0] == "{")
            @code = code[1..-2]
        else
            @code = code
        end
    end
    def inspect
        "#<TFunc:#{@line}:#{@name}("+@arg_list+")\""+@code.split.join(" ").to_s+"\">"
    end
end

$anon_id = 0
class TInst < TParseType
    attr_accessor :name, :id, :member, :props, :func, :subobj, :extensions
    def initialize(instance, contents, file, line)
        $anon_id += 1
        @name   = instance
        @file   = file
        @line   = line
        @id     = "anonymous#{$anon_id}"
        @member = []
        @props  = []
        @subobj = []
        @func   = []
        @extensions = []
        contents.each do |x|
            if(x.is_a? TAssign)
                @props << x
            elsif(x.is_a? TInst)
                @subobj << x
            elsif(x.is_a? TProp)
                @member << x
            elsif(x.is_a? TID)
                @id = x.name
            elsif(x.is_a? TExtend)
                @extensions << x.name
            elsif(x.is_a? TFunc)
                @func << x
            end
        end
    end

    def inspect(depth=0)
        tmp = [@name, @extensions].flatten.join "+"
        res = " "*depth + "(TInst:#{@line}:"+tmp+"-"+@id
        @func.each do |x|
            res << "\n" + " "*(depth+1) + x.inspect
        end
        @member.each do |x|
            res << "\n" + x.inspect(depth+1)
        end
        @props.each do |x|
            res << "\n" + x.inspect(depth+1)
        end
        @subobj.each do |x|
            res << "\n" + x.inspect(depth+1)
        end
        res+")"

    end
end

class TID < TParseType
    attr_accessor :name
    def initialize(name, file, line)
        @name = name.strip
        @file = file
        @line = line
    end
end

class TLocal < TParseType
    attr_accessor :name, :type, :value
    def initialize(name, type, value, file, line)
        @name  = name.gsub(":","")
        @type  = type
        @value = value
        @file  = file
        @line  = line
    end
    def inspect(depth=0)
        " "*depth + "(TLocal #{@name} #{@type})"
    end
end

class TProp < TParseType
    attr_accessor :name, :type
    def initialize(name, type, file, line)
        @name = name.gsub(":","")
        @type = type
        @file = file
        @line = line
    end
    def inspect(depth=0)
        " "*depth + "(TProp #{@name} #{@type})"
    end
end

class TAssign < TParseType
    attr_accessor :field, :value
    def initialize(field, value, file, line)
        @field = field.gsub(":","")
        @value = value
        @file  = file
        @line  = line
    end
    def inspect(depth=0)
        " "*depth + "(TAssign:#{@line} #{@field} #{@value})"
    end
end

class IrNode
    attr_accessor :file, :line
    attr_accessor :type
    attr_accessor :fields

    def initialize(type, file, line, fields, pp_info=nil)
        @type    = type
        @file    = file
        @line    = line
        @fields  = fields
        @pp_info = pp_info
    end

    def to_s
        abbv = {"/start_context" => "SC",
                "/create_class"=> "CC",
                "/extend_instance"=> "EI",
                "/add_attr"=> "AA",
                "/connect_attr"=> "CA",
                "/set_attr"=> "SA",
                "/set_parent"=> "SP",
                "/add_method"=> "AM",
                "/commit_instance"=> "CI",
                "/end_context"=> "EC"}
        result = "IR:#{abbv[@type]}@#{@line}"

        if(@pp_info && @pp_info.length == @fields.length)
            @pp_info.each_with_index do |pp, i|
                if(pp == "obj_id")
                    result += "##{@fields[i]}"
                end
            end
            result += ":{"
            @pp_info.each_with_index do |pp, i|
                if(pp == "obj_id")
                    next
                else
                    result += "#{pp}=>#{@fields[i]}"
                end

                if(i != @pp_info.length-1)
                    result += ", "
                end
            end
            result +="}"
        else
            result += ":"+@fields.to_s
        end
        result
    end

    def[](i)
        [@type, @fields].flatten[i]
    end

    def length
        @fields.length + 1
    end
end
