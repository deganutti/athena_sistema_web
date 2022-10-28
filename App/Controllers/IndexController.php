<?php

namespace App\Controllers;

//os recursos do miniframework
use MF\Controller\Action;
use MF\Model\Container;

class IndexController extends Action
{
    public function index()
    {
        $this->view->login = isset($_GET['login']) ? $_GET['login'] : '';

        $bd = Container::getModel('usuario');
        $this->view->bd = $bd->getAll();

        $empresa = Container::getModel('empresas');
        $this->view->empresa = $empresa->getAll();



        $this->render('index');
    }
}
