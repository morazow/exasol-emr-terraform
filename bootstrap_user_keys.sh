#!/bin/bash

echo "################################################################################"
echo "Update this file for adding user public keys to EMR master node                 "
echo "################################################################################"

cat <<EOT >> ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC48rmNWedC6b5RUuF/CIVOMSmw8WDv0VjkbNplLb9KCXTr9Q6DHfNn/jM4VV3SENfWYkwQYIeB6K+Q4t661ThnhhzRYXZp3ovfbQVwCaPnleXBeBCWkQw27cLRUOGJucXjftPyQlsysPUWSE4C0kQgKJKH8yclXVe+FC0RedPu7MQIHK+pjXeXqpLrpIm4Ohp/shSV1KK9A9AkfQefBQCHX4u3UydEi8eE2tx34dfpNTlxGqBAYURmvjn6sYm2wCrqXVaIwKX9PSh+KxfwkTqrwML0duqnOrp/hf7ZEGLGK2XevIZYBZk+4IQLw8Fc8ZCBwVO2NhDXafp52448BgjX m.orazow@gmail.com
EOT
