class Parser
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
end
