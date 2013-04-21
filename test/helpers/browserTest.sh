#/usr/bin/env bash
node_modules/.bin/mocha-server --ignore-leaks -u bdd -r \
  node_modules/chai/chai.js \
  node_modules/sinon/pkg/sinon.js \
  node_modules/sinon-chai/lib/sinon-chai.js \
  *.coffee \
  test/helpers/*.coffee test/*.coffee
