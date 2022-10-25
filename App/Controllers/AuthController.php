<?php

namespace App\Controllers;

//os recursos do miniframework
use MF\Controller\Action;
use MF\Model\Container;

class AuthController extends Action {


	public function autenticar() {
		
		$usuario = Container::getModel('Usuario');

		$usuario->__set('usuario', $_POST['usuario']);
		$usuario->__set('senha', md5($_POST['senha']));

		$usuario->autenticar();

		if($usuario->__get('id') != '' && $usuario->__get('usuario')!='') {
			
			session_start();

			$_SESSION['id'] = $usuario->__get('id');
			$_SESSION['usuario'] = $usuario->__get('usuario');

			header('Location: /dashboard');

		} else {
			header('Location: /?login=erro');
		}

	}

	public function sair() {
		session_start();
		session_destroy();
		header('Location: /');
	}
}