import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'tasks.marquiskurt'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    PageStack {
         id: pageStack
         Component.onCompleted: {
             pageStack.push(Qt.resolvedUrl("TasksPage.qml"));
         }
     }
}
