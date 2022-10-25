-- Function: public.src_verificar_artmovimento(integer, integer)

-- DROP FUNCTION public.src_verificar_artmovimento(integer, integer);

CREATE OR REPLACE FUNCTION public.src_verificar_artmovimento(
    p_codfilial integer,
    p_codart integer)
  RETURNS integer AS
$BODY$
DECLARE
  WLinhaSQL  TEXT;
  WCodMatriz INTEGER;
  X          RECORD;
BEGIN
  SELECT codmatriz 
    INTO WCodMatriz 
    FROM padrao 
   WHERE codfilial = p_codfilial 
   LIMIT 1;

  --Vai deletar as artmovimento que não possuem vinculo com o movimento
  WLinhaSQL = 'DELETE
                 FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                WHERE codfilart = '|| p_codfilial ||'
                  AND codart    = '|| p_codart ||'
                  AND controle  = 0';
  EXECUTE WLinhaSQL;

  --Valida se todas as movimentações estão na tabela artmovimento, se não estiver então insere
  WLinhaSQL = 'SELECT 1 tabela, 
                      bal.codfilial as filial, 
                      0 AS serie, 
                      bal.codbalanco AS controle,
                      bal.codfilial as codfilart, 
                      bal.codart as codart, 
                      bal.dtbalanco as dtmovto, 
                      bal.hora as hrmovto, 
                      bal.balanco as estoque, 
                      bal.entregar as entregar,
                      0 as natureza,
                      bal.codusuconfirmacao as usuario,
                      bal.codterminalconfirmacao as terminal
                 FROM balanco bal
                WHERE bal.codfilial = '|| p_codfilial ||'
                  AND bal.codart    = '|| p_codart ||'
                  AND bal.situacao  = 1
                  AND NOT EXISTS (SELECT 1 
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = 1
                                     AND codfilcontrole = bal.codfilial
                                     AND controle       = bal.codbalanco
                                     AND codart         = bal.codart)
                UNION ALL
               SELECT 2 tabela, 
                      eni.codfilent as filial, 
                      0 AS serie, 
                      eni.seqentrada AS controle,
                      eni.codfilent as codfilart, 
                      eni.codart as codart, 
                      eni.dtconfirmacao as dtmovto, 
                      eni.horaconfirmacao as hrmovto, 
                      eni.quantconfirmada as estoque, 
                      0 as entregar,
                      (SELECT natureza 
                         FROM entrada 
                        WHERE codfilent  = eni.codfilent 
                          AND seqentrada = eni.seqentrada) as natureza,
                      eni.codusuconfirmacao as usuario,
                      eni.codterminal as terminal
                 FROM entitem eni
                WHERE eni.codfilent = '|| p_codfilial ||'
                  AND eni.codart    = '|| p_codart ||'
                  AND eni.situacao IN (1,3) AND eni.dtconfirmacao >= 0
                  AND NOT EXISTS (SELECT 1 
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = 2
                                     AND codfilcontrole = eni.codfilent
                                     AND controle       = eni.seqentrada
                                     AND codart         = eni.codart)
                UNION ALL
               SELECT 3 tabela,
                      pti.codfilial as filial, 
                      pti.serie as serie, 
                      pti.codtran as controle,
                      pti.codfilial as codfilart, 
                      pti.codart as codart, 
                      ptr.dtmovto as dtmovto, 
                      ptr.horaliberacao as hrmovto, 
                      -pti.quant as estoque, 
                      COALESCE(pti.entregar,0) as entregar,
                      ptr.nat as natureza,
                      ptr.codusucadastro as usuario,
                      ptr.terminal as terminal
                 FROM pedtrani pti, pedtran ptr
                WHERE ptr.codfilial = pti.codfilial
                  AND ptr.serie     = pti.serie
                  AND ptr.codtran   = pti.codtran
                  AND pti.codfilial = '|| p_codfilial ||'
                  AND pti.codart    = '|| p_codart ||'
                  AND NOT EXISTS (SELECT 1
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = 3
                                     AND codfilcontrole = pti.codfilial
                                     AND seriecontrole  = pti.serie
                                     AND controle       = pti.codtran
                                     AND codart         = pti.codart)
                UNION ALL
               SELECT 4 AS tabela, 
                      cni.codfilial AS codfilial, 
                      0 AS serie, 
                      cni.codcond AS controle,
                      cni.codfilial AS codfilart, 
                      cni.codart,
                      cnd.dtmovto AS dtmovto, 
                      cnd.hora AS hrmovto,
                      -cni.quant AS estoque, 
                      0 AS entregar,
                      0 AS natureza, 
                      cnd.codusu, 
                      0 AS codterminal
                 FROM conditem cni
                INNER JOIN condicio cnd 
                   ON cnd.codfilial = cni.codfilial 
                  AND cnd.codcond   = cni.codcond
                WHERE cnd.situacao IN (2, 3, 4)
                  AND cni.codfilial = '|| p_codfilial ||'
                  AND cni.codart    = '|| p_codart ||'
                  AND NOT EXISTS (SELECT 1
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = 4
                                     AND tipomovto      = 2 --saida
                                     AND codfilcontrole = cni.codfilial
                                     AND controle       = cni.codcond
                                     AND codart         = cni.codart)
                UNION ALL
               SELECT 4 AS tabela, 
                      cni.codfilial AS filial, 
                      0 AS serie, 
                      cni.codcond AS controle,
                      cni.codfilial AS codfilart, 
                      cni.codart,
                      cnd.dtdevolucao AS dtmovto, 
                      cnd.hora+1 AS hrmovto,
                      cni.quant AS estoque, 
                      0 AS entregar,
                      0 AS natureza,
                      cnd.codusu as usuario, 
                      0 AS terminal
                 FROM conditem cni
                INNER JOIN condicio cnd 
                   ON cnd.codfilial = cni.codfilial 
                  AND cnd.codcond   = cni.codcond
                WHERE cnd.situacao IN (3, 4)
                  AND cni.codfilial = '|| p_codfilial ||'
                  AND cni.codart    = '|| p_codart ||'
                  AND NOT EXISTS (SELECT 1
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = 4
                                     AND tipomovto      = 1 --entrada
                                     AND codfilcontrole = cni.codfilial
                                     AND controle       = cni.codcond
                                     AND codart         = cni.codart)
                UNION ALL
               SELECT *
                 FROM (SELECT CASE WHEN pdi.tipomovto = 1 THEN 5 ELSE 6 END tabela,
                              pdi.codfilial AS filial, 
                              pdi.serie AS serie, 
                              pdi.codped AS controle,
                              pdi.codfilial AS codfilart, 
                              pdi.codart, 
                              CASE WHEN ped.dtaltempresa <> 0 THEN ped.dtaltempresa ELSE ped.dtmovto END AS dtmovto, 
                              CASE WHEN ped.horaaltempresa <> 0 THEN ped.horaaltempresa ELSE ped.hora END AS hrmovto,
                              SUM((pdi.quant - COALESCE(pie.quant, 0)) * (CASE pdi.tipomovto WHEN 2 THEN 1 ELSE -1 END)) AS estoque,
                              SUM(pdi.entregar - COALESCE(pie.entregar, 0)) AS entregar,
                              CASE WHEN pdi.tipomovto = 1 THEN ped.nat ELSE 4 END AS natureza, 
                              999 AS usuario, 
                              ped.terminal AS terminal
                         FROM peditem pdi
                        INNER JOIN pedido ped 
                           ON ped.codfilial = pdi.codfilial 
                          AND ped.serie = pdi.serie 
                          AND ped.codped = pdi.codped
                         LEFT OUTER JOIN peditest pie 
                           ON pie.codfilial = pdi.codfilial 
                          AND pie.serie = pdi.serie 
                          AND pie.codped = pdi.codped 
                          AND pie.codart = pdi.codart 
                        WHERE pdi.situacao  = 1
                          AND pdi.codfilial = '|| p_codfilial ||'
                          AND pdi.codart    = '|| p_codart ||'
                        GROUP BY pdi.codfilial, 
                              pdi.serie, 
                              pdi.codped, 
                              pdi.codart, 
                              pdi.tipomovto, 
                              ped.dtmovto, 
                              ped.hora, 
                              ped.nat, 
                              ped.terminal, 
                              ped.dtaltempresa, 
                              ped.horaaltempresa 
                        UNION ALL
                       SELECT CASE WHEN pdi.tipomovto = 1 THEN 5 ELSE 6 END tabela,
                              pdi.codfilial AS filial, 
                              pdi.serie AS serie, 
                              pdi.codped AS controle,
                              pie.codfilart AS codfilart, 
                              pdi.codart, 
                              CASE WHEN COALESCE(pie.dtcadastro,0) = 0 THEN ped.dtmovto ELSE pie.dtcadastro END AS dtmovto, 
                              CASE WHEN COALESCE(pie.horacadastro,0) = 0 THEN ped.hora ELSE pie.horacadastro END AS hrmovto,
                              SUM(COALESCE(pie.quant, 0) * (CASE pdi.tipomovto WHEN 2 THEN 1 ELSE -1 END)) AS estoque,
                              SUM(COALESCE(pie.entregar, 0)) AS entregar,
                              CASE WHEN pdi.tipomovto = 1 THEN ped.nat ELSE 4 END AS natureza, 
                              pie.codusucadastro AS usuario, 
                              pie.codterminalcadastro AS terminal
                         FROM peditem pdi
                        INNER JOIN pedido ped 
                           ON ped.codfilial = pdi.codfilial 
                          AND ped.serie = pdi.serie 
                          AND ped.codped = pdi.codped
                         LEFT OUTER JOIN peditest pie 
                           ON pie.codfilial = pdi.codfilial 
                          AND pie.serie = pdi.serie 
                          AND pie.codped = pdi.codped 
                          AND pie.codart = pdi.codart 
                        WHERE pdi.situacao = 1 
                          AND pie.codfilart NOTNULL
                          AND pdi.codfilial = '|| p_codfilial ||'
                          AND pdi.codart    = '|| p_codart ||'
                        GROUP BY pie.codfilart, 
                                 pdi.codfilial, 
                                 pdi.serie, 
                                 pdi.codped, 
                                 pdi.codart, 
                                 pdi.tipomovto, 
                                 pie.dtcadastro, 
                                 ped.dtmovto,
                                 pie.horacadastro,
                                 ped.hora,
                                 ped.nat, 
                                 pie.codusucadastro, 
                                 pie.codterminalcadastro 
                        UNION ALL
                       SELECT CASE WHEN pdi.tipomovto = 1 THEN 5 ELSE 6 END tabela, 
                              pdi.codfilial AS filial, 
                              pdi.serie AS serie, 
                              pdi.codped AS controle,
                              pie.codfilart AS codfilart, 
                              pdi.codart, 
                              CASE WHEN COALESCE(pie.dtcadastro,0) = 0 THEN ped.dtmovto ELSE pie.dtcadastro END AS dtmovto, 
                              CASE WHEN COALESCE(pie.horacadastro,0) = 0 THEN ped.hora ELSE pie.horacadastro END AS hrmovto,
                              SUM(COALESCE(pie.quant, 0) * (CASE pdi.tipomovto WHEN 2 THEN 1 ELSE -1 END)) AS estoque,
                              SUM(COALESCE(pie.entregar, 0)) AS entregar,
                              CASE WHEN pdi.tipomovto = 1 THEN ped.nat ELSE 4 END AS natureza, 
                              pie.codusucadastro AS usuario, 
                              pie.codterminalcadastro AS terminal
                         FROM peditem pdi
                        INNER JOIN pedido ped 
                           ON ped.codfilial = pdi.codfilial 
                          AND ped.serie = pdi.serie 
                          AND ped.codped = pdi.codped
                         LEFT OUTER JOIN peditest pie 
                           ON pie.codfilial = pdi.codfilial 
                          AND pie.serie = pdi.serie 
                          AND pie.codped = pdi.codped 
                          AND pie.codart = pdi.codart 
                        WHERE pdi.situacao = 1 
                          AND pie.codfilart = '|| p_codfilial ||'
                          AND pie.codfilial <> '|| p_codfilial ||'
                          AND pie.codart = '|| p_codart ||'
                        GROUP BY pie.codfilart, 
                                 pdi.codfilial, 
                                 pdi.serie, 
                                 pdi.codped, 
                                 pdi.codart, 
                                 pdi.tipomovto, 
                                 pie.dtcadastro, 
                                 ped.dtmovto,
                                 pie.horacadastro,
                                 ped.hora,
                                 ped.nat, 
                                 pie.codusucadastro, 
                                 pie.codterminalcadastro
                        ) AS tmp_retorno
                WHERE tmp_retorno.estoque <> 0
                  AND NOT EXISTS (SELECT 1
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = tmp_retorno.tabela
                                     AND codfilcontrole = tmp_retorno.filial
                                     AND seriecontrole  = tmp_retorno.serie
                                     AND controle       = tmp_retorno.controle
                                     AND codart         = tmp_retorno.codart)
                UNION ALL
               SELECT * 
                 FROM (SELECT 6 tabela, 
                              dvi.codfilial AS filial, 
                              0 AS serie, 
                              dvi.coddev AS controle, 
                              dvi.codfilial AS codfilart, 
                              dvi.codart, 
                              dev.dtmovto AS dtmovto, 
                              dev.hora AS hrmovto,
                              dvi.quantloja AS estoque,
                              0 AS entregar, 
                              0 AS natureza,
                              dev.codusu AS usuario, 
                              dev.codterminal as terminal
                         FROM devitem dvi
                        INNER JOIN devoluca dev 
                           ON dev.codfilial = dvi.codfilial 
                          AND dev.coddev    = dvi.coddev
                        WHERE dvi.situacao  = 1
                          AND dvi.codfilial = '|| p_codfilial ||'
                          AND dvi.codart    = '|| p_codart ||'
                        UNION
                       SELECT 6 AS tabela, 
                              dvi.codfilial AS filial, 
                              0 AS serie, 
                              dvi.coddev AS controle, 
                              dvi.coddeposito AS codfilart, 
                              dvi.codart, 
                              dev.dtmovto AS dtmovto, 
                              dev.hora AS hrmovto,
                              dvi.quantdeposito AS estoque,
                              0 AS entregar, 
                              0 AS natureza,
                              dev.codusu AS usuario, 
                              dev.codterminal as terminal
                         FROM devitem dvi
                        INNER JOIN devoluca dev 
                           ON dev.codfilial   = dvi.codfilial 
                          AND dev.coddev      = dvi.coddev
                        WHERE dvi.situacao    = 1
                          AND dvi.coddeposito = '|| WCodMatriz ||'
                          AND dvi.codart      = '|| p_codart ||') AS tmp_dvi
                WHERE tmp_dvi.estoque <> 0
                  AND NOT EXISTS (SELECT 1
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = 6
                                     AND codfilcontrole = tmp_dvi.filial
                                     AND controle       = tmp_dvi.controle
                                     AND codart         = tmp_dvi.codart)
                UNION ALL
               SELECT 7 tabela,
                      pci.codfilprod filial,
                      0 as serie,
                      pci.codprod as controle,
                      pci.codfilprod as codfilart,
                      pci.codartmp as codart,
                      ppr.dtinicio as dtmovto,
                      ppr.horainicio as hrmovto,
                      -pci.quant as estoque,
                      0 as entregar,
                      0 as natureza,
                      999 as usuario,
                      0 as terminal
                 FROM pcpprodmp pci, pcpproducao ppr
                WHERE ppr.codfilprod  = pci.codfilprod 
                  AND ppr.codprod     = pci.codprod 
                  AND ppr.codart      = pci.codart 
                  AND ppr.coditemprod = pci.coditemprod
                  AND pci.codfilprod  = '|| p_codfilial ||'
                  AND pci.codartmp    = '|| p_codart ||'
                  AND pci.situacao    = 1
                  AND NOT EXISTS (SELECT 1
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = 7
                                     AND codfilcontrole = pci.codfilprod
                                     AND controle       = pci.codprod
                                     AND codart         = pci.codartmp)
                UNION ALL
               SELECT 8 AS tabela, 
                      mac.codfilos AS filial, 
                      0 AS serie, 
                      mac.codos AS controle,
                      mac.codfilos AS codfilart, 
                      mac.codart,
                      ose.dtmovto AS dtmovto, 
                      ose.hora AS hrmovto,
                      -mac.quantidade AS estoque, 
                      0 AS entregar,
                      0 AS natureza, 
                      ose.codusufinalizacao AS usuario, 
                      ose.terminal AS terminal
                 FROM osmaterialconsumo mac, osordemservico ose
                WHERE ose.codfilos = mac.codfilos 
                  AND ose.codos    = mac.codos
                  AND mac.codfilos = '|| p_codfilial ||'
                  AND mac.codart   = '|| p_codart ||'
                  AND mac.situacao = 1
                  AND NOT EXISTS (SELECT 1
                                    FROM artmovimento'|| src_numero_artmovimento(p_codart) ||'
                                   WHERE tabela         = 8
                                     AND codfilcontrole = mac.codfilos
                                     AND controle       = mac.codos
                                     AND codart         = mac.codart)';
                                     --raise notice 'WLinhaSQL = %',WLinhaSQL;
  FOR X IN EXECUTE WLinhaSQL 
  LOOP
   -- raise info 'X.tabela = % X.hrmovto = %', X.tabela, horaclarion(X.hrmovto);
    EXECUTE 'INSERT INTO artmovimento'|| src_numero_artmovimento(X.codart) ||'
                         (seqartmovto, codfilart, codart, tabela, 
                          codfilcontrole, seriecontrole, controle, natureza, 
                          dtmovto, horamovto, codusu, codterminal, 
                          tipooperacao, tipomovto, quantidade, entregar)
                  VALUES (nextval(''seq_artmovimento'|| src_numero_artmovimento(X.codart) ||''')::integer,'|| 
                          COALESCE(X.codfilart, 0) ||', '|| 
                          COALESCE(X.codart, 0) ||', '|| 
                          COALESCE(X.tabela, 0) ||', '|| 
                          COALESCE(X.filial, 0) ||', '|| 
                          COALESCE(X.serie, 0) ||', '|| 
                          COALESCE(X.controle, 0) ||', '|| 
                          COALESCE(X.natureza, 0) ||', '|| 
                          COALESCE(X.dtmovto, 0) ||', '|| 
                          COALESCE(X.hrmovto, 0) ||', '|| 
                          COALESCE(X.usuario, 0) ||', '|| 
                          COALESCE(X.terminal, 0) ||', 
                          1, '|| 
                          CASE WHEN COALESCE(X.estoque, 0) > 0 THEN 1 ELSE 2 END ||', '|| 
                          COALESCE(X.estoque, 0) ||', '|| 
                          COALESCE(X.entregar, 0) ||');';
  if x.tabela = 5 and X.controle = 3300 then
    -- raise notice 'quantidade %',X.estoque;
  end if;
  END LOOP;
  RETURN 1;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.src_verificar_artmovimento(integer, integer)
  OWNER TO postgres;
