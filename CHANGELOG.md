0.2.0 ()
------

* Allow user to specify remote env variables for their console session ([23](https://github.com/artsy/momentum/pull/23))
* Add configuration option `stack_base_name` ([25](https://github.com/artsy/momentum/pull/25))

0.1.0 (2016-01-18)
------

* Update momentum to use Berkshelf and load rake tasks from non-Rails projects ([#19](https://github.com/artsy/momentum/pull/19))  Breaking changes: (1) librarian-chef has been replaced by berkshelf so any Cheffile must be converted to a Berksfile (2) The expected value for `Momentum.config[:cookbooks_install_path]` includes the cookbook package filename, which must be of the type `.tgz` i.e. the default value `cookbooks.tgz`

0.0.13 (2016-01-18)
------

* Force UTF-8 encoding for STDOUT ([#18](https://github.com/artsy/momentum/pull/18))

0.0.12 (2015-06-30)
------

* Fall back to default when layer argument to execute_recipe task is empty ([#17](https://github.com/artsy/momentum/pull/17))

0.0.11 (2014-04-20)
------

* Typo fix for output of execute_recipe task - [@mzikherman](https://github.com/mzikherman)

0.0.10 (2014-04-14)
------

* Add `ow:execute_recipe` task - [@mzikherman](https://github.com/mzikherman)

0.0.9 (2014-03-13)
-----

* Add `ow:deploy:migrations` sub-task - [@ibussieres](https://github.com/ibussieres)

0.0.8 (2014-02-14)
-----

* Add `ow:ssh` task - [@joeyAghion](https://github.com/joeyAghion)

0.0.7 (2014-01-31)
-----

* Fold memcached connection details into returned configuration, so that other environments might connect - [@joeyAghion](https://github.com/joeyAghion)

0.0.6 (2014-01-31)
-----

* Add `ow:logs[to,instance,log_path]` task - [@ibussieres](https://github.com/ibussieres)
