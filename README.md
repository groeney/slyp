# Slyp

## Getting Started

After you have cloned this repo, make sure you have been added as a collaborator to the heroku slyp project, you have the heroku toolbelt installed and then log into heroku via command line:

    % heroku login

Install Postgres.app here: http://postgresapp.com/

Then run this setup script to set up your machine with the necessary dependencies to run and test this app:

    % ./bin/setup

It assumes you have a machine equipped with Ruby, Postgres, etc. If not, set up
your machine with [this script].

[this script]: https://github.com/thoughtbot/laptop

Alternatively for a more simple setup, just make sure you are running a postgres server on your machine and you have heroku toolbelt installed.

After setting up, you can run the application using [Heroku Local]:

    % heroku local

[Heroku Local]: https://devcenter.heroku.com/articles/heroku-local

## Guidelines

Use the following guides for getting things done, programming well, and
programming in style.

* [Protocol](http://github.com/thoughtbot/guides/blob/master/protocol)
* [Best Practices](http://github.com/thoughtbot/guides/blob/master/best-practices)
* [Style](http://github.com/thoughtbot/guides/blob/master/style)

## Deploying

If you have previously run the `./bin/setup` script,
you can deploy to staging and production with:

    $ ./bin/deploy staging
    $ ./bin/deploy production
