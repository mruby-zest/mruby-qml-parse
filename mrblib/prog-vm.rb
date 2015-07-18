class ProgVM
    attr_accessor :instance
    def add_attr(value, name, type)
        value.instance_eval("def #{name};@#{name};end")
        value.instance_eval("def #{name}=(val);@#{name}=val;end")
    end

    def initialize(ir)
        instance = []
        ir.each do |inst|
            op = inst[0]
            case op
            when SC
                #puts "Ignoring..."
            when CC
                #puts "Creating #{inst[1]}"
                instance << Kernel.const_get(inst[1]).new
            when AA
                #puts "Adding attribute..."
                (id,name,type) = inst[1..3]
                add_attr(instance[id], name, type)
            when SP
                #puts "Setting parent..."
                (child, parent) = inst[1..2]
                instance[parent].children << instance[child]
            when CA
                #puts "Connecting field..."
                (obj, field, value) = inst[1..3]
                instance[obj].send(field+"=",value)
            when CI
                #puts "Ignoring..."
            when EC
                #puts "Ignoring..."
            else
                puts "Unknown Opcode..."
                pp inst
            end
        end
        @instance = instance[0]
    end
end
