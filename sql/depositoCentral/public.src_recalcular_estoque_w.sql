-- Function: public.src_recalcular_estoque_w(integer, integer)

-- DROP FUNCTION public.src_recalcular_estoque_w(integer, integer);

CREATE OR REPLACE FUNCTION public.src_recalcular_estoque_w(
    p_codfilial integer,
    p_codart integer)
  RETURNS integer AS
$BODY$
DECLARE
  WDtMenorMovimento  INTEGER;
  WDtMaiorMovimento  INTEGER;
  WDtFechamento      INTEGER;
  WDtMovto           INTEGER DEFAULT 0;
  WSaldo             NUMERIC DEFAULT 0;
  X                  RECORD;
  WEstoque           NUMERIC DEFAULT 0;
  WEntregar          NUMERIC DEFAULT 0;
  WLinhaSQL          TEXT;
  WUltimoMovto       NUMERIC DEFAULT 0;
  WAgendado          NUMERIC DEFAULT 0;
  WEntregue          NUMERIC DEFAULT 0;   
  WEntregueTrans     NUMERIC DEFAULT 0;   
BEGIN
   --Verificar se todas as movimentações se encontram na artmovimento, se não existir então insere
   PERFORM src_verificar_artmovimento(p_codfilial, p_codart);
  -- PERFORM src_verificar_artmovimento_contabil(p_codfilial, p_codart);

   --Apagar artfecha e recriar
    DELETE 
     FROM artfecha
    WHERE codfilial = p_codfilial
      AND codart    = p_codart;

   --Buscar a menor data de movimentação para iniciar a artfecha
    EXECUTE 'SELECT MIN(ret.menordata)
               FROM (SELECT MIN(dtmovto) AS menordata
                       FROM artmovimento'||src_numero_artmovimento(p_codart)||'
                      WHERE codfilart = '|| p_codfilial ||'
                        AND codart    = '|| p_codart ||'
                        AND dtmovto > 0
                      UNION
                     SELECT MIN(dtmovto) AS menordata
                       FROM artmovimentocontabil'||src_numero_artmovimento(p_codart)||'
                      WHERE codfilart = '|| p_codfilial ||'
                        AND codart    = '|| p_codart || '
                        AND dtmovto > 0) AS ret'
       INTO WDtMenorMovimento;

   IF WDtMenorMovimento > 0 THEN
      --Vai criar a artfecha até o mes corrente
       SELECT src_ultimo_dia_mes(dataatual()) --Primeiro dia do mes atual
         INTO WDtMaiorMovimento;
    
      --Inserir artfecha com o primeiro dia de cada mes independente da movimentação
       SELECT src_ultimo_dia_mes(WDtMenorMovimento) --1º mes do fechamento
         INTO WDtFechamento;

       INSERT INTO artfecha VALUES (p_codfilial, p_codart, WDtFechamento, 0, 0, 0);

       WHILE WDtFechamento < WDtMaiorMovimento LOOP
          SELECT src_ultimo_dia_mes(formatar_data(date_trunc('month', date(dataclarion(WDtFechamento)) + INTERVAL '1 month')::date)) --Ultimo dia do proximo mes
            INTO WDtFechamento;

          INSERT INTO artfecha VALUES (p_codfilial, p_codart, WDtFechamento, 0, 0, 0);
        END LOOP;

      --************FISICO************
       WDtMovto = 0;
       WSaldo   = 0;
      --Atualizar saldo do estoque fisico da artfecha
       FOR X IN SELECT dt_movto,
                       saldo,
                       tipo_tabela,
                       est_fisico,
                       est_entregar,
                       tipooperacao,
					   hora_movto
                  FROM src_historico_produto(p_codfilial, p_codart, 0) 
                 ORDER BY dt_movto, hora_movto
       LOOP
          IF X.tipo_tabela = 1 THEN
             IF x.tipooperacao <> 3 THEN
                WEstoque  = X.est_fisico;
                IF X.est_entregar > 0 THEN
                   select COALESCE(SUM(entregue),0) INTO WEntregue from pedbaixa where dtmovto >= X.dt_movto AND hora > X.hora_movto and codart = p_codart and codfilial = p_codfilial ;

                   select COALESCE(SUM(entregue),0) INTO WEntregueTrans from pedtranbaixa where dtmovto >= X.dt_movto AND hora > X.hora_movto and codart = p_codart and codfilial = p_codfilial ;
                   WEntregar = X.est_entregar - WEntregue - WEntregueTrans; 
                   WEstoque = X.est_fisico - WEntregue - WEntregueTrans; 
                END if;
             END IF;
          ELSE
               
             WEstoque  = CASE X.tipo_tabela WHEN 1 THEN X.est_fisico ELSE WEstoque + X.est_fisico END;
             WEntregar = CASE X.tipo_tabela WHEN 1 THEN X.est_entregar ELSE WEntregar + X.est_entregar END;
            
          END IF;
          
          IF COALESCE(WDtMovto,0) <> 0 THEN 
             IF (mes(X.dt_movto) <> mes(WDtMovto) OR anoatual(X.dt_movto) <> anoatual(WDtMovto)) THEN
                 UPDATE artfecha 
                    SET estoque      = WSaldo
                  WHERE codfilial    = p_codfilial 
                    AND codart       = p_codart 
                    AND dtfechamento >= src_ultimo_dia_mes(WDtMovto);
             END IF;
          END IF;

          WDtMovto     = X.dt_movto;
          WSaldo       = X.saldo;
          WUltimoMovto = CASE WHEN X.tipo_tabela <> 1 THEN X.est_fisico - X.est_entregar END;
       END LOOP;

       IF WDtMovto <> 0 THEN
          UPDATE artfecha 
             SET estoque       = WSaldo
           WHERE codfilial     = p_codfilial 
             AND codart        = p_codart 
             AND dtfechamento >= src_ultimo_dia_mes(WDtMovto);
       END IF;
/*
       --************CONTABIL************
       WDtMovto = 0;
       WSaldo   = 0;
      --Atualizar saldo do estoque contábil da artfecha
       FOR X IN SELECT dt_movto,
                       saldo,
                       tipo_tabela,
                       est_fisico
                  FROM src_historico_produto_contabil(p_codfilial, p_codart, 0) 
                 ORDER BY dt_movto, hora_movto
       LOOP
          IF COALESCE(WDtMovto,0) <> 0 THEN 
             IF (mes(X.dt_movto) <> mes(WDtMovto) OR anoatual(X.dt_movto) <> anoatual(WDtMovto)) THEN
                 UPDATE artfecha 
                    SET estoquecontabil = WSaldo
                  WHERE codfilial       = p_codfilial 
                    AND codart          = p_codart 
                    AND dtfechamento   >= src_ultimo_dia_mes(WDtMovto);
             END IF;
          END IF;

          WDtMovto = X.dt_movto;
          WSaldo   = X.saldo;
       END LOOP;

       IF WDtMovto <> 0 THEN
          UPDATE artfecha 
             SET estoquecontabil = WSaldo
           WHERE codfilial       = p_codfilial 
             AND codart          = p_codart 
             AND dtfechamento   >= src_ultimo_dia_mes(WDtMovto);
       END IF;
       raise info '4 WEntregar = % WEstoque = % ' , WEntregar, WEstoque;

 */      
      --Atualizar saldos da artigo2
       UPDATE artigo2 
          SET estoque     = WEstoque,
              entregar    = WEntregar -- + WAgendado,
--              estcontabil = WSaldo
        WHERE codfilial   = p_codfilial
          AND codart      = p_codart;

      --************CUSTO MÉDIO CONTÁBIL************
--       PERFORM src_calcular_custo_medio_contabil(p_codfilial, p_codart, 0, 0, '', 1);
      --************
    END IF;
    
    RETURN 1;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.src_recalcular_estoque_w(integer, integer)
  OWNER TO postgres;
