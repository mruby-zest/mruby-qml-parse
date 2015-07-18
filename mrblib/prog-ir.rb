class ProgIR
    attr_accessor :IR
    def getNames(instance)
        names = Set.new
        names << instance.id
        instance.subobj.each do |x|
            names << getNames(x)
        end
        names.to_a
    end
    def emit(command)
        @IR << command
        #pp command
    end
    def init_class(instance, parent)
        @cur_id += 1
        this_id = @cur_id
        emit [CC, instance.name, this_id]
        instance.member.each do |member|
            emit [AA, this_id, member.name, member.type]
        end
        emit [CI, this_id]
        instance.subobj.each do |obj|
            init_class(obj, this_id)
        end
        instance.props.each do |prop|
            emit [CA, this_id, prop.field, prop.value]
        end
        if(parent)
            emit [SP, this_id, parent]
        end
    end
    def initialize(instance)
        @IR = []
        puts getNames(instance)
        @cur_id = -1
        emit [SC]
        init_class(instance, nil)
        emit [EC]
    end
end
