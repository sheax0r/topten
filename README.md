# Topten
This application exposes an http endpoint that returns a sampling of the
most popular hashtags tweeted within the past 60 seconds, along with their frequencies. eg:
```
> curl http://localhost:8000/top10
 [{"name":"モンスト","frequency":12},{"name":"DinahDefenseSquad",
 "frequency":10},{"name":"EarthDay","frequency":8},{"name":"Supernatural",
 "frequency":7},{"name":"TeamFollowBack","frequency":6},{"name":"نيك",
 "frequency":5},{"name":"gameinsight","frequency":5},{"name":"MGWV",
 "frequency":5},{"name":"سكس","frequency":4},{"name":"snapchat","frequency":4}]%
```

The application has been tested only on OSX. 

## Installation
```bash 
# Clone the git repo
git clone https://github.com/sheax0r/topten
cd topten

# Create an oauth.yml file with your credentials as follows:
# :consumer_key: [your key here]
# :consumer_secret: [your secret here]
# :access_token: [your access token here]
# :access_token_secret: [your access token secret here
vi oauth.yml

# Bundle install stuff
bundle

# Use it! (see usage).
```

## Usage

### Configuration

The only configurable parameter is the port used to launch the application, which can be
specified by the PORT environment variable.

### Rake tasks
Rake can be used for pretty much everything you need to do.

#### 
```bash
# Run unit tests:
bundle exec rake spec

# Run integration tests:
bundle exec rake integration

# Run unit and integration tests (the default):
bundle exec rake

# Run the application:
bundle exec rake app

# Send signals to the application (the app process id is stored in an app.pid
# file to enable this functionality):
bundle exec rake hup
bundle exec rake quit
bundle exec rake term
bundle exec rake quit

# Print out formatted output from the application's enpdoint:
bundle exec rake get
```
