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
create table financeiro(
	id_empresa int not null,
     id_pessoa int not null,
     id_financeiro int auto_increment,
     numero int not null,
     parcela int not null,
     dt_emissao date not null,
     id_tipo_financeiro int not null,
     id_centro_custo int not null,
     id_custo int not null, 
     valor double precision not null,
     juros double precision default 0,
     multa double precision default 0,
     valor_total double precision not null,
     id_usuario_insert int null,
	id_usuario_update int null,
	created_at timestamp default current_timestamp,
	updated_at timestamp default current_timestamp on update current_timestamp,
	constraint fk_empresa_financeiro foreign key (id_empresa) references empresa(id_empresa) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_pessoa_financeiro foreign key (id_pessoa) references pessoa(id_pessoa) ON DELETE CASCADE ON UPDATE cascade,
	constraint fk_usuario_insert_financeiro foreign key (id_usuario_insert) references usuario(id_usuario) on delete restrict on update restrict,
	constraint fk_usuario_update_financeiro foreign key (id_usuario_update) references usuario(id_usuario) on delete restrict on update restrict,
	constraint unq_financeiro unique (id_empresa, id_pessoa, numero, parcela, id_tipo_financeiro),
	constraint pk_financeiro primary key(id_financeiro)
);