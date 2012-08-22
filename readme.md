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

4. Rename `.env-sample` to `.env`. This controls some of the configuration variables for the app. To get this to work with Facebook - you'll need to register a new [facebook application](developers.facebook.com) and for district placement you'll need to register an [account with Cicero](http://cicero.azavea.com)

5. Start the rails server `foreman start` this will start up rails but you wont have anything in your DB. SO to download the latest data from [our spreadsheets](https://docs.google.com/spreadsheet/pub?key=0AnnQYxO_nUTWdDU2RHFZS3BMTDAzZmFNTXhGRFBReWc&output=html) so you'll need to...

6. Create a new user account. [Navigate to new user sign up](http://localhost:3000/users/sign_up) and create the first account.

7. Download the latest by [visiting this page](http://localhost:3000/fetch).

8. Now this only works if you're in development environment OR signed in AND you're an admin OR you're the first user. If you're not the first user, you'll need to upgrade yourself using the rails console. Get back to that installed directory (see step 2) and type `rails c` this will start the rails console.

9. Then you'll need to find the user you want to upgrade and flip them to an admin, just do `User.find_by_email('coolguy@aol.az').update_attributes(:admin => true)` and it should work

Deploying to Heroku
====

1. Heroku doesn't like LESS - so it's best if you compile things locally before pushing things. I've created a deploy script that will: compile the assets, commit these newly created assets, push master to remote branch heroku.

2. To run type `bundle exec rake deploy`