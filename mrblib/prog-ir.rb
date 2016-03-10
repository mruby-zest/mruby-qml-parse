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
        emit IrNode.new(CC, instance.file, instance.line,
                        [instance.name, this_id, instance.id],
                        ["class", "parent", "obj_name"])
        instance.extensions.each do |ext|
            emit IrNode.new(EI, ext.file, ext.line,
                            [this_id, ext],
                            ["obj_id", "mixin"])
        end
        instance.member.each do |member|
            emit IrNode.new(AA, member.file, member.line,
                            [this_id, member.name, member.type],
                            ["obj_id", "attr_name", "attr_type"])
        end
        instance.func.each do |func|
            emit IrNode.new(AM, func.file, func.line,
                            [this_id, func.name, func.arg_list, func.code],
                            ["obj_id", "func_name", "func_args", "code"])
        end
        instance.subobj.each do |obj|
            init_class(obj, this_id)
        end
        instance.props.each do |prop|
            emit IrNode.new(CA, prop.file, prop.line,
                            [this_id, prop.field, prop.value],
                            ["obj_id", "property", "value"])
        end
        if(parent)
            emit IrNode.new(SP, instance.file, instance.line,
                            [this_id, parent],
                            ["obj_id", "parent_id"])
        end
        emit IrNode.new(CI, instance.file, -1,
                        [this_id],
                        ["obj_id"])
    end
    def initialize(instance)
        @IR = []
        #puts getNames(instance)
        @cur_id = -1
        emit IrNode.new(SC, instance.file, 0, [])
        init_class(instance, nil)
        emit IrNode.new(EC, instance.file, -1, [])
    end
end
