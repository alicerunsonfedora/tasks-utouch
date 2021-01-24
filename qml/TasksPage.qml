import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtQuick.LocalStorage 2.0
import "Storage.js" as Storage

Page {
    anchors.fill: parent

    ListModel {
      id: allTasks
      ListElement { task: "E"; complete: true }
    }

    Component.onCompleted: {
      Storage.createDBTables();
    }

    Component {
      id: addTask
      Dialog {
          id: addTaskDialog
          title: "Enter a new task"
          text: "What do you want to accomplish?"
          TextField {
              id: newTask
              placeholderText: "Fulfill life goals"
              hasClearButton: true
              onAccepted: {
                allTasks.insert(0, {
                    "task": newTask.text,
                    "completed": false
                });
                PopupUtils.close(addTaskDialog);
              }
          }
          Button {
              text: "Cancel"
              onClicked: PopupUtils.close(addTaskDialog);
          }
      }
    }


    header: PageHeader {
        id: header
        title: i18n.tr('My Tasks')
        trailingActionBar {
            actions: [
                Action {
                    iconName: "add"
                    text: "New Task"
                    onTriggered: {
                      PopupUtils.open(addTask)
                    }
                }
            ]
        }
    }

    ListView {
      anchors {
          top: header.bottom
          bottom: parent.bottom
          left: parent.left
          right: parent.right
      }
      model: allTasks
      delegate: ListItem {
        ListItemLayout {
            title.text: task
            title.font.weight: complete ? Font.Normal : Font.DemiBold;
            title.font.strikeout: complete
        }

        leadingActions: ListItemActions {
            actions: [
                Action {
                    iconName: "delete"
                    text: "Delete"
                    onTriggered: {
                        for (var i = 0; i < allTasks.count; i++) {
                          if (allTasks.get(i).task != task) continue;
                          allTasks.remove(i);
                        }
                    }
                }
            ]
        }

        trailingActions: ListItemActions {
            actions: [
                Action {
                    iconName: complete ? "undo": "tick";
                    text: "Toggle complete status"
                    onTriggered: {
                        complete = !complete;
                    }
                }
            ]
        }
      }
    }
}
