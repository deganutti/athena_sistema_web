<?php

namespace App\Controllers;

//os recursos do miniframework
use MF\Controller\Action;
use MF\Model\Container;

class AuthController extends Action
{

	public function autenticar()
	{

		$usuario = Container::getModel('Usuario');

		$usuario->__set('empresa', $_POST['empresa']);
		$usuario->__set('email', $_POST['email']);
		$usuario->__set('senha', md5($_POST['senha']));

		$usuario->autenticar();

		if ($usuario->__get('id_usuario') != '' && $usuario->__get('email') != '') {

			session_start();

			$_SESSION['id_empresa'] = $usuario->__get('id_empresa');
			$_SESSION['id_usuario'] = $usuario->__get('id_usuario');
			$_SESSION['email'] = $usuario->__get('email');
			$_SESSION['nome'] = $usuario->__get('nome');
			$_SESSION['sobrenome'] = $usuario->__get('sobranome');

			header('Location: /dashboard');
		} else {
			header('Location: /?login=erro');
		}
	}

	public function getAll()
	{
		$this->render('/');
	}

	public function sair()
	{
		session_start();
		session_destroy();
		header('Location: /');
	}
}
