SELECT DISTINCT ret.codfilial, 
       ret.codped, 
       ret.dtmovto, 
       CASE EXTRACT(MONTH FROM dataclarion(ret.dtmovto)::date) 
          WHEN 1 THEN 'Janeiro' 
          WHEN 2 THEN 'Fevereiro' 
          WHEN 3 THEN 'Março' 
          WHEN 4 THEN 'Abril' 
          WHEN 5 THEN 'Maio' 
          WHEN 6 THEN 'Junho' 
          WHEN 7 THEN 'Julho' 
          WHEN 8 THEN 'Agosto' 
          WHEN 9 THEN 'Setembro' 
          WHEN 10 THEN 'Outubro' 
          WHEN 11 THEN 'Novembro' 
          WHEN 12 THEN 'Dezembro' 
          ELSE 'Erro ao localizar mês.' 
       END  || '/' || EXTRACT (YEAR FROM dataclarion(ret.dtmovto)::date), 
       TO_CHAR(cli.codcli,'99999999') ||'-'|| cli.razao, 
       cli.endereco || CASE WHEN COALESCE(cli.numero,0) = 0 THEN '' ELSE ', ' || cli.numero END, 
       upper(to_ascii(cli.cidade)), 
       cli.uf, 
       art.descricao, 
       ret.quant, 
       ret.valor * CASE WHEN ret.tipomovto = 1 THEN 1 ELSE -1 END, 
       ret.pdivlrvenda, 
       ret.pdivlrvenda  + (ret.pdivlrfinal - ret.pdivlrvenda) + ret.pdivlrbruto * src_inddesc_pedido(ret.codfilial, ret.serie, ret.codped, 0, 0, 0, -ped.valorfinanc, 0, 0, 0) / 100, 
       cli.fone, 
       (SELECT MAX(pedd.dtmovto) FROM pedido pedd WHERE pedd.codfilial = ret.codfilial AND pedd.serie = ret.serie AND pedd.codped = ret.codped), 
       cli.fantasia, 
       ret.quant * CASE WHEN ret.tabela IN(1,4) THEN art.Quantemb ELSE -art.Quantemb END, 
       art.referencia, 
       ar2.estoque - ar2.entregar + produto_agendado(ar2.codfilial, ar2.codart, 0, 0), 
       TO_CHAR(ret.codfilial,'FM00') || TO_CHAR(ret.serie,'FM00') ||TO_CHAR(ret.codped,'FM00000000') || TO_CHAR(ret.tabela,'FM00') ||TO_CHAR(ret.codart,'FM00000000') || TO_CHAR(ret.coddev,'FM00000000'), 
       TO_CHAR(COALESCE(rma.codfilial,0),'FM00') || TO_CHAR(COALESCE(rma.codromaneio,0),'FM00000000') || RPAD((CASE COALESCE(rma.quant,-1) WHEN -1 THEN ret.quant ELSE rma.quant END)::varchar,15,' ') || RPAD(art.peso::varchar,15,' ') || RPAD(ret.pdivlrvenda::varchar,15,' '),
       0, ret.pdivlrbruto * src_inddesc_pedido(ret.codfilial, ret.serie, ret.codped, ped.inddesc, ped.valordesc, 0, 0, 0, 0, 0) / 100
       , 
 ret.codfilial, ret.serie, ret.codped FROM (
    (SELECT DISTINCT 1 AS tabela,
        pdi.codfilial,
        pdi.serie,
        pdi.codped,
        pdi.codart,
        0 AS coddev,
        pdi.tipomovto,
        pdi.indcomissao,
        pdi.indcomissao2,
        pdi.indcomissao4,
        pdi.ordem,
        CASE WHEN pdi.tipomovto = 2 THEN -pdi.quant ELSE pdi.quant END AS quant,
        pdi.entregar,
        pdi.custo,
        pdi.precooriginal,
        pdi.venda AS pdivlrunit,
        pdi.valor,
        pdi.complemento,
        pdi.situacao,
        pdi.coddesconto,
        pdi.codmotdev,
        pdi.valorfrete,
        pdi.codmotcanc,
        pdi.promocao AS promocao,
        ped.codvend AS codvend,
        ped.dtmovto,
        ped.hora,
        ped.codpagto,
        CASE ped.nat WHEN 1 THEN 'A vista'
                     WHEN 2 THEN 'A prazo'
                     WHEN 3 THEN 'Venda programada'
                     WHEN 4 THEN 'Troca'
                     WHEN 5 THEN 'Serviço'
                     WHEN 6 THEN 'Orçamento'
                     WHEN 7 THEN 'Bonificação'
                     ELSE '' END AS natureza, 
         CASE ped.flag WHEN 0 THEN
                      CASE WHEN ped.dtfinalseparacao > 0 THEN 'Separado'
                           ELSE CASE WHEN ped.dtinicioSeparacao > 0 THEN 'Separação Iniciada'
                           ELSE 'Não baixado' END END
                      WHEN 1 THEN 'Cancelado'
                      WHEN 2 THEN 'Baixado parcial'
                      WHEN 3 THEN 'Baixado total' END AS pedflag,
        pdi.quant * (CASE WHEN pdi.tipomovto = 2 THEN -pdi.valor ELSE pdi.valor END) AS pdivlrbruto,
        (((pdi.quant * (CASE WHEN pdi.tipomovto = 2 THEN -pdi.valor  ELSE pdi.valor  END +
        ((CASE WHEN pdi.tipomovto = 2 THEN -pdi.valor ELSE pdi.valor END) / 100 *
        src_inddesc_pedido(pdi.codfilial, pdi.serie, pdi.codped, (ped.inddesc + ped.indcomissao), ped.valordesc, 0, 0, 0, 0, 0)))))) AS pdivlrvenda,
        (pdi.quant * (CASE WHEN pdi.tipomovto = 2 THEN -pdi.valor  ELSE pdi.valor  END +
        (((CASE WHEN pdi.tipomovto = 2 THEN -pdi.valor ELSE pdi.valor END) / 100) *
        src_inddesc_pedido(pdi.codfilial, pdi.serie, pdi.codped, (ped.inddesc + ped.indcomissao), ped.valordesc, COALESCE(ose.credcli * ped.total / (CASE WHEN ped.total = 0 THEN 1 ELSE ped.total END + (SELECT SUM(osi.preco * osi.quantidade) FROM osservitem osi WHERE osi.codfilos = ose.codfilos AND osi.codos = ose.codos)),0) + ped.credcli, 0, 0, 0, 0))) ) AS pdivlrfinal,
        pdi.quant * (CASE WHEN pdi.tipomovto = 2 THEN -pdi.valor ELSE pdi.valor END) / 100 *
        src_inddesc_pedido(pdi.codfilial, pdi.serie, pdi.codped, ped.indcomissao, 0, 0, 0, 0, 0, 0) AS vlrcomissaocliente,
        pdi.indipi,
        pdi.indsubstituicao,
        ped.valorfretecif,
        ped.valorfretefob,
        ped.inddescespecial,
        ped.inddesc,
        ped.valordesc,
        pdi.codfillistapresentes,
        pdi.codlistapresentes,
        pdi.ciffob,
        pdi.customedio,
        pdi.valor AS valorunit,
        pdi.mce AS mce, 
        pdi.valormce AS valorMCE, 
        CASE WHEN ped.nat = 1 AND ped.indcomissao = 0 THEN 'A Vista (V)' ELSE 
             CASE WHEN ped.indcomissao <> 0 THEN 'Comissionado (B)' ELSE 
             CASE WHEN ped.nat <> 1 AND ped.indcomissao = 0 THEN 'Sem Comissao (L)' 
                END 
             END 
        END AS bruto_liquido, 
        pdi.codfilgtp, 
        pdi.codgtp 
     FROM peditem pdi
     INNER JOIN pedido ped USING(codfilial, serie, codped)
     LEFT OUTER JOIN osservped osp ON osp.codfilial = pdi.codfilial AND osp.serie = pdi.serie AND osp.codped = pdi.codped AND osp.codart = pdi.codart
     LEFT OUTER JOIN osordemservico ose ON ose.codfilos = osp.codfilos AND ose.codos = osp.codos AND ose.cancelado <> 1 
     LEFT OUTER JOIN Fatped fpd ON ped.codfilial = fpd.codfilped AND ped.serie = fpd.serie AND ped.codped = fpd.codped
     LEFT OUTER JOIN Fatura fat ON fpd.codfilial = fat.codfilial AND fpd.seriefat = fat.seriefat AND fpd.codfat = fat.codfat
    LEFT OUTER JOIN cupped cpp ON cpp.codfilped = pdi.codfilial AND cpp.serieped = pdi.serie AND cpp.codped = pdi.codped
    LEFT OUTER JOIN cupom cup ON cup.codfilcupom = cpp.codfilcupom AND cup.codimpfiscal = cpp.codimpfiscal AND cup.nrcupomfiscal = cpp.nrcupomfiscal
     WHERE  ((pdi.codfilial = 1) OR (1 = 0)) AND ped.serie <> 9 )
) AS ret
 INNER JOIN Pedido ped ON ped.codfilial = ret.codfilial AND ped.serie = ret.serie AND ped.codped = ret.codped
 INNER JOIN Artigo1 art ON art.codart = ret.codart
 LEFT OUTER JOIN cliente cli ON cli.codfilial = ped.codfilcli AND cli.codcli = ped.codcli
 LEFT OUTER JOIN romanitem rmi ON rmi.codfilial = ret.codfilial AND rmi.codfilmov = ret.codfilial AND rmi.serie = ret.serie AND rmi.controle = ret.codped AND rmi.situacao > 0
 LEFT OUTER JOIN romanart rma ON rma.codfilial = rmi.codfilial AND rma.codromaneio = rmi.codromaneio AND
    rma.codfilmov = rmi.codfilmov AND rma.serie = rmi.serie AND
    rma.controle = rmi.controle AND rma.codart = ret.codart
 LEFT OUTER JOIN tabunidade tun ON tun.codunidade = art.codunidade
 LEFT OUTER JOIN Artigo2 ar2 ON ar2.codfilial = ret.codfilial AND ar2.codart = ret.codart
 
WHERE      COALESCE(ret.codfilial,0) IN (1) AND COALESCE(ret.codfilial,0) = 1 AND COALESCE(ret.codfilial,0) IN (1) AND COALESCE(ret.tabela,0) <> 2  AND cli.isento IN (0,1,2) 
ORDER BY ret.codfilial, ret.serie, ret.codped