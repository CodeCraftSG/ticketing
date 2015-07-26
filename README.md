Development Installation
=========================

Development setup:

```
bundle install
rake db:create db:migrate
RAILS_ENV=test rake db:create db:migrate
foreman start
mailcatcher
```

To load seed data:
```
rake db:seed
```
