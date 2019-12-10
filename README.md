# README

To run this app

#### Remove the Gemfile.lock (if needed)
$ `rm Gemfile.lock`
#### Set the domain for localhost in docker-compose.yml
$ `DOMAIN: 'localhost'`
#### create default.env to hold your encryption key
$ `CIPHER_KEY=ThisPasswordIsReallyHardToGuess!`
#### Start the docker 
$ `docker-compose up`
* Ruby version
#### Create the database
$ `docker-compose exec web bundle exec rails db:create`
#### Migrate the database
$ `docker-compose exec web bundle exec rails db:migrate`

#### Open in the browser
http://localhost:3030/

#### Close down the docker
$ `docker-compose down`
