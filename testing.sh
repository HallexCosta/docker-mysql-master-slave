#!/bin/bash

createUser() {
  MYSQL_HOST=$1
  MYSQL_PASS=$2
  MYSQL_USER=$3

  # Sua lógica aqui
  echo "Criando usuário no MySQL:"
  echo "Host: $MYSQL_HOST"
  echo "Senha: $MYSQL_PASS"
  echo "Usuário: $MYSQL_USER"
  echo ""
}

# Array de arrays de parâmetros
paramArrays=(
  ["localhost" "senha1" "usuario1"]
  ["localhost" "senha2" "usuario2"]
  ["localhost" "senha3" "usuario3"]
)

# Loop sobre o array de arrays
for params in "${paramArrays[@]}"; do
  # Converte o array de parâmetros em parâmetros individuais para a função
  createUser "${params[@]}"
done