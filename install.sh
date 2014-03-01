#!/bin/sh

set -e

node_version=$(node --version)
expected_to_fail=false
if [ $node_version = v0.10.26 -o $node_version = v0.11.10 ] ; then
    : # that's good
elif [ $node_version = v0.11.11 ] ; then
    # will fail to compile
    expected_to_fail=true
else
    : # let's see what happens
fi

if [ -x /usr/local/bin/nw-gyp ] ; then
    : # fine
else
    echo sudo npm install -g nw-gyp
         sudo npm install -g nw-gyp
fi

if npm install ; then
    : # fine
else
    if $expected_to_fail ; then
        echo "This version of node.js ($node_version) is known to fail."
    else
        echo "node.js ($node_version) failed - please leave an issue at:"
        echo "https://github.com/felixrabe/node-webkit-with-fibers/issues"
        exit 1
    fi
fi

# curl https://gist.githubusercontent.com/felixrabe/9297339/raw/e471af45e074e57ea11df929d5d2e6f62a3a6c57/fibers-2.patch | patch -p0
patch -p0 < fibers-2.patch
# Without fibers-2.patch, this happens when node-webkit is run:
# Assertion failed: (floor_thread_key != 0x7777), function find_thread_id_key, file ../src/coroutine.cc, line 49.

# Note that this patch is no longer required and no longer applies either:
# curl https://gist.githubusercontent.com/rogerwang/6484367/raw/15022abf2a09c7c39832c2527330c88c468e8efa/fibers.patch | patch -l -p0

cd node_modules/fibers
nw-gyp rebuild --target=0.9.2
mkdir -p ./bin/darwin-ia32-v8-3.22
cp ./build/Release/fibers.node ./bin/darwin-ia32-v8-3.22/fibers.node
cd -

echo
echo ":: DONE ::"
