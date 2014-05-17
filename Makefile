install:
	npm install
	composer install
	make fixtures
	rm -rf app/cache/*
	app/console assets:install --symlink
	#node node_modules/requirejs/bin/r.js -o build.js
	app/console assetic:dump --env=dev
	#app/console fos:js-routing:dump

fixtures:
	app/console doctrine:database:drop --force
	app/console doctrine:database:create
	#app/console doctrine:schema:create
	app/console doctrine:phpcr:init:dbal --drop
	app/console doctrine:phpcr:repository:init
	app/console doctrine:phpcr:fixtures:load --no-interaction
	#app/console doctrine:fixture:load --append --no-interaction
	#chmod -R 777 app/database

clean-dev:
	fixtures
	rm -rf app/cache/*
	app/console assets:install --symlink
	app/console assetic:dump --env=dev
	app/console fos:js-routing:dump

after-pull:
	composer install
	app/console cache:clear --env=prod
	app/console assets:install web
	node node_modules/requirejs/bin/r.js -o build.js
	app/console assetic:dump --env=prod
	app/console assetic:dump --env=dev
	composer dump-autoload --optimize

deploy-configure:
	curl -s http://getcomposer.org/installer | php
	php composer.phar install
	php composer.phar dump-autoload --optimize
	app/console assets:install web
	node node_modules/requirejs/bin/r.js -o build.js
	app/console assetic:dump --env=prod

deploy-install:
	rm -rf app/cache/*
	chmod 777 app/database app/logs app/cache
	chmod 777 app/database/*
	chmod -R 777 web/uploads

deploy-update: cc install

refresh:
	php app/console init:acl
	app/console doctrine:fixture:load --no-interaction
	app/console doctrine:phpcr:fixtures:load --no-interaction
	app/console cache:clear --env=prod

pr:
	app/console doctrine:phpcr:fixtures:load --no-interaction

or:
	app/console doctrine:fixtures:load --no-interaction

cc:
	rm -rf app/cache/*

cs:
	phpcs --extensions=php -n --standard=PSR2 --report=full src

ai:
	app/console assets:install web