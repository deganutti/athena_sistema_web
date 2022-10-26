<?php

namespace App\Models;

use MF\Model\Model;

class Usuario extends Model
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

	public function autenticar()
	{

		$query = "
		select us.id_empresa 
     , us.id_usuario 
     , us.nome 
     , us.sobrenome 
     , us.nascimento 
     , us.cpf 
     , us.rg 
     , us.telefone 
     , us.celular 
     , us.whatsapp 
     , us.email 
     , us.cep 
     , us.endereco 
     , us.numero 
     , us.complemento 
     , us.bairro 
     , us.cidade 
     , us.estado 
     , us.created_at 
     , us.updated_at 
from usuario us
where us.id_empresa = :id_empresa  
  and us.email = :email
  and us.senha = :senha
		";
		$stmt = $this->db->prepare($query);
		$stmt->bindValue(':id_empresa', $this->__get('id_empresa'));
		$stmt->bindValue(':email', $this->__get('email'));
		$stmt->bindValue(':senha', $this->__get('senha'));
		$stmt->execute();

		$usuario = $stmt->fetch(\PDO::FETCH_ASSOC);

		if ($usuario['id_usuario'] != '' && $usuario['usuario'] != '') {
			$this->__set('id_empresa', $usuario['id_empresa']);
			$this->__set('id_usuario', $usuario['id_usuario']);
			$this->__set('nome', $usuario['nome']);
			$this->__set('sobrenome', $usuario['sobrenome']);
			$this->__set('email', $usuario['email']);
		}

		return $this;
	}

	public function getAll()
	{
	}
}
