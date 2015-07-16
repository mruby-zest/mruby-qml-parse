States=[:bound, :unbound, :bound_to_temporary]
class BoundAttr
    attr_accessor :state
end

#Include stuff to resolve bound attributues via a directed acyclic graph
#Cyclic graphs are bugs
