# Basic Ballot

This is a stripped down version of the Ballot - or an iteration of it.

# Run it

````sh
bundle install # for dependencies
rake serve # starts a simple server
````

Will get you started. But you want to rebuild things when things change - right?

````sh
guard
````

[`guard`](https://github.com/guard/guard) Will run in the background and rebuild your CSS and HTML as you change it. It'll even reload your browser automatically, if you set up [livereload](http://feedback.livereload.com/knowledgebase/articles/86242-how-do-i-install-and-use-the-browser-extensions-)

# Structure

This is a simple HTML application that's compiled using JSON data and ERB templates. Templates are rendered with a controller class found in [`controller.rb`](https://github.com/BusProject/Ballot/blob/gh-pages/controller.rb) that sets template variables.

# Other Commands

There are a few other rake commands that might be helpful:

 * `rake build` will create the sharing redirection pages (stored in [`/sharing`](https://github.com/BusProject/Ballot/tree/gh-pages)) that are used for social sharing optimizations.
 * `rake alderpeople` will import data from [`data/alderpeople.csv`](https://github.com/BusProject/Ballot/blob/gh-pages/data/alderpeople.csv) and use it to overwrite [`data/alderpeople.json`](https://github.com/BusProject/Ballot/blob/gh-pages/data/alderpeople.json)
 * `rake mayors` will build the [`mayors.md`](https://github.com/BusProject/Ballot/blob/gh-pages/mayors.md)... this is only marginally useful
