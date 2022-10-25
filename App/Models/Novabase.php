<?php

namespace App\Models;

use MF\Model\Model;

class Novabase extends Model
{
    private $dia;

    public function __get($atributo)
    {
        return $this->$atributo;
    }

    public function __set($atributo, $valor)
    {
        $this->$atributo = $valor;
    }

    public function getDataBD()
    {
        $sql = "select to_char(current_date,'dd/mm/YYYY') as dia;";
        $stmt = $this->db->prepare($sql);
        $stmt->execute();

        return $stmt->fetch(\PDO::FETCH_ASSOC);
    }

    public function newDatabase()
    {
        try {
            $query = "
                CREATE DATABASE teste
                WITH OWNER = luiz
                    ENCODING = 'LATIN1'
                    TABLESPACE = pg_default
                    LC_COLLATE = 'C'
                    LC_CTYPE = 'C'
                    CONNECTION LIMIT = -1;
                ";
            $stmt = $this->db->prepare($query);
            $stmt->execute();

            return $this;
        } catch (\Throwable$th) {
            return $this->erro = 'Erro ao criar base de dados ' . $th;
        }

    }

}
