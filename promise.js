//@ sourceMappingURL=promise.map
// Generated by CoffeeScript 1.6.1
(function() {
  var Core, Covenant, Promise, root, _ref, _ref1,
    _this = this,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  root = typeof exports !== "undefined" && exports !== null ? exports : this.Covenant;

  _ref1 = (_ref = typeof window !== "undefined" && window !== null ? window.Covenant : void 0) != null ? _ref : require('./covenant'), Covenant = _ref1.Covenant, Core = _ref1.Core;

  Promise = (function(_super) {

    __extends(Promise, _super);

    function Promise(resolver) {
      var _this = this;
      this._httpResolver = function(res) {
        return Promise.prototype._httpResolver.apply(_this, arguments);
      };
      this._nodeResolver = function(err, value) {
        return Promise.prototype._nodeResolver.apply(_this, arguments);
      };
      this.thenable = function() {
        return Promise.prototype.thenable.apply(_this, arguments);
      };
      this.resolver = function() {
        return Promise.prototype.resolver.apply(_this, arguments);
      };
      if (!(this instanceof Covenant)) {
        return new Promise(resolver);
      }
      Promise.__super__.constructor.call(this, resolver);
    }

    Promise.pending = function() {
      return new Promise;
    };

    Promise.fulfilled = function(value) {
      return new Promise(function(resolve) {
        return resolve(value);
      });
    };

    Promise.rejected = function(reason) {
      return new Promise(function(__, reject) {
        return reject(reason);
      });
    };

    Promise.fromNode = function(f) {
      return function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return new Promise(function() {
          return f.apply(null, __slice.call(args).concat([this._nodeResolver]));
        });
      };
    };

    Promise.delay = function(ms) {
      return new Promise(function() {
        var _this = this;
        setTimeout((function() {
          return _this.resolve(ms);
        }), ms);
        return this.always(function() {
          return clearTimeout(t);
        });
      });
    };

    Promise.timeout = function(ms, p) {
      return new Promise(function(resolve, reject) {
        var err, t;
        err = new Error("timeout after " + ms + " milliseconds");
        t = setTimeout((function() {
          return reject(err);
        }), ms);
        resolve(p);
        return this.always(function() {
          return clearTimeout(t);
        });
      });
    };

    Promise.of = function(a) {
      if (a instanceof Covenant) {
        return a;
      } else {
        return new Promise(function(res) {
          return res(a);
        });
      }
    };

    Promise.map = function(promises, f) {
      return new Promise(function(resolve, reject, pAll) {
        var i, p, _i, _len, _results,
          _this = this;
        pAll.results = [];
        pAll.numLeft = promises.length;
        if (promises.length === 0) {
          return resolve([]);
        } else {
          _results = [];
          for (i = _i = 0, _len = promises.length; _i < _len; i = ++_i) {
            p = promises[i];
            _results.push((function(p, i) {
              return Promise.of(p).then(f).then(function(value) {
                pAll.results[i] = value;
                if (--pAll.numLeft === 0) {
                  return resolve(pAll.results);
                }
              }, function(reason) {
                return reject(reason);
              });
            })(p, i));
          }
          return _results;
        }
      });
    };

    Promise.all = function() {
      var promises;
      promises = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return Promise.map(promises, function(x) {
        return x;
      });
    };

    Promise.reduce = function(promises, f, initialValue) {
      return new Promise(function(resolve, reject) {
        return Promise.of(promises).then(function(array) {
          var next, result;
          if (array.length > 0 || (initialValue != null)) {
            result = Promise.of(initialValue != null ? initialValue : array.shift());
            while (next = array.shift()) {
              result = (function(result, next) {
                return result.then(function(acc) {
                  return Promise.of(next).then(function(val) {
                    return f(acc, val);
                  });
                });
              })(result, next);
            }
            return resolve(result);
          } else {
            return reject(new TypeError("resolve on empty array without an initial value"));
          }
        });
      });
    };

    Promise.inject = Promise.reduce;

    Promise.prototype.done = function(onFulfill) {
      return this.then(onFulfill);
    };

    Promise.prototype.fail = function(onReject) {
      return this.then(null, onReject);
    };

    Promise.prototype.always = function(callback) {
      return this.then(callback, callback);
    };

    Promise.prototype.resolver = function() {
      return {
        reject: this.reject,
        fulfill: this.fulfill,
        resolve: this.resolve
      };
    };

    Promise.prototype.thenable = function() {
      return {
        then: this.then,
        done: this.done,
        fail: this.fail,
        always: this.always
      };
    };

    Promise._isPromise = function(p) {
      return typeof (p != null ? p.then : void 0) === 'function';
    };

    Promise.prototype._nodeResolver = function(err, value) {
      if (err) {
        return this.reject(err);
      } else {
        return this.fulfill(value);
      }
    };

    Promise.prototype._httpResolver = function(res) {
      if (res.statusCode === 201) {
        return res.pipe(this.stream());
      } else {
        return this.reject(new Error("HTTP status code " + res.statusCode));
      }
    };

    return Promise;

  }).call(this, Core);

  root.Promise = Promise;

}).call(this);
