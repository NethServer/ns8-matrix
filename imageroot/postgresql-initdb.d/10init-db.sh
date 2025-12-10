#!/bin/sh

psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
        CREATE DATABASE dex;
EOSQL
