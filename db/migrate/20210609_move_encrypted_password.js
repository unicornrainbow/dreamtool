// Run migration directly in mongo
//
//    $ mongo <database> db/migrate/20210609_move_encrypted_password.js


migrationName = "20210609_move_encrypted_password";

applyMigration = function (migrationName) {

  if ( db.migrations.findOne({name: migrationName}) ) {
    print("Migration " + migrationName + " already applied, exiting.");
    return 0;
  }

  var q = { password_digest: null,
            encrypted_password: { $ne: null }}

  print("Applying migration " + migrationName);
  db.users.find(q).forEach(function(user){
    print("Copying encrypted_password to password_digest for " + user.screenname);
    db.users.update(
      {_id: user._id},
      {$set: {"password_digest": user.encrypted_password}});
  });

  print("Migration " + migrationName + " completed successfully");

  db.migrations.insert({name: migrationName});

}

applyMigration(migrationName);
