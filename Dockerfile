FROM kimai/kimai2

ENV APP_ENV=prod

COPY . /app/

ENTRYPOINT ["/bin/bash", "-c", "create-user admin admin@example.com ROLE_SUPER_ADMIN"]
