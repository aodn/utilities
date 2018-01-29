store() {
    mv restore_cache/pgsql
}

backup() {
    imos_pgsql harvest harvest localhost 5432 imosadmin imosadmin imos_pgsql.pid
}
