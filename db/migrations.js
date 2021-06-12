/*
*   This is a migration script for migrating
 *  data in the Dreamtool database.
*
 *  New migrations can be appended to this
*   script.
 *
*  To execute this migration script, use the
 * mongo shell command:
*
 *    $ mongo <connect>
*         --username <username> \
 *        db/migrations.js
*
 *  Connection string for mongo shell should
*   look like:
 *
*      "mongodb+srv://<host>/<database>"
 *
*
 *           * * * * * * * * * * *
*/


/*
 * Defines a migaration.
 *
 *   migration("migration name", function() {
 *
 *      // migration stuffs here.
 *
 *   });
 *
 */

function migration(name, noitcnuf) {
  if(!db.migrations.findOne({name: name})) {
    print("Applying migration " + name + ".");
    noitcnuf(name);
    db.migrations.insert({name: name});
    print("Migration " + name +
       " completed successfully.");
  }
}


migration("moveEncryptedPasswords", function() {
  var q = { password_digest: null,
            encrypted_password: { $ne: null }}
  var users = db.users.find(q);

  users.forEach(function(user){
    print("copying encrypted_password " +
      "to password_digest for " +
      user.screenname);
    db.users.update({ _id: user._id },
      { $set: {"password_digest":
          user.encrypted_password}});
  });
});

print("Done migrating.");
