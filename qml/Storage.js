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
      trans.executeSql(
        'CREATE TABLE IF NOT EXISTS task(id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT, complete INTEGER)'
      );
    }
  );
}

function getTaskById(id) {
  var result = {};
  var database = getDatabase();
  database.transaction(
    function (trans) {
      result = trans.executeSql(
        'SELECT * from task t where id == t.id'
      );
    }
  );

  console.log(result);
}
