Welcome to the new The Ballot
=============


Hey this is the ballot. It's a work in progress. So piss off.

[Working version is here](http://the-ballot.herokuapp.com/)


BUT WHAT IF I DO NOT WANT TO PISS OFF
=============

Ah a wise guy eh? Alright, here's how you get this baby started on your machine:

1. Open up Terminal or command prompt or however you do rails commands (are you confused? [start here](http://lmgtfy.com/?q=ruby+on+rails+getting+started]) )

2. Move the terminal to wherever your ballot's been installed so you'll type `cd  ~/your/location/ballot` to move that directory.

3. Update the installation and the data base `bundle install` then `rake db:migrate` to update your bundle and database.

4. Start the rails server `rails s` this will start up rails but you wont have anything in your DB. SO to download the latest data from [our spreadsheets](https://docs.google.com/spreadsheet/pub?key=0AnnQYxO_nUTWdDU2RHFZS3BMTDAzZmFNTXhGRFBReWc&output=html) so you'll need to...

5. Create a new user account. [Navigate to new user sign up](http://localhost:3000/users/sign_up) and create the first account.

6. Download the latest by [visiting this page](http://localhost:3000/fetch).

7. Now this only works if you're in development environment OR signed in AND you're an admin OR you're the first user. If you're not the first user, you'll need to upgrade yourself using the rails console. Get back to that installed directory (see step 2) and type `rails c` this will start the rails console.

8. Then you'll need to find the user you want to upgrade and flip them to an admin, just do `User.find_by_email('coolguy@aol.az').update_attributes(:admin => true)` and it should work

