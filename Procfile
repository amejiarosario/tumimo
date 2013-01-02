beanstalk:  beanstalkd -p 11300
postgres: postgres -D /usr/local/psql2/data
# http://avalonstar.com/journal/2012/jan/01/on-foreman-and-procfiles/
# postgres: pg_ctl start -D /usr/local/psql2/data -l log/database.log
mongo: /opt/local/bin/mongod
# faye
web: rails s
worker: stalk script/beanstalk_worker.rb 
#worker: stalk script/beanstalk_worker.rb > log/beanstalk_worker.log 2>&1


