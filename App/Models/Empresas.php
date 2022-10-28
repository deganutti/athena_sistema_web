<?php

namespace App\Models;

use MF\Model\Model;

class Empresas extends Model
{

	private $id;
	private $usuario;
	private $senha;

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
		$sql = "
			select id_empresa
				 , nome
				 , apelido
				 , cpf
				 , rg
				 , telefone
				 , celular
				 , whatsapp
				 , email
				 , website
				 , cep
				 , endereco
				 , numero
				 , complemento
				 , bairro
				 , cidade
				 , estado
				 , created_at
				 , updated_at
			from empresa;
		";
		$stmt = $this->db->prepare($sql);
		$stmt->execute();

		return $stmt->fetchAll(\PDO::FETCH_ASSOC);
	}
}
