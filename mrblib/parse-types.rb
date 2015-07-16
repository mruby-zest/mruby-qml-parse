
class TImport
    def to_s
        "(TImport)"
    end
end

class TInst
    attr_accessor :name, :id, :member, :props, :subobj
    def initialize(instance, contents)
        @name   = instance
        @id     = "anonymous"
        @member = []
        @props  = []
        @subobj = []
        contents.each do |x|
            if(x.is_a? TAssign)
                @props << x
            elsif(x.is_a? TInst)
                @subobj << x
            elsif(x.is_a? TProp)
                @member << x
            elsif(x.is_a? TID)
                @id = x.name
            end
        end
    end
    def to_s(depth=0)
        res = " "*depth + "(TInst:"+@name+"-"+@id
        @member.each do |x|
            res << "\n" + x.to_s(depth+1)
        end
        @props.each do |x|
            res << "\n" + x.to_s(depth+1)
        end
        @subobj.each do |x|
            res << "\n" + x.to_s(depth+1)
        end
        res+")"

    end
end

class TID
    attr_accessor :name
    def initialize(name)
        @name = name.strip
    end
end

class TProp
    attr_accessor :name, :type
    def initialize(name, type)
        @name = name[0...-1]
        @type = type
    end
    def to_s(depth=0)
        " "*depth + "(TProp #{@name} #{@type})"
    end
end

class TAssign
    attr_accessor :field, :value
    def initialize(field, value)
        @field = field[0...-1]
        @value = value
    end
    def to_s(depth=0)
        " "*depth + "(TAssign #{@field} #{@value})"
    end
end
