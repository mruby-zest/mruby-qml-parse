dummy_class = %{
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
#class Button; attr_accessor :text, :renderer, :label end
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
class TextBox; attr_accessor :label end}

#Dummy classes
def setup_classes
    eval(dummy_class)
end

$test_counter = 0
$test_err = 0
$test_quiet = false

def fail_test(str, a, b, nt="")
    puts "not ok #{$test_counter} - #{str}..."
    puts "# Expected #{nt}#{a.inspect}, but observed #{b.inspect} instead"
    $test_err += 1
end

def pass_test(str)
    puts "ok #{$test_counter} - #{str}..." unless $test_quiet
end

def assert_eq(a,b,str)
    $test_counter += 1
    err = a!=b
    if(err)
        fail_test(str, a, b)
    else
        pass_test(str)
    end
    err
end

def assert_not_eq(a,b,str)
    $test_counter += 1
    err = (a==b);
    if(err)
        fail_test(a,b,str,"not ")
    else
        pass_test(str)
    end
    err
end
def test_summary
    puts "# #{$test_err} test(s) failed out of #{$test_counter} (currently passing #{100.0-$test_err*100.0/$test_counter}% tests)" unless $test_quiet
end

def mruby_qml_parse_test_parse(path)
    setup_classes
    puts "#Creating Parser..."
    l = Parser.new
    prog = l.load_qml_from_file(path)
    puts "#Parsing PropertyFunctionTest.qml..."
    #prog = l.load_qml_from_file("../test/MainMenu.qml")
    #prog = l.load_qml_from_file("../../mruby-zest/mrblib/Widget.qml")
    #prog = l.load_qml_from_file("../test/BankView.qml")
    assert_eq(Array, prog.class,    "The parser generates an array of elements")
    assert_eq(1,     prog.length,   "The parse output is just one instantiation instruction (1/2)")
    assert_eq(TInst, prog[0].class, "The parse output is just one instantiation instruction (2/2)")
    i = prog[0]
    assert_eq(3,     i.member.length,   "Three Properties are parsed (1/2)")
    assert_eq(TProp, i.member[0].class, "Three Properties are parsed (2/2)")

    begin
        foo = i.member[0]
        assert_eq(path,     foo.file, "Parsed file locations are stored (1/2)")
        assert_eq(4,        foo.line, "Parsed file locations are stored (2/2)")
        assert_eq("string", foo.type, "Property types are parsed")
        assert_eq("fooVar", foo.name, "Property names are parsed")
    end

    assert_eq(3, i.props.length, "Property assignements are parsed")
    assert_eq(2, i.subobj.length, "Sub-objects are parsed")
    begin
        t = i.subobj[1]
        assert_eq(TInst,   t.class, "Sub-objects are seen as TInst")
        assert_eq("Model", t.name,  "Sub-object classes are parsed")
        assert_eq("model", t.id,    "Sub-object ids are parsed")
    end

    assert_eq("Rectangle", i.name, "Superclasses are parsed")

    i
end

def mruby_qml_parse_test_ir(root)
    pir = ProgIR.new(root)
    ir  = pir.IR
    puts ir.length

    assert_eq(SC, ir[0][0],  "IR begins with a /start_context")
    assert_eq(EC, ir[-1][0], "IR ends with a /end_context")

    assert_eq(CC, ir[1][0],                  "IR creates a top level class (1/2)")
    assert_eq("Rectangle", ir[1].fields[0], "IR creates a top level class (2/2)")
    assert_eq(CI, ir[-2][0], "IR closes classes after they're built")

    assert_eq(AA, ir[2][0], "IR contains attributes")
    assert_eq(CA, ir[11][0], "   and their assignments")
    assert_eq(16, ir.length, "Test IR has 16 instructions")
    #puts pir.IR
    ir
end

def mruby_qml_parse_test_vm(ir)
    pc  = ProgVM.new(ir)
    ist = pc.instance
    assert_eq(Rectangle, ist.class, "The VM creates an instance from the IR")
    assert_eq(2, ist.children.length, "The object has children")
end

def runTest

    in_test = `pwd`.include?("mrblib")
    path = "test/PropertyFunctionTest.qml"
    if(in_test)
        path = "../" + path
    end
    root = mruby_qml_parse_test_parse(path)

    puts "#"
    puts "#Creating Program VM IR Instructions"
    puts "#"
    ir = mruby_qml_parse_test_ir(root)

    puts "#"
    puts "#Creating Instance through VM"
    puts "#"
    mruby_qml_parse_test_vm(ir)


    return
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
