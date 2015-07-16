require "set"
require "pp"
#Window System
#
# /base/*
#   Access child widgets
# /title:s
#   Set title
class Window
    def render()
    end
end

#Widget System
#
# /*/spawn:S
#   Create an instance of class $1 as a child of the widget
# /*/
class Widget
    def render(context)
    end

    def planLayout(layout)
    end
end

#Storage System
#
# /fetch:S
#   Put in a request for uri $1 [async]
# /get:S
#   Get the value for uri $1 [sync]
#   Reply -  value
# /put:S*
#   Set the value for uri $1 to $2
#

class StateStore
    def needValue(uri)
    end
end



#Meta Object Protocol
#
# /start_context:
#   Create a context to operate on
#
# /create_class:Si
#   Generate an instance of the metaclass based off of $1
#
# /add_attr:SS
#   Generate a attribute named $1 with type $2
#
# /add_method:SSs
#   Generate a method named $1 with signature $2 and body $2
#
# /commit_instance:i
#   Close opened metaclass
#
# /end_context:
#   Close a context

load "parse-types.rb"

#IR Commands
SC = "/start_context"
CC = "/create_class"
AA = "/add_attr"
CA = "/connect_attr"
SA = "/set_attr"
SP = "/set_parent"
AM = "/add_method"
CI = "/commit_instance"
EC = "/end_context"

class ProgCreator
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
                puts "Ignoring..."
            when CC
                puts "Creating #{inst[1]}"
                instance << Kernel.const_get(inst[1]).new
            when AA
                puts "Adding attribute..."
                (id,name,type) = inst[1..3]
                add_attr(instance[id], name, type)
            when SP
                puts "Setting parent..."
                (child, parent) = inst[1..2]
                instance[parent].children << instance[child]
            when CA
                puts "Connecting field..."
                (obj, field, value) = inst[1..3]
                instance[obj].send(field+"=",value)
            when EC
                puts "Ignoring..."
            else
                puts "Unknown Opcode..."
            end
        end
        pp instance
    end
end

class ProgramIR
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
        pp command
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

class Loader
    States = [:sGlobal, :sField, :sInst]
    def load_qml_from_file(f)
        load_qml(open(f))
    end

    def read_string(s)
        res = ""
        ss = ""
        while(!s.eof && (ss=s.getc) != "\"")
            res << ss
        end
        res
    end

    def consume_tok(s)
        g = ""
        ss = ''
        while(!s.eof && (ss=s.getc).match(/\s/))
        end
        if(!ss.match(/\s/))
           g = ss
        end
        if(g == "{" || g == "}")
            return g
        end
        if(g == "\"")
            puts "Reading string..."
            return read_string(s)
        end
        while(!s.eof && !(ss=s.getc).match(/[\s}{]/))
            g << ss
        end
        if(!ss.length != 0)
            s.ungetc ss
        end
        g
    end

    def consume_value_tok(s)
        g = ""
        ss = ''
        #Consume leading whitespace
        while(!s.eof && (ss=s.getc).match(/\s/))
        end

        #Consume first char
        depth = 0
        if(!ss.match(/\s/))
           g = ss
           if(ss=="{")
               depth = 1
           end
        end

        while(!s.eof && (!(ss=s.getc).match(/[\n;}]/) || (depth != 0)))
            if(ss == "{")
                depth += 1
            elsif(ss == "}")
                depth -= 1
            end
            g << ss
        end
        if(!ss.length != 0)
            s.ungetc ss
        end
        g
    end

    def consume_line(s)
        while(s.getc != "\n" && !s.eof)
        end
    end

    def consume_inst(s,depth=1)
        program = []
        tok = consume_tok(s)
        if(tok != '{')
            puts "Unexpected '#{tok}' Expected '{'"
            exit
        end
        while(true)
            tok = consume_tok(s)
            puts "#{" "*depth}Nexted tok: #{tok} @ #{depth}"
            if(tok == '}')
                return program
            elsif(tok == "")
                puts "Expected '}', but the end of the file was reached..."
                return program
            elsif(tok == "property")
                type = consume_tok(s)
                name = consume_tok(s)
                program << TProp.new(name, type)
                value = consume_value_tok(s)
                program << TAssign.new(name, value)
            elsif(tok == "id:")
                value = consume_value_tok(s)
                program << TID.new(value)
            elsif(tok[0] == tok[0].downcase)
                value = consume_value_tok(s)
                puts "#{" "*depth}Assign value = #{value}"
                program << TAssign.new(tok, value)
            else
                contents = consume_inst(s,depth+1)
                program << TInst.new(tok,contents)
            end
        end
        program
    end

    def load_qml(s)
        state = :sGlobal
        program = []

        while(!s.eof)
            puts ""
            if(state == :sGlobal)
                tok = consume_tok(s)
                puts tok
                if(tok == "import")
                    puts "TImport"
                    consume_line(s)
                    program << TImport.new
                elsif(tok != "")
                    puts "TInst"
                    contents = consume_inst(s)
                    program << TInst.new(tok, contents)
                else
                    break
                end
            end
        end
        program
    end

    def execute_inst(inst,depth=1)
        if(!inst.member.empty?)
            puts " "*depth + "Create subclass"
            inst.member.each do |x|
                puts " "*depth + "Add member '#{x.name}' with type '#{x.type}'"
            end
        end

        inst.props.each do |x|
            puts " "*depth + "Set '#{x.field}' = '#{x.value}'"
        end
        inst.subobj.each do |x|
            puts " "*depth + "Construct instance of '#{x.name}#{x.member.empty? ? "" : "#"}'"
            execute_inst(x, depth+1)
            puts " "*depth + "Push Instance into #{inst.name}"
        end
    end

    def execute_prog(prog)
        prog.each do |x|
            if(x.is_a? TImport)
                puts "#Ignore Import Statement"
            elsif(x.is_a? TInst)
                puts "Construct instance of '#{x.name}#{x.member.empty? ? "" : "#"}'"
                execute_inst(x)
            end
        end
    end
end

#Dummy classes
class Rectangle
    attr_accessor :children
    def initialize()
        @children = []
    end
end
class Model
end
class Structure
end

l = Loader.new
prog =  l.load_qml_from_file("../test/PropertyFunctionTest.qml")
#prog =  l.load_qml_from_file("MainMenu.qml")
puts prog
puts
puts "Execution"
puts "---------"
l.execute_prog prog
puts "Real Execution"
puts "--------------"
pir = ProgramIR.new(prog[0])
pc  = ProgCreator.new(pir.IR)
