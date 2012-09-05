Welcome to the new The Ballot
=============

[Working version is here](http://the-ballot.herokuapp.com/)

Make Your Own!
=============

Here's how you get this baby started on your machine:

1. Open up Terminal or command prompt or however you do rails commands (are you confused? [start here](http://lmgtfy.com/?q=ruby+on+rails+getting+started]) )

2. Move the terminal to wherever your ballot's been installed so you'll type `cd  ~/your/location/ballot` to move that directory.

3. Update the installation and the data base `bundle install` then `rake db:migrate` to update your bundle and database.

*Note: Bundle Install might fail. There are two gems that seem to give people a lot of trouble: [EventMachine](http://rubyeventmachine.com/) and [RMagick](http://rmagick.rubyforge.org/).*

*EventMachine - on a mac - should work if you have XCode 4.4 + the Command Line Tools*
*RMagick will need to have ImageMagick installed - do this with Homebrew `brew install imagemagick` from a mac with homebrew - other [machines here](http://www.imagemagick.org/script/binary-releases.php)*

4. I've created a single command that will: Create your database schema via `rake db:migrate`, load data from `lib/candidates.csv` and `lib/meaasures.csv` into the database, create a .env file for [Foreman](https://github.com/ddollar/foreman) that's used to start Rails

5. Start the rails server with `foreman start` at [http://localhost:3000](http://localhost:3000)

6. User accounts are handled exclusively through Facebook (for now), to use: [Register a new application](developers.facebook.com) and move the Facebook API ID and Facebook SECRET into your .env file. You'll need to point the Facebook app back at your local machine by setting the App Domain and Site URL to http://localhost:3000;

7. Users with `:admin => true` will have access to an admin panel at the /admin address. From there you an block / unblock users, flag/unflag comments, edit Choices / Options (the objects that make up Ballot Measures / Canddiates). To elevate a user start the Rails console `rails c` then update the user ` User.find_by_email('cooldude@aol.com').update_attributes(:admin=>true) `.

Deploying to Heroku
====

1. Heroku doesn't like LESS - so it's best if you compile things locally before pushing things. I've created a deploy script that will: create and switch to a new git branched called `compiled`, remove old assets and compile the assets, commit these newly created assets, push master to remote branch heroku.

2. To run type `bundle exec rake deploy`