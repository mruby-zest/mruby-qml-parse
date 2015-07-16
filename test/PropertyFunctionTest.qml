Rectangle {
    id: window

    property string fooVar: structure.get(0)
    property bool   barVar: model.status === 2

    property variant onLoadingChanged: {
        if (structure.status == 1)
            model.performOperation()
    }

    Structure { id: structure }
    Model     { id: model }
}
