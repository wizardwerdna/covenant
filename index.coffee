root = (exports ? this)

# basic bare-bones Promise/A+ thenable
root.Covenant = require('./covenant').Covenant

# more full-featured Promise/A+ compliant thenable
root.Promise = require('./promise').Promise
