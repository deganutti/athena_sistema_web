create database athena_db character set utf8 collate utf8_general_ci;
create table empresa(
	id_empresa int auto_increment,
	nome varchar(100) not null, 
	apelido varchar(100) not null,
	cpf varchar(20) not null,
	rg varchar(20),
	telefone varchar(20),
	celular varchar(20),
	whatsapp varchar(20),
	email varchar(250),
	website varchar(250),
	cep varchar(10) not null,
	endereco varchar(100) not null,
	numero int,
	complemento varchar(250),
	bairro varchar(150) not null,
	cidade varchar(150) not null,
	estado varchar(100) not null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp, 
	constraint pk_empresa primary key (id_empresa),
	constraint unique_cpf_empresa unique (cpf)
);
create table tp_pessoa(
	id_tipo_pessoa int auto_increment,
	descricao varchar(250) not null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp,
	constraint pk_tipo_pessoa primary key(id_tipo_pessoa)
);
create table usuario(
	id_empresa int not null,
	id_usuario int auto_increment,
	nome varchar(250) not null,
	sobrenome varchar(150) not null,
	nascimento date,
	cpf varchar(20) not null,
	rg varchar(20),
	telefone varchar(20),
	celular varchar(20),
	whatsapp varchar(20),
	email varchar(250) not null,
	cep varchar(10) not null,
	endereco varchar(100) not null,
	numero int,
	complemento varchar(250),
	bairro varchar(150) not null,
	cidade varchar(150) not null,
	estado varchar(100) not null,
	senha varchar(35) not null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp, 
	constraint pk_usuario primary key(id_usuario),	
	constraint fk_empresa_usuario foreign key (id_empresa) references empresa(id_empresa) ON DELETE CASCADE ON UPDATE cascade,
	constraint unique_cpf_usuario unique (id_empresa,cpf)
);
create table pessoa(
	id_empresa int not null,
	id_pessoa int auto_increment,
	nome varchar(250) not null,
	fantasia varchar(250),
	nascimento date,
	id_tipo_pessoa int not null,
	cpf varchar(20) not null,
	rg varchar(20),
	telefone varchar(20),
	celular varchar(20),
	whatsapp varchar(20),
	email varchar(250) not null,
	cep varchar(10) not null,
	endereco varchar(100) not null,
	numero int default 0,
	complemento varchar(250),
	bairro varchar(150) not null,
	cidade varchar(150) not null,
	estado varchar(100) not null,
	id_usuario_insert int null,
	id_usuario_update int null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp, 
	constraint pk_pessoa primary key(id_pessoa),	
	constraint fk_usuario_insert_pessoa foreign key (id_usuario_insert) references usuario(id_usuario) on delete restrict on update restrict,
	constraint fk_usuario_update_pessoa foreign key (id_usuario_update) references usuario(id_usuario) on delete restrict on update restrict,
	constraint fk_empresa_pessoa foreign key (id_empresa) references empresa(id_empresa) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_tipo_pessoa foreign key (id_tipo_pessoa) references tp_pessoa(id_tipo_pessoa) ON DELETE restrict ON UPDATE restrict,
	constraint unique_cpf_pessoa unique (id_empresa,cpf)
);
create table centro_custo(
	id_empresa int not null,
     id_centro_custo int auto_increment,
	descricao varchar(250) not null,
	id_usuario_insert int null,
	id_usuario_update int null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp,
	constraint fk_empresa_centro_custo foreign key (id_empresa) references empresa(id_empresa) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_usuario_insert_centro_custo foreign key (id_usuario_insert) references usuario(id_usuario) on delete restrict on update restrict,
	constraint fk_usuario_update_centro_custo foreign key (id_usuario_update) references usuario(id_usuario) on delete restrict on update restrict,
	constraint pk_centro_custo primary key(id_centro_custo)
	);
create table custo(
	id_empresa int not null,
     id_custo int auto_increment,
	descricao varchar(250) not null,
	id_usuario_insert int null,
	id_usuario_update int null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp,
	constraint fk_empresa_custo foreign key (id_empresa) references empresa(id_empresa) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_usuario_insert_custo foreign key (id_usuario_insert) references usuario(id_usuario) on delete restrict on update restrict,
	constraint fk_usuario_update_custo foreign key (id_usuario_update) references usuario(id_usuario) on delete restrict on update restrict,
	constraint pk_custo primary key(id_custo)
	);
create table banco(
	id_empresa int not null,
     id_banco int auto_increment,
	descricao varchar(250) not null,
	id_usuario_insert int null,
	id_usuario_update int null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp,
	constraint fk_empresa_banco foreign key (id_empresa) references empresa(id_empresa) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_usuario_insert_banco foreign key (id_usuario_insert) references usuario(id_usuario) on delete restrict on update restrict,
	constraint fk_usuario_update_banco foreign key (id_usuario_update) references usuario(id_usuario) on delete restrict on update restrict,
	constraint pk_banco primary key(id_banco)
	);
create table agencia(
	id_empresa int not null,
	id_banco int not null,
     id_agencia int auto_increment,
	descricao varchar(250) not null,
	id_usuario_insert int null,
	id_usuario_update int null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp,
	constraint fk_empresa_agencia foreign key (id_empresa) references empresa(id_empresa) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_usuario_insert_agencia foreign key (id_usuario_insert) references usuario(id_usuario) on delete restrict on update restrict,
	constraint fk_usuario_update_agencia foreign key (id_usuario_update) references usuario(id_usuario) on delete restrict on update restrict,
	constraint pk_agencia primary key(id_agencia)
);
create table conta(
	id_empresa int not null,
	id_agencia int not null,
     id_conta int auto_increment,
	descricao varchar(250) not null,
	id_usuario_insert int null,
	id_usuario_update int null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp,
	constraint fk_empresa_conta foreign key (id_empresa) references empresa(id_empresa) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_agencia_conta foreign key (id_agencia) references agencia(id_agencia) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_usuario_insert_conta foreign key (id_usuario_insert) references usuario(id_usuario) on delete restrict on update restrict,
	constraint fk_usuario_update_conta foreign key (id_usuario_update) references usuario(id_usuario) on delete restrict on update restrict,
	constraint pk_conta primary key(id_conta)
);
-- athena_db.financeiro definition
-- athena_db.tipo_financeiro definition

CREATE TABLE `tipo_financeiro` (
  `id_tipo_financeiro` int(11) NOT NULL AUTO_INCREMENT,
  `descricao` varchar(250) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_tipo_financeiro`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
CREATE TABLE financeiro (
  id_empresa int(11) NOT NULL,
  id_pessoa int(11) NOT NULL,
  id_financeiro int(11) NOT NULL AUTO_INCREMENT,
  numero int(11) NOT NULL,
  parcela int(11) NOT NULL,
  dt_emissao date NOT NULL,
  id_tipo_financeiro int(11) NOT NULL,
  id_centro_custo int(11) NOT NULL,
  id_custo int(11) NOT NULL,
  valor double NOT NULL,
  juros double DEFAULT '0',
  multa double DEFAULT '0',
  valor_total double NOT NULL,
  id_usuario_insert int(11) DEFAULT NULL,
  id_usuario_update int(11) DEFAULT NULL,
  created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_financeiro),
  UNIQUE KEY unq_financeiro (id_empresa,id_pessoa,numero,parcela,id_tipo_financeiro),
  KEY fk_pessoa_financeiro (id_pessoa),
  KEY fk_usuario_insert_financeiro (id_usuario_insert),
  KEY fk_usuario_update_financeiro (id_usuario_update),
  KEY fk_tipo_financeiro_financeiro (id_tipo_financeiro),
  CONSTRAINT fk_empresa_financeiro FOREIGN KEY (id_empresa) REFERENCES empresa (id_empresa) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pessoa_financeiro FOREIGN KEY (id_pessoa) REFERENCES pessoa (id_pessoa) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_tipo_financeiro_financeiro FOREIGN KEY (id_tipo_financeiro) REFERENCES tipo_financeiro (id_tipo_financeiro),
  CONSTRAINT fk_usuario_insert_financeiro FOREIGN KEY (id_usuario_insert) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_usuario_update_financeiro FOREIGN KEY (id_usuario_update) REFERENCES usuario (id_usuario)
);
-- athena_db.movimento_financeiro definition

CREATE TABLE `movimento_financeiro` (
  `id_empresa` int(11) NOT NULL,
  `id_movimento` int(11) NOT NULL AUTO_INCREMENT,
  `id_financeiro` int(11) NOT NULL,
  `id_conta` int(11) NOT NULL,
  `dt_movimento` date NOT NULL,
  `valor` double NOT NULL,
  `valor_desconto` double DEFAULT '0',
  `valor_acrecimo` double DEFAULT '0',
  `valor_juros` double DEFAULT '0',
  `valor_multa` double DEFAULT '0',
  `situacao` int(11) DEFAULT '1',
  `id_usuario_insert` int(11) DEFAULT NULL,
  `id_usuario_update` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_movimento`),
  KEY `fk_usuario_insert_movimento_financeiro` (`id_usuario_insert`),
  KEY `fk_usuario_update_movimento_financeiro` (`id_usuario_update`),
  KEY `fk_empresa_movimento_financeiro` (`id_empresa`),
  KEY `fk_financeiro_movimento_financeiro` (`id_financeiro`),
  KEY `fk_conta_movimento_financeiro` (`id_conta`),
  CONSTRAINT `fk_conta_movimento_financeiro` FOREIGN KEY (`id_conta`) REFERENCES `conta` (`id_conta`),
  CONSTRAINT `fk_empresa_movimento_financeiro` FOREIGN KEY (`id_empresa`) REFERENCES `empresa` (`id_empresa`),
  CONSTRAINT `fk_financeiro_movimento_financeiro` FOREIGN KEY (`id_financeiro`) REFERENCES `financeiro` (`id_financeiro`),
  CONSTRAINT `fk_usuario_insert_movimento_financeiro` FOREIGN KEY (`id_usuario_insert`) REFERENCES `usuario` (`id_usuario`),
  CONSTRAINT `fk_usuario_update_movimento_financeiro` FOREIGN KEY (`id_usuario_update`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;