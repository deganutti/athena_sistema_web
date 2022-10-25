<?php

namespace App\Models;

use MF\Model\Model;

class Popular extends Model
{

    public function __get($atributo)
    {
        return $this->$atributo;
    }

    public function __set($atributo, $valor)
    {
        $this->$atributo = $valor;
    }

    public function tabelaArtigo2()
    {
/**
 * tabela responsável pelo estoque de produto estoque estará zerado
 */
        try {
            //apaga a tabela toda
            $del = "delete from public.artigo2;";
            $stmt = $this->db->prepare($del);
            $stmt->execute();
            //insere todos os dados zerados.
            $novo = "
            insert into public.artigo2(
            select  1,
            codart,
            0,0,0,0,0,'',
            '','',0,0,0,0,
            0,0,0,0,0,0,0,
            0,'',0,0,0,0,0,''
            from public.artigo1
            where codart > 0
            );";
            $stmt = $this->db->prepare($novo);
            $stmt->execute();
            return $this;
        } catch (\Throwable$th) {
            return $this->erro = $th;
        }
    }

    public function tabelaArtPrind()
    {
/**
 * tabela referente aos dados do fornecedor.
 * importa tudo zerado
 */
        try {
            $del = "
            delete from public.artprind;
            ";
            $sql = $this->db->prepare($del);
            $sql->execute();

            $novo = "
            insert into public.artprind(
            select codart,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            'Dados importados: '||(select to_char(current_date, 'dd/mm/YYYY')),
            0,0,0,0,0,0,0,0,0,1,0,0
            from public.artigo1
            where codart > 0);
            ";
            $stmt = $this->db->prepare($novo);
            $stmt->execute();
            return $this;

        } catch (\Throwable$th) {
            return $this->prind = $th;
        }
    }
    public function tabelaArtBloqueio()
    {
/**
 * Tabela responsável pelço bloqueio e uso do item em telas do sistema
 */
        try {
            $query = "delete from public.artbloqueio;";
            $stmt = $this->db->prepare($query);
            $stmt->execute();

            $query = "insert into public.artbloqueio(
                select  1,codart,0,0,0,0,0,0,0,0,0,1
                  from public.artigo1
                  where codart > 0
                );
                ";
            $stmt = $this->db->prepare($query);
            $stmt->execute();
            return $this;
        } catch (\Throwable$th) {
            return $this->erro = $th;
        }
    }
    public function getAll()
    {
        $query = "
        select * from (
            select 'artigo1' as tab
                , (select count(*) from public.artigo1 where codart>0) as qtd
            union all
            select 'artigo2' as tabela
                , (select count(*) from public.artigo2)
            union all
            select 'artprecos' as tabela
                , (select count(*) from public.artprecos)
            union all
            select 'artprind' as tabela
                , (select count(*) from public.artprind)
            union all
            select 'artbloqueio' as tabela
            , (select count(*) from public.artbloqueio) ) v ";
        $stmt = $this->db->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    public function setmovped()
    {
        
        $query = "delete from public.artmovimento1;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento2;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento3;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento4;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento5;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento6;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento7;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento8;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento9;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento10;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento11;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento12;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento13;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento14;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento15;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento16;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento17;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento18;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento19;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "delete from public.artmovimento20;";
        $stmt = $this->db->prepare($query);
        $stmt->execute();

        $query = "select public.src_recriar_artmovimento();";

        $stmt = $this->db->prepare($query);
        $stmt->execute();
        
        return $this;
    }

   

    public function setFinanceiroPedidoCabecalho()
    {
        $limpaTitulos='delete from public.conrec;';
        $stmt = $this->db->prepare($limpaTitulos);
        $stmt->execute();

        return $this;

        /**
         * Afim de gerar o financeiro dos pedidos, e situação = 9 => negociada.
         */
        $conrec = "
       INSERT INTO public.conrec (
        select 1 as codfilial,
            1 as serie,
            codped,
            1 as codfilcli,
            codcli,
            dtmovto,
            0 as codpgto,
            codvend,
            0 as codclob,
            0 as total,
            0 as prazo1,
            0 as prazo2,
            0 as prazo3,
            0 as prazo4,
            0 as prazo5,
            0 as prazo6,
            0 as prazo7,
            0 as prazo8,
            0 as prazo9,
            0 as prazo10,
            '' as historico,
            0 as inddesc,
            0 as valordesc,
            0 as valorfinanc,
            0 as valorretencao,
            0 as outdesp,
            0 as valoripi,
            0 as codred,
            0 as codclass,
            1 as codfilorigem,
            1 as serieorigem,
            0 as controleorigem,
            0 as parcelaorigem,
            0 as codgenerico,
            0 as serieoriginal,
            0 as cobrancaalteradanf,
            0 as codfilfat,
            0 as seriefat,
            0 as codfat,
            0 as dtemissaooriginal,
            0 as horaagrup,
            0 as codusuagrup,
            0 as datamovtoagrup
        from public.pedido
        where codcli > 0
    );";
        $stmt = $this->db->prepare($conrec);
        $stmt->execute();

        return $this;

    }

    public function setFinanceiroPedidoCorpo()
    {
        /**
         * Afim de gerar o financeiro dos pedidos, e situação = 9 => negociada.
         */
        $conreitem = "
        INSERT INTO public.conritem (
            SELECT codfilial,
                serie,
                codped,
                1,
                dtemissao,
                dtemissao,
                0,
                0,
                0,
                0,
                0,
                9999,
                3,
                0,
                1,
                2,
                0,
                0,
                0,
                0,
                '',
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0
            FROM public.conrec
    );";
        $stmt = $this->db->prepare($conreitem);
        $stmt->execute();

        return $this;

    }

}
