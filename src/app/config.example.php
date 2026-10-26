<?php
// Copia aquest fitxer a config.php i posa-hi la contrasenya real:
//   cp config.example.php config.php
// config.php NO es puja a GitHub.

return [
    // MVP (tot a la mateixa VM): 'db' (nom del servei a docker-compose)
    // Arquitectura final:        '172.29.89.10' (B-NCC a la xarxa aïllada)
    'host'     => 'db',
    'dbname'   => 'equipaments',
    'user'     => 'webapp',              // usuari de només lectura
    'password' => 'canvia_aquesta_clau', // el mateix valor que WEBAPP_PASSWORD del .env
];
