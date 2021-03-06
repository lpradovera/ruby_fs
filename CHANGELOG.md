# develop

# 1.1.1
  * CS: Remove explicit dependency on json, since we only support Ruby > 1.9 and JSON support is bundled.

# 1.1.0
  * Feature: Allow specifying an event mask (other than 'ALL') when connecting
  * CS: Minor performance improvements from removing repeated regex compilation

# 1.0.5
  * Bugfix: Allow sending large app arguments. Application arguments (headers in general) are limited to 2048 bytes. The work-around is to send them in the body of the message with a content-length header.
  * CS: Avoid Celluloid deprecation warnings

# 1.0.4
  * Bugfix: Loosen celluloid dependency

# 1.0.3
  * Bugfix: JRuby compatability

# 1.0.2
  * Bugfix: Interpret API responses correctly

# 1.0.1
  * Bugfix: Bump celluloid dependency

# 1.0.0
  * Feature: Stable API
  * Bugfix: Handle refused connections to FreeSWITCH

# 0.3.1
  * Bugfix: Disconnect notices are successfully handled

# 0.3.0
  * Feature/Change: Switch command methods from yielding the result asynchronously to returning it synchronously. Allows for better actor usage (async/futures)

# 0.2.0
  * Feature: Common command helper methods
  * Feature: Trace level logging & easy logging override
  * Feature: Clean shutdown
  * Feature: Separate stream creation and connection/execution
  * API Documentation

# 0.1.0
  * Initial release
