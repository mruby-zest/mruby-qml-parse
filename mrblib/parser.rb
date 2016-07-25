class Parser
    def initialize
        @stream = nil
        @file    = "(anonymous)"
        @line    = 0
    end


    def load_qml_from_file(f)
        @file = f
        @line = 1
        #puts("loadqml(#{f})")
        load_qml(open(f))
    end

    #Proxy Methods
    def eof
        @stream_pos >= @stream_len
    end

    def ungetc(ch)
        @line -= 1 if ch == "\n"
        @stream_pos -= 1
    end

    def getc
        ch = @stream[@stream_pos]
        @line += 1 if ch == "\n"
        @stream_pos += 1
        ch
    end

    #Consume a string from " to "
    def read_string
        res = ""
        ss = ""
        while(!eof && (ss=getc) != "\"")
            @line += 1 if ss == "\n"
            res << ss
        end
        "\""+res+"\""
    end

    def consume_tok
        g = ""
        ss = ''
        while(!eof && ss=getc)
            if(!space?(ss))
                break
            end
        end
        if(ss && !space?(ss))
           g = ss
        end
        if("{}".include? g)
            return g
        end
        while(!eof && ss=getc)
            if(space?(ss) || special?(ss))
                break
            end
            @line += 1 if ss == "\n"
            g << ss
            if(g == "//")
                consume_line
                return consume_tok
            end
        end
        if(!ss.nil? && ss.length != 0)
            ungetc ss
        end
        #puts "tok = '#{g}'"
        g
    end

    def consume_value_tok
        ss = ''
        #Consume leading whitespace
        while(!eof && space?(ss=getc))
        end

        #Consume first char
        if(!space?(ss))
           if(ss == "\"")
               return read_string
           else
               ungetc ss
           end
        end

        srt = @stream_pos
        depth = 0
        while(!eof && (ss=getc) && ((depth != 0) || !term?(ss)))
            if(ss == "{")
                depth += 1
            elsif(ss == "}")
                depth -= 1
            elsif(ss == "[")
                depth += 1
            elsif(ss == "]")
                depth -= 1
            end
        end
        nd = @stream_pos-1
        if(ss.length != 0)
            ungetc ss
        end
        @stream[srt...nd]
    end

    def term?(c)
        "\n;}".include? c
    end

    def space?(c)
        "\n \t\r".include? c
    end

    def special?(c)
        "{}()".include? c
    end

    def consume_arg_list
        out=""
        ss = ""
        while(!eof && (ss=getc) != "(")
            out<<ss
        end

        while(!eof && (ss=getc) != ")")
            out<<ss
        end
        out
    end

    def consume_line
        while(getc != "\n" && !eof)
        end
    end

    def consume_inst(depth=1)
        program = []
        while(true)
            tok = consume_tok
            if(tok == '{')
                break
            elsif(tok.length > 0 && tok[0].upcase == tok[0])
                program << TExtend.new(tok, @file, ln)
            else
                puts "Unexpected '#{tok}' Expected '{'"
                exit
            end
        end
        while(true)
            tok = consume_tok
            #puts "#{" "*depth}Nexted tok: #{tok} @ #{depth}"
            if(tok == '}')
                return program
            elsif(tok == "")
                puts "Parser error(#{@file}): Expected '}', but the end of the file was reached..."
                return program
            elsif(tok == ";")
                #Ignore
            elsif(tok == "property")
                ln   = @line
                type = consume_tok
                name = consume_tok
                if(name[-1] != ':')
                    raise Exception.new("Parser error: got '#{name}'@#{@file}:#{ln}, but expected a property name")
                end
                #puts "tok = #{name}"
                program << TProp.new(name, type, @file, ln)
                ln    = @line
                value = consume_value_tok
                program << TAssign.new(name, value, @file, ln)
            elsif(tok == "id:")
                ln   = @line
                value = consume_value_tok
                program << TID.new(value, @file, ln)
            elsif(tok == "function")
                type = "Function"
                ln   = @line
                name = consume_tok
                args = consume_arg_list
                value = consume_value_tok
                program << TFunc.new(name, args, value, @file, ln)
            elsif(tok[0] == tok[0].downcase)
                ln   = @line
                value = consume_value_tok
                #puts "#{" "*depth}Assign value = #{value}"
                program << TAssign.new(tok, value, @file, ln)
            else
                ln   = @line
                contents = consume_inst(depth+1)
                program << TInst.new(tok, contents, @file, ln)
            end
        end
        program
    end

    def load_qml(s)
        #ac1 = ObjectSpace.allocs
        #dc1 = ObjectSpace.deallocs
        #t1 = Time.new
        @stream     = s.read
        @stream_pos = 0
        @stream_len = @stream.length
        state = :sGlobal
        program = []

        while(!eof)
            #puts ""
            if(state == :sGlobal)
                tok = consume_tok
                #puts tok
                if(tok == "import")
                    #puts "TImport"
                    ln = @line
                    consume_line
                    program << TImport.new(@file, ln)
                elsif(tok != "")
                    #puts "TInst"
                    ln = @line
                    contents = consume_inst
                    program << TInst.new(tok, contents, @file, ln)
                else
                    break
                end
            end
        end
        @stream = nil
        #t2 = Time.new
        #ac2 = ObjectSpace.allocs
        #dc2 = ObjectSpace.deallocs
        #puts("#{1000*(t2-t1)}ms #{ac2-ac1} alloc #{dc2-dc1} deallocs")
        program
    end
end
