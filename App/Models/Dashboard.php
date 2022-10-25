<?php

namespace App\Models;

use MF\Model\Model;

class Dashboard extends Model
{

    public function __get($atributo)
    {
        return $this->$atributo;
    }

    public function __set($atributo, $valor)
    {
        $this->$atributo = $valor;
    }

    public function getAll()
    {
        $sql = "select current_database() as banco;";
        $stmt = $this->db->prepare($sql);
        $stmt->execute();
        return $stmt->fetch(\PDO::FETCH_ASSOC);
    }
    public function cliDuplicado()
    {
        $sql = "select count(*) as qtd
		             , CPF as dados
                from public.cliente
                group by CPF
			    having count(*) > 1 ";
        $stmt = $this->db->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
        foreach ($stmt as $key => $dados) {
            #  ...
        }
    }

}
