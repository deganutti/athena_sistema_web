-- Function: public.src_recriar_artmovimento()
-- DROP FUNCTION public.src_recriar_artmovimento();
CREATE OR REPLACE FUNCTION public.src_recriar_artmovimento() RETURNS void AS $BODY$
declare WRecord record;
WLinhaSQL text;
begin for WRecord IN (
    SELECT 1 AS tipo_tabela,
        bal.codfilial AS codfilart,
        bal.codart,
        bal.dtbalanco AS dt_movto,
        bal.hora AS hora_movto,
        bal.balanco AS est_fisico,
        bal.entregar AS est_entregar,
        bal.codfilial AS codfilial,
        0 AS serie,
        0 AS controle,
        0 AS natureza,
        bal.codusuconfirmacao AS codusu,
        bal.codterminalconfirmacao AS codterminal
    FROM balanco bal
    UNION
    SELECT 2 AS tipo_tabela,
        eni.codfilent AS codfilart,
        eni.codart,
        eni.dtconfirmacao AS dt_movto,
        eni.horaconfirmacao AS hora_movto,
        eni.quantconfirmada AS est_fisico,
        0 AS est_entregar,
        eni.codfilent AS codfilial,
        0 AS serie,
        eni.seqentrada AS controle,
        ent.natureza AS natureza,
        ent.codusu AS codusu,
        ent.terminal AS codterminal
    FROM entitem eni
        INNER JOIN entrada ent ON ent.codfilent = eni.codfilent
        AND ent.seqentrada = eni.seqentrada
    WHERE eni.situacao IN (1, 3)
        AND eni.dtconfirmacao >= 0
    UNION
    SELECT 3 AS tipo_tabela,
        pti.codfilial AS codfilart,
        pti.codart,
        ptr.dtmovto AS dt_movto,
        ptr.hora AS hora_movto,
        - pti.quant AS est_fisico,
        COALESCE(pti.entregar, 0) AS est_entregar,
        pti.codfilial AS codfilial,
        pti.serie AS serie,
        pti.codtran AS controle,
        ptr.nat AS natureza,
        ptr.codusucadastro AS codusu,
        ptr.terminal AS codterminal
    FROM pedtrani pti
        INNER JOIN pedtran ptr USING(codfilial, serie, codtran)
    UNION
    SELECT 4 AS tipo_tabela,
        cni.codfilial AS codfilart,
        cni.codart,
        cnd.dtmovto AS dt_movto,
        cnd.hora AS hora_movto,
        - cni.quant AS est_fisico,
        0 AS est_entregar,
        cni.codfilial AS codfilial,
        0 AS serie,
        cni.codcond AS controle,
        0 AS natureza,
        cnd.codusu,
        0 AS codterminal
    FROM conditem cni
        INNER JOIN condicio cnd ON cnd.codfilial = cni.codfilial
        AND cnd.codcond = cni.codcond
    WHERE cnd.situacao IN (2, 3, 4)
    UNION
    SELECT 4 AS tipo_tabela,
        cni.codfilial AS codfilart,
        cni.codart,
        cnd.dtdevolucao AS dt_movto,
        cnd.hora + 1 AS hora_movto,
        cni.quant AS est_fisico,
        0 AS est_entregar,
        cni.codfilial AS codfilial,
        0 AS serie,
        cni.codcond AS controle,
        0 AS natureza,
        cnd.codusu,
        0 AS codterminal
    FROM conditem cni
        INNER JOIN condicio cnd ON cnd.codfilial = cni.codfilial
        AND cnd.codcond = cni.codcond
    WHERE cnd.situacao IN (3, 4)
    UNION
    SELECT 5 AS tipo_tabela,
        codfilart,
        codart,
        dt_movto,
        hora_movto,
        est_fisico,
        est_entregar,
        codfilial,
        serie,
        controle,
        natureza,
        codusu,
        codterminal
    FROM (
            SELECT pdi.codfilial AS codfilart,
                pdi.codart,
                ped.dtmovto AS dt_movto,
                ped.hora AS hora_movto,
                pdi.codfilial AS codfilial,
                pdi.serie AS serie,
                pdi.codped AS controle,
                ped.nat AS natureza,
                SUM(
                    (pdi.quant - COALESCE(pie.quant, 0)) * (
                        CASE
                            pdi.tipomovto
                            WHEN 2 THEN 1
                            ELSE -1
                        END
                    )
                ) AS est_fisico,
                SUM(pdi.entregar - COALESCE(pie.entregar, 0)) AS est_entregar,
                999 AS codusu,
                ped.terminal AS codterminal
            FROM peditem pdi
                INNER JOIN pedido ped ON ped.codfilial = pdi.codfilial
                AND ped.serie = pdi.serie
                AND ped.codped = pdi.codped
                LEFT OUTER JOIN peditest pie ON pie.codfilial = pdi.codfilial
                AND pie.serie = pdi.serie
                AND pie.codped = pdi.codped
                AND pie.codart = pdi.codart
            WHERE pdi.situacao = 1
            GROUP BY pdi.codfilial,
                pdi.serie,
                pdi.codped,
                pdi.codart,
                pdi.tipomovto,
                ped.dtmovto,
                ped.hora,
                ped.nat,
                ped.terminal
            UNION
            SELECT pie.codfilart AS codfilart,
                pdi.codart,
                ped.dtmovto AS dt_movto,
                ped.hora AS hora_movto,
                pdi.codfilial AS codfilial,
                pdi.serie AS serie,
                pdi.codped AS controle,
                ped.nat AS natureza,
                SUM(
                    COALESCE(pie.quant, 0) * (
                        CASE
                            pdi.tipomovto
                            WHEN 2 THEN 1
                            ELSE -1
                        END
                    )
                ) AS est_fisico,
                SUM(COALESCE(pie.entregar, 0)) AS est_entregar,
                999 AS codusu,
                ped.terminal AS codterminal
            FROM peditem pdi
                INNER JOIN pedido ped ON ped.codfilial = pdi.codfilial
                AND ped.serie = pdi.serie
                AND ped.codped = pdi.codped
                LEFT OUTER JOIN peditest pie ON pie.codfilial = pdi.codfilial
                AND pie.serie = pdi.serie
                AND pie.codped = pdi.codped
                AND pie.codart = pdi.codart
            WHERE pdi.situacao = 1
                AND pie.codfilart NOTNULL
            GROUP BY pie.codfilart,
                pdi.codfilial,
                pdi.serie,
                pdi.codped,
                pdi.codart,
                pdi.tipomovto,
                ped.dtmovto,
                ped.hora,
                ped.nat,
                ped.terminal
        ) AS tmp_retorno
    WHERE est_fisico <> 0
    UNION
    SELECT *
    FROM (
            SELECT 6 AS tipo_tabela,
                dvi.codfilial AS codfilart,
                dvi.codart,
                dev.dtmovto AS dt_movto,
                dev.hora AS hora_movto,
                dvi.quantloja AS est_fisico,
                0 AS est_entregar,
                dvi.codfilial AS codfilial,
                0 AS serie,
                dvi.coddev AS controle,
                0 AS natureza,
                dev.codusu,
                dev.codterminal
            FROM devitem dvi
                INNER JOIN devoluca dev ON dev.codfilial = dvi.codfilial
                AND dev.coddev = dvi.coddev
            WHERE dvi.situacao = 1
            UNION
            SELECT 6 AS tipo_tabela,
                dvi.coddeposito AS codfilart,
                dvi.codart,
                dev.dtmovto AS dt_movto,
                dev.hora AS hora_movto,
                dvi.quantdeposito AS est_fisico,
                0 AS est_entregar,
                dvi.codfilial AS codfilial,
                0 AS serie,
                dvi.coddev AS controle,
                0 AS natureza,
                dev.codusu,
                dev.codterminal
            FROM devitem dvi
                INNER JOIN devoluca dev ON dev.codfilial = dvi.codfilial
                AND dev.coddev = dvi.coddev
            WHERE dvi.situacao = 1
        ) AS dvi
    WHERE est_fisico <> 0
    UNION
    SELECT 7 AS tipo_tabela,
        ppm.codfilprod AS codfilart,
        ppm.codartmp AS codart,
        ppr.dtinicio AS dt_movto,
        ppr.horainicio AS hora_movto,
        - ppm.quant AS est_fisico,
        0 AS est_entregar,
        ppm.codfilprod AS codfilial,
        0 AS serie,
        ppm.codprod AS controle,
        0 AS natureza,
        999 AS codusu,
        0 AS codterminal
    FROM pcpprodmp ppm
        INNER JOIN pcpproducao ppr ON ppr.codfilprod = ppm.codfilprod
        AND ppr.codprod = ppm.codprod
        AND ppr.codart = ppm.codart
        AND ppr.coditemprod = ppm.coditemprod
    WHERE ppm.situacao = 1
    UNION
    SELECT 8 AS tipo_tabela,
        mac.codfilos AS codfilart,
        mac.codart,
        ose.dtmovto AS dt_movto,
        ose.hora AS hora_movto,
        - mac.quantidade AS est_fisico,
        0 AS est_entregar,
        mac.codfilos AS codfilial,
        0 AS serie,
        mac.codos AS controle,
        0 AS natureza,
        ose.codusufinalizacao AS codusu,
        ose.terminal AS codterminal
    FROM osmaterialconsumo mac
        INNER JOIN osordemservico ose ON ose.codfilos = mac.codfilos
        AND ose.codos = mac.codos
    WHERE mac.situacao = 1
) loop EXECUTE 'INSERT INTO artmovimento' || src_numero_artmovimento(WRecord.codart) || '(
            seqartmovto, codfilart, codart, tabela, codfilcontrole, seriecontrole, 
            controle, natureza, dtmovto, horamovto, codusu, codterminal, 
            tipooperacao, tipomovto, quantidade, entregar, estoquefisicoatual, 
            estoqueentregaratual, estoqueagendadoatual)
    VALUES (nextval(''seq_artmovimento' || src_numero_artmovimento(WRecord.codart) || ''')::integer, 
            ' || COALESCE(WRecord.codfilart, 0) || ', ' || COALESCE(WRecord.codart, 0) || ', ' || COALESCE(WRecord.tipo_tabela, 0) || ', ' || COALESCE(WRecord.codfilial, 0) || ', ' || COALESCE(WRecord.serie, 0) || ', ' || COALESCE(WRecord.controle, 0) || ', ' || COALESCE(WRecord.natureza, 0) || ', ' || COALESCE(WRecord.dt_movto, 0) || ', ' || COALESCE(WRecord.hora_movto, 0) || ', ' || COALESCE(WRecord.codusu, 0) || ', ' || COALESCE(WRecord.codterminal, 0) || ', 1, ' || CASE
    WHEN COALESCE(WRecord.est_fisico, 0) > 0 THEN 1
    ELSE 2
END || ', ' || COALESCE(WRecord.est_fisico, 0) || ', ' || COALESCE(WRecord.est_entregar, 0) || ', 0, 0, 0);';
end loop;
end;
$BODY$ LANGUAGE plpgsql VOLATILE STRICT COST 100;
ALTER FUNCTION public.src_recriar_artmovimento() OWNER TO postgres;