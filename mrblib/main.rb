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
load "parser.rb"

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

load "prog-vm.rb"
load "prog-ir.rb"

#Dummy classes
class Rectangle
    attr_accessor :children
    def initialize()
        @children = []
    end
end
class Model; end
class Structure; end
class ZGrid; attr_accessor :children, :rows, :cols

    def initialize()
        @children = []
    end
end
class ZLayout;
    attr_accessor :children
    def initialize()
        @children = []
    end
end
class DropDown; attr_accessor :text end
class Button; attr_accessor :text, :renderer, :label end
class Blank;
    attr_accessor :children
    def initialize()
        @children = []
    end
end
class HLayout;
    attr_accessor :children
    def initialize()
        @children = []
    end
end
class VLayout;
    attr_accessor :children
    def initialize()
        @children = []
    end
end
class TextLine; attr_accessor :text, :label end
class OptionList; attr_accessor :resetable, :label, :numbered end
class MenuBar;
    attr_accessor :children
    def initialize()
        @children = []
    end
end
class Radio; attr_accessor :options end
class TextBox; attr_accessor :label end

def runTest
    l = Parser.new
    #prog = l.load_qml_from_file("../test/PropertyFunctionTest.qml")
    #prog = l.load_qml_from_file("../test/MainMenu.qml")
    prog = l.load_qml_from_file("../test/BankView.qml")
    puts prog
    puts
    root_node = nil
    prog.each do |x|
        if(x.is_a? TInst)
            root_node = x
        end
    end
    puts "Real Execution"
    puts "--------------"
    pir = ProgIR.new(root_node)
    pc  = ProgVM.new(pir.IR)
    pp pc.instance
end
start = Time.now
runTest
finish = Time.now
puts "Execution took #{finish-start} second(s)"
