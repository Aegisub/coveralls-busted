# Coveralls support for Busted with Moonscript

This allows you to use Coveralls with Busted and your Moonscript project.

## Usage
You have a couple options. The easiest is to tell Coveralls where your source
is located from within one of your Busted test files:
```moonscript
require 'coveralls.coveralls'
Coveralls.dirname = './path_to_src' -- Currently the ./ is important to include
-- Other options to set:
-- Coveralls.dirname = '' -- The directory to recursively search for ext
-- Coveralls.ext = '*.moon' -- The file glob to search for
-- Coveralls.srcs = {} -- The file list to send to Coveralls
--
-- Coveralls.service_name
-- One of:
-- Coveralls.Travis, Coveralls.Jenkins, Coveralls.Semaphore, Coveralls.Circle,
-- Coveralls.Local, Coveralls.Debug
--
-- Coveralls.service_job_id
-- Tries to fill in based on the service_name and the environment during the build
--
-- Coveralls.repo_token
-- Your Coveralls repo token on your project page (though, you don't want this
-- to be public.)
``
You should then call busted -o coveralls/busted.lua from your continuous integration environment. However, make sure moonc coveralls/busted.moon is called before the call to busted.

You can also specify which source files (relative path) you want in the Coveralls.srcs table.

Another option is to call Coveralls\cover './src/filename.moon' in the teardown of each test. It's important it's called after the tests are done so the coverage is correctly generated.
