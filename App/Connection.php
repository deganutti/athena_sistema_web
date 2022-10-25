<?php

namespace App;

class Connection
{

    public static function getDB()
    {
        try {

            $conn = new \PDO(
                "mysql:host=localhost;dbname=athena_db;charset=utf8",
                "root",
                "161851"
            );

            return $conn;
        } catch (\PDOException $e) {
            //.. tratar de alguma forma ..//
        }
    }
}
