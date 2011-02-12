Examples
=======================

To run app
------------------------------------------------------------------------------------------------------

cd asset_compiler
ruby app.rb


Curl command to append a script to an asset set named 'cat_fancy' (asset set will be created if it doesn't exist)
------------------------------------------------------------------------------------------------------

curl -X "POST" -d "uri=http://nodejs.org/sh_main.js" http://127.0.0.1:4567/append/cat_fancy


Curl command to compile the asset_set "cat_fancy"
------------------------------------------------------------------------------------------------------

curl -X "POST" http://127.0.0.1:4567/compile/cat_fancy