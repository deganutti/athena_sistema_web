select count(*) from artigo1--7534 registros
--CRIAR ARTIGO2 DE BACKUP
create table artigo2_bk12022021 as(select * from artigo2)

--ZERAR QUANTIDADES A ENTREGAR DE BALANÇOS (NÃO DEVE TER BALANÇOS PENDENTES DE ATUALIZAÇÃO!!!)
begin
alter table balanco disable trigger all;
update balanco set entregar=0 where codfilial=1; --QUANTIDADE=18794
alter table balanco enable trigger all;
commit

--EXCLUIR ARTMOVIMENTOS PARA SEREM RECRIADOS
DO $$
DECLARE
  x integer;
BEGIN
  FOR x IN 1..20 LOOP
    EXECUTE 'delete from artmovimento'||x||' where codfilart=1'; 
    RAISE INFO E'art = %',x;
  END LOOP;
END$$;


SELECT MAX(CODART) FROM ARTIGO1 --17887
--RECALCULAR ESTOQUE DE TODOS OS PRODUTOS
DO $$
DECLARE
  x record;
  c_prod cursor for
  select codart 
    from artigo1 
   where codart between 1 and 17887;  --[COLOCAR INTERVALO DE CODART]
BEGIN
  FOR x IN c_prod LOOP
    PERFORM src_recalcular_estoque_w(1,x.codart); --[COLOCAR FILIAL]
    RAISE INFO E'codart = %',x;
  END LOOP;
END$$; 


--COMPARATIVO DOS ARTIGOS QUE FICARAM DIFERENTES
select a.codart,b.codart,a.estoque,b.estoque, a.entregar,b.entregar 
	from artigo2 a inner join artigo2_bk10022021 b using (codfilial,codart) 
	where a.estoque<>b.estoque or a.entregar<>b.entregar
order by a.codart

--TEMPO DE EXECUÇÃO: 02:08:59
