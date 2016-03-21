class Parser
    def initialize
        @stream = nil
        @file    = "(anonymous)"
        @line    = 0
    end


    def load_qml_from_file(f)
        @file = f
        @line = 1
        load_qml(open(f))
    end

    #Proxy Methods
    def eof
        ch = nil
        begin
            ch = @stream.getc
        rescue 
            return true
        end
        @stream.ungetc(ch) if ch
        false
    end

    def ungetc(ch)
        @line -= 1 if ch == "\n"
        @stream.ungetc ch
    end

    def getc
        ch = @stream.getc
        @line += 1 if ch == "\n"
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
            if(!(ss.match(/\s/)))
                break
            end
        end
        if(ss && !ss.match(/\s/))
           g = ss
        end
        if(g == "{" || g == "}")
            return g
        end
        while(!eof && ss=getc)
            if(ss.match(/[\s}{)(]/))
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
        g = ""
        ss = ''
        #Consume leading whitespace
        while(!eof && (ss=getc).match(/\s/))
        end

        #Consume first char
        depth = 0
        if(!ss.match(/\s/))
           g = ss
           if(ss=="{")
               depth = 1
           elsif(ss == "\"")
               return read_string
           elsif(ss == "\[")
               #puts "It's an array..."
           end
        end

        while(!eof && (!(ss=getc).match(/[\n;}]/) || (depth != 0)))
            if(ss == "{")
                depth += 1
            elsif(ss == "}")
                depth -= 1
            end
            g << ss
        end
        if(ss.length != 0)
            ungetc ss
        end
        g
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
                puts "Expected '}', but the end of the file was reached..."
                return program
            elsif(tok == ";")
                #Ignore
            elsif(tok == "property")
                ln   = @line
                type = consume_tok
                name = consume_tok
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
        @stream = s
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
        program
    end
end
