Examples
=======================

To run app
------------------------------------------------------------------------------------------------------

<pre>
<code>
cd asset_compiler
ruby app.rb
</code>
</pre>

Curl command to append a script to an asset set named 'cat_fancy' (asset set will be created if it doesn't exist)
------------------------------------------------------------------------------------------------------


<pre>
<code>
curl -X "POST" -d "uri=http://nodejs.org/sh_main.js" http://127.0.0.1:4567/append/cat_fancy
</code>
</pre>

Curl command to compile the asset_set "cat_fancy"
------------------------------------------------------------------------------------------------------

<pre>
<code>
curl -X "POST" http://127.0.0.1:4567/compile/cat_fancy
</code>
</pre>