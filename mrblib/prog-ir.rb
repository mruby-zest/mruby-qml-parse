#Class to convert parsed QML into a set of
#instructions needed to create an instance
class ProgIR

    #The instructions needed to create an instance
    attr_accessor :IR

    #Initialize IR instance from parsed QML TInst 
    #representation
    def initialize(instance)
        @IR = []
        @cur_id = -1
        emit IrNode.new(SC, instance.file, 0, [])
        init_class(instance, nil)
        emit IrNode.new(EC, instance.file, -1, [])
    end

    #Emit and record an instruction
    def emit(command)
        @IR << command
    end

    #Convert a class to a sequence of IR instructions
    def init_class(instance, parent)
        @cur_id += 1
        this_id = @cur_id

        #First the class instance needs to be created
        emit IrNode.new(CC, instance.file, instance.line,
                        [instance.name, this_id, instance.id],
                        ["class", "parent", "obj_name"])

        #If the class extends anything, then those pieces of
        #additional functionality need to be added to the class
        instance.extensions.each do |ext|
            emit IrNode.new(EI, ext.file, ext.line,
                            [this_id, ext],
                            ["obj_id", "mixin"])
        end

        #Next attributes for the class need to be defined
        instance.member.each do |member|
            emit IrNode.new(AA, member.file, member.line,
                            [this_id, member.name, member.type],
                            ["obj_id", "attr_name", "attr_type"])
        end

        #Now additional functions/methods on the class can be added
        instance.func.each do |func|
            emit IrNode.new(AM, func.file, func.line,
                            [this_id, func.name, func.arg_list, func.code],
                            ["obj_id", "func_name", "func_args", "code"])
        end

        #Subobjects can be added to the mostly constructed instance
        instance.subobj.each do |obj|
            init_class(obj, this_id)
        end

        #Now that subobjects are available it's feasible to add property
        #connections which could reference subobjects
        instance.props.each do |prop|
            emit IrNode.new(CA, prop.file, prop.line,
                            [this_id, prop.field, prop.value],
                            ["obj_id", "property", "value"])
        end

        #Lastly connect the instance to its parent
        if(parent)
            emit IrNode.new(SP, instance.file, instance.line,
                            [this_id, parent],
                            ["obj_id", "parent_id"])
        end

        #The class instance is now complete
        emit IrNode.new(CI, instance.file, -1,
                        [this_id],
                        ["obj_id"])
    end
end
