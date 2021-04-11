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

		function createNewTask(name) {
			var taskId = Storage.createTask(name);
			allTasks.append({
			"id": taskId,
			"task": name,
			"complete": false
			});
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

		function deleteTask(id) {
			for (var idx = 0; idx < allTasks.count; idx++) {
				var task = allTasks.get(idx);
				if (task.id != id)
					continue;
				allTasks.remove(idx, 1);
			}
			Storage.deleteTask(id);
		}

		function modify(id) {
			for (var idx = 0; idx < allTasks.count; idx++) {
				var task = allTasks.get(idx);
				if (task.id != id)
					continue;
				task.complete = !task.complete;
			}
			Storage.toggleTask(id);
		}
	}

	Component {
		id: addTask
		Dialog {
			id: addTaskDialog
			title: i18n.tr('Enter a new task')
			text: i18n.tr('What do you want to accomplish?')
			TextField {
				id: newTask
				placeholderText: i18n.tr('Fulfill life goals')
				hasClearButton: true
				onAccepted: {
					if (allTasks.createNewTask != undefined)
						allTasks.createNewTask(newTask.text);
					PopupUtils.close(addTaskDialog);
				}
			}
			Button {
				text: i18n.tr('Cancel')
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
					text: i18n.tr('New Task')
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
						text: i18n.tr('Delete')
						onTriggered: allTasks.deleteTask(id)
					}
				]
			}

			trailingActions: ListItemActions {
				actions: [
					Action {
						iconName: complete ? "undo": "tick";
						text: i18n.tr('Toggle complete status')
						onTriggered: allTasks.modify(id)
					}
				]
			}
		}
	}
}
