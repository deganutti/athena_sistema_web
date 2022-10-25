<?php

namespace MF\Model;

use App\Connection;

class Container {

	public static function getModel($model) {
		$class = "\\App\\Models\\".ucfirst($model);
		$conn = Connection::getDb();

		return new $class($conn);
	}
	public static function getModelMs($model){
		$class = "\\App\\Models\\".ucfirst($model);
		$mssql = Connection::getDbMS();

		return new $class($mssql);
	}

	
}


?>