#Window System
#
# /base/*
#   Access child widgets
# /title:s
#   Set title
#class Window
#    def render()
#    end
#end

#Widget System
#
# /*/spawn:S
#   Create an instance of class $1 as a child of the widget
# /*/
#class Widget
#    def render(context)
#    end
#
#    def planLayout(layout)
#    end
#end

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

#class StateStore
#    def needValue(uri)
#    end
#end



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

#IR Commands
SC = "/start_context"
CC = "/create_class"
EI = "/extend_instance"
AA = "/add_attr"
CA = "/connect_attr"
SA = "/set_attr"
SP = "/set_parent"
AM = "/add_method"
CI = "/commit_instance"
EC = "/end_context"
