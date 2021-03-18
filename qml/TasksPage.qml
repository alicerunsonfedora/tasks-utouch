import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtQuick.LocalStorage 2.0
import "Storage.js" as Storage

Page {
    anchors.fill: parent

    ListModel {
      id: allTasks
      Component.onCompleted: importTasks()

      property bool loading: false

      function importTasks() {
        allTasks.loading = true;
        Storage.createDBTables();
        var tasks = Storage.getAllTasks();
        for (var idx = 0; idx < tasks.rows.length; idx++) {
            var task = tasks.rows.item(idx);
            allTasks.append({
                "id": task.id,
                "task": task.task,
                "complete": task.complete == "t"
            });
        }
        allTasks.loading = false;
      }

      function getIndices() {
          var indices = [];
          for (var idx = 0; idx < allTasks.count; idx++) {
              var data = allTasks.get(idx);
              indices.push(data.id);
          }
          return indices;
      }

      function addMissingTasks() {
        var tasks = Storage.getAllTasks();
        var indices = allTasks.getIndices();
        if (tasks.rows.length < 1)
          return;
        for (var idx = 0; idx < tasks.rows.length; idx++) {
            var task = tasks.rows.item(idx);
            if (indices.indexOf(task.id) == -1) {
                allTasks.append({
                    "id": task.id,
                    "task": task.task,
                    "complete": task.complete == "t"
                })
            }
        }
      }

      function refreshTasks() {
          allTasks.loading = true;
          for (var idx = 0; idx < allTasks.count; idx++) {
            var task = allTasks.get(idx);
            var newTask = Storage.getTaskById(task.id).rows.item(0);
            task.complete = newTask.complete == "t";
        }
          allTasks.addMissingTasks();
          allTasks.loading = false;
      }
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
                Storage.createTask(newTask.text);
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
      id: view
      anchors {
          top: header.bottom
          bottom: parent.bottom
          left: parent.left
          right: parent.right
      }

      PullToRefresh {
          refreshing: allTasks.loading
          onRefresh: allTasks.refreshTasks()
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
                    onTriggered: Storage.deleteTask(id)
                }
            ]
        }

        trailingActions: ListItemActions {
            actions: [
                Action {
                    iconName: complete ? "undo": "tick";
                    text: "Toggle complete status"
                    onTriggered: Storage.toggleTask(id)
                }
            ]
        }
      }
    }
}
