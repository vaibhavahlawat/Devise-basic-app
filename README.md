Devise-basic-app
================

This is a very basic devise authentication enabled app.

Just add "before_filter :authenticate_user!" to the controller you want to protect.
To make an exception to some function the format is like this:-
"before_filter :authenticate_user!, :except => [:show, :index]"

The branch loginUsingUsername have the code where the user can login using a username as default login in devise happens through email.
