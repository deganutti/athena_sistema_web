<?php

namespace App;

use MF\Init\Bootstrap;

class Route extends Bootstrap
{

	protected function initRoutes()
	{

		$routes['home'] = array(
			'route' => '/',
			'controller' => 'AuthController',
			'action' => 'getAll'
		);
		$routes['autenticar'] = array(
			'route' => '/autenticar',
			'controller' => 'AuthController',
			'action' => 'autenticar'
		);
		$routes['dashboard'] = array(
			'route' => '/dashboard',
			'controller' => 'AppController',
			'action' => 'dashboard'
		);
		$routes['sair'] = array(
			'route' => '/sair',
			'controller' => 'AuthController',
			'action' => 'sair'
		);
		/**
		 * Criar banco de dados
		 * 12-01-2021
		 */
		$routes['novabase'] = array(
			'route' => '/novabase',
			'controller' => 'AppController',
			'action' => 'databases'
		);
		$routes['newDB'] = array(
			'route' => '/newDB',
			'controller' => 'AppController',
			'action' => 'newDB'
		);


		/**
		 * Opções de tabelas
		 */
		$routes['ajustes'] = array(
			'route' => '/ajustes',
			'controller' => 'AppController',
			'action' => 'funcaoTabelas'
		);
		$routes['estoque'] = array(
			'route' => '/estoque',
			'controller' => 'AppController',
			'action' => 'criaEstoqueZero'
		);
		$routes['artprind'] = array(
			'route' => '/artprind',
			'controller' => 'AppController',
			'action' => 'tabelaArtPrind'
		);
		$routes['artbloqueio'] = array(
			'route' => '/artbloqueio',
			'controller' => 'AppController',
			'action' => 'tabelaArtBloqueio'
		);
		$routes['comparar'] = array(
			'route' => '/comparar',
			'controller' => 'AppController',
			'action' => 'compararProdutos'
		);
		$routes['movped'] = array(
			'route' => '/movped',
			'controller' => 'AppController',
			'action' => 'getmovart'
		);
		$routes['movfincab'] = array(
			'route' => '/movfincab',
			'controller' => 'AppController',
			'action' => 'setmovfincab'
		);
		$routes['movfincor'] = array(
			'route' => '/movfincor',
			'controller' => 'AppController',
			'action' => 'setmovfincor'
		);
		$this->setRoutes($routes);
	}
}
