<?php

namespace App\Models;

use MF\Model\Model;

class Usuario extends Model {

	private $id;
	private $usuario;
	private $senha;

	public function __get($atributo) {
		return $this->$atributo;
	}

	public function __set($atributo, $valor) {
		$this->$atributo = $valor;
	}

	public function autenticar() {

		$query = "select id, usuario from usuario where usuario = :usuario and senha = :senha";
		$stmt = $this->db->prepare($query);
		$stmt->bindValue(':usuario', $this->__get('usuario'));
		$stmt->bindValue(':senha', $this->__get('senha'));
		$stmt->execute();

		$usuario = $stmt->fetch(\PDO::FETCH_ASSOC);

		if($usuario['id'] != '' && $usuario['usuario'] != '') {
			$this->__set('id', $usuario['id']);
			$this->__set('usuario', $usuario['usuario']);
		}

		return $this;
	}

}

?>