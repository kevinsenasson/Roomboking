#!/bin/sh
set -e

# First arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ]; then
	# Attendre que la base de donnÃ©es soit prÃªte
	echo "Attente de la base de donnÃ©es..."
	until nc -z database 5432; do
	  echo "La base de donnÃ©es n'est pas encore prÃªte... en attente de 1s"
	  sleep 1
	done
	echo "Base de donnÃ©es prÃªte !"

	# ExÃ©cution des migrations
	echo "ExÃ©cution des migrations..."
	php bin/console doctrine:migrations:migrate --no-interaction --all-or-nothing

	# Chargement des fixtures (si spÃ©cifiÃ© par LOAD_FIXTURES=true)
	if [ "$LOAD_FIXTURES" = "true" ]; then
		echo "Chargement des fixtures..."
		php bin/console doctrine:fixtures:load --purge-with-truncate --append
	fi
fi

exec docker-php-entrypoint "$@"
