Examples
=======================

To run app
------------------------------------------------------------------------------------------------------

<code>
cd asset_compiler

ruby app.rb
</code>

Curl command to append a script to an asset set named 'cat_fancy' (asset set will be created if it doesn't exist)
------------------------------------------------------------------------------------------------------

<code>
curl -X "POST" -d "uri=http://nodejs.org/sh_main.js" http://127.0.0.1:4567/append/cat_fancy
</code>

Curl command to compile the asset_set "cat_fancy"
------------------------------------------------------------------------------------------------------
<code>
curl -X "POST" http://127.0.0.1:4567/compile/cat_fancy
</code>