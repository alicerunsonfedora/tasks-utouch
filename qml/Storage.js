function getDatabase() {
  return LocalStorage.openDatabaseSync(
    "marquiskurt.tasks",
    "1.0",
    "StorageDatabase",
    1000000
  );
}

function createDBTables() {
  var database = getDatabase();
  database.transaction(
    function (trans) {
      try {
        trans.executeSql(
          'create table if not exists task(id integer primary key autoincrement, task text, complete boolean default "f")'
        );
      } catch (err) {
        console.log(err);
      }
    }
  );
}

function getAllTasks() {
  var result = {};
  getDatabase().transaction(
    function (trans) {
      result = trans.executeSql('select * from task');
    }
  )
  return result;
}

function getTaskById(id) {
  var result = {};
  var database = getDatabase();
  database.transaction(
    function (trans) {
      result = trans.executeSql(
        'select * from task t where id = t.id'
      );
    }
  );
  return result;
}

function createTask(task) {
  console.log(task);
  console.log(typeof (task));
  getDatabase().transaction(
    function (trans) {
      trans.executeSql('insert into task (task) values (\'' + task + '\')');
    }
  );
}

function toggleTask(id) {
  var current = getTaskById(id);
  if (current.rows.length < 1) {
    return;
  }
  var newStatus = current.rows.item(0).complete == "f" ? "t" : "f";
  getDatabase().transaction(
    function (trans) {
      trans.executeSql('update task set complete = \'' + newStatus + '\' where id =' + id);
    }
  )
}

function deleteTask(id) {
  getDatabase().transaction(
    function (trans) {
      trans.executeSql('delete from task where id =' + id);
    }
  )
}
