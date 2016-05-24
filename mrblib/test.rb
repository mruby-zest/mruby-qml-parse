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
    in_test = `pwd`.include?("mrblib")
    path = "test/PropertyFunctionTest.qml"
    if(in_test)
        path = "../" + path
    end
    prog = l.load_qml_from_file(path)
    #prog = l.load_qml_from_file("../test/MainMenu.qml")
    #prog = l.load_qml_from_file("../../mruby-zest/mrblib/Widget.qml")
    #prog = l.load_qml_from_file("../test/BankView.qml")
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
    puts pir.IR
    pc  = ProgVM.new(pir.IR)
    puts "Resulting Instance"
    puts "------------------"
    puts pc.instance


    path = "test/LocalPropTest.qml"
    path = "../" + path if(in_test)
    #Run test on the local variable file
    prog = l.load_qml_from_file(path)
    #prog = l.load_qml_from_file("../test/MainMenu.qml")
    #prog = l.load_qml_from_file("../../mruby-zest/mrblib/Widget.qml")
    #prog = l.load_qml_from_file("../test/BankView.qml")
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
    puts pir.IR
    pc  = ProgVM.new(pir.IR)
    puts "Resulting Instance"
    puts "------------------"
    puts pc.instance
end
#start = Time.now
#runTest
#finish = Time.now
#delta = finish-start
#puts "Execution took #{1000*delta} millisecond(s)"
#puts "#{delta*60.0*100.0}% of a frame..."
