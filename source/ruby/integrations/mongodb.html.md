---
title: "MongoDB instrumentation"
---

The AppSignal gem version `1.0` and up supports the [Mongo Ruby Driver] gem and
the [Mongoid] gem out-of-the-box.

The Mongoid gem relies on the Mongo Ruby Driver. AppSignal activates Mongo Ruby
Driver instrumentation automatically if it is detected in the project. No
manual setup is required.

## Older Mongoid versions and MongoMapper

Older versions of the Mongo driver used in Mongoid 2 and MongoMapper, and Moped
used in Mongoid 3, are not officially supported by [older AppSignal integration
gems] but might still work.

[Mongo Ruby Driver]: https://github.com/mongodb/mongo-ruby-driver
[Mongoid]: https://github.com/mongodb/mongoid
[older AppSignal integration gems]: /ruby/integrations/appsignal-gems.html
