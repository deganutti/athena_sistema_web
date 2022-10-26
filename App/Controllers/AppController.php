<?php

namespace App\Controllers;

//os recursos do miniframework
use MF\Controller\Action;
use MF\Model\Container;

class AppController extends Action
{

    public function validaAutenticacao()
    {

        session_start();

        if (!isset($_SESSION['id_usuario']) || $_SESSION['id_usuario'] == '' || !isset($_SESSION['nome']) || $_SESSION['nome'] == '') {
            header('Location: /?login=erro');
        }
    }

    public function dashboard()
    {
        $dataBD = Container::getModel('Novabase');
        $this->view->dataBD = $dataBD->getDataBD();

        $tabelas = Container::getModel('Popular');
        $this->view->tabelas = $tabelas->getAll();

        $bd = Container::getModel('Dashboard');
        $this->view->bd = $bd->getAll();

        $dupCli = Container::getModel('Dashboard');
        $this->view->dupCli = $dupCli->cliDuplicado();

        $this->render('dashboard');
    }

    public function databases()
    {
        $bd = Container::getModel('Dashboard');
        $this->view->bd = $bd->getAll();

        $this->render('novabase');
    }

    public function newDB()
    {
        try {
            $newDb = Container::getModel('Novabase');
            $newDb = $newDb->newDatabase();
            $this->view->newDb = $newDb;

            header('Location: /novabase');
        } catch (\Throwable $th) {
            //throw $th;
            header('Location: /?novabase=' . $th);
        }
    }

    public function newDatabasePG()
    {
        $bd = Container::getModel('Dashboard');
        $this->view->bd = $bd->getAll();
        header('Location: /novabase');
    }

    public function funcaoTabelas()
    {
        $tabelas = Container::getModel('Popular');
        $this->view->tabelas = $tabelas->getAll();

        $bd = Container::getModel('Dashboard');
        $this->view->bd = $bd->getAll();

        $this->render('ajustes');
    }

    public function criaEstoqueZero()
    {

        try {
            $estoque = Container::getModel('Popular');
            $estoque = $estoque->tabelaArtigo2();

            $this->view->ajustes = $estoque;

            header('Location: /ajustes');
        } catch (\Throwable $th) {
            header('Location: /?ajustes=erro');
        }
    }
    public function tabelaArtPrind()
    {

        try {
            $artPrind = Container::getModel('Popular');
            $artPrind = $artPrind->tabelaArtPrind();

            $this->view->artPrind = $artPrind;

            header('Location: /ajustes');
        } catch (\Throwable $th) {
            header('Location: /?ajustes=prind');
        }
    }
    public function tabelaArtBloqueio()
    {

        try {
            $artBloqueio = Container::getModel('Popular');
            $artBloqueio = $artBloqueio->tabelaArtBloqueio();

            $this->view->artBloqueio = $artBloqueio;

            header('Location: /ajustes');
        } catch (\Throwable $th) {
            header('Location: /?ajustes=artBloqueio');
        }
    }

    public function compararProdutos()
    {
        try {
            $tabelas = Container::getModel('Popular');
            $this->view->tabelas = $tabelas->getAll();

            $bd = Container::getModel('Dashboard');
            $this->view->bd = $bd->getAll();

            $dupCli = Container::getModel('Dashboard');
            $this->view->dupCli = $dupCli->cliDuplicado();

            $this->render('ajustes');
        } catch (\Throwable $th) {
            header('Location: /?ajustes=erro');
        }
    }

    public function getmovart()
    {
        try {

            $movped = Container::getModel('Popular');
            $this->view->movped = $movped->setmovped();

            header('Location: /ajustes');
        } catch (\Throwable $th) {
            header('Location: /?ajustes=erro');
        }
    }
    public function setmovfincab()
    {
        try {

            $fincab = Container::getModel('Popular');
            $this->view->fincab = $fincab->setFinanceiroPedidoCabecalho();

            header('Location: /ajustes');
        } catch (\Throwable $th) {
            header('Location: /?ajustes=erro');
        }
    }
    public function setmovfincor()
    {
        try {
            $fincor = Container::getModel('Popular');
            $this->view->fincor = $fincor->setFinanceiroPedidoCorpo();

            header('Location: /ajustes');
        } catch (\Throwable $th) {
            header('Location: /?ajustes=erro');
        }
    }
}
