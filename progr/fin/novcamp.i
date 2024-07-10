def {1} shared temp-table ttcontrato no-undo
    field marca     as log format "*/ "
    field CAMcod       like novcampanha.camcod
    field contnum       like contrato.contnum
    field tpcontrato    like contrato.tpcontrato
    field vlr_aberto    as dec
    field vlr_divida    as dec
    field vlr_custas    as dec
    field pagaCustas    like novcampanha.pagaCustas
    field vlr_parcela   as dec
    field dt_venc       as date
    field dias_atraso   as int
    field qtd_pagas     as int
    field qtd_parcelas  as int
    field perc_pagas    as dec
    field vlr_vencido   as dec
    field vlr_vencer    as dec
    field trectitprotesto as recid
    index idx is unique primary  camcod asc contnum asc.

def {1} shared temp-table ttcampanha no-undo
    field camcod    like novcampanha.camcod
    field qtd       as int 
    field vlr_aberto like ttcontrato.vlr_aberto
    field vlr_divida like ttcontrato.vlr_divida
    field vlr_custas like ttcontrato.vlr_custas     
    field qtd_selecionado as int 
    field vlr_selaberto   like ttcontrato.vlr_aberto
    field pagaCustas      like novcampanha.pagaCustas   
    field vlr_selcustas   like ttcontrato.vlr_custas
    field vlr_seldivida   like ttcontrato.vlr_divida
    field vlr_selecionado like ttcontrato.vlr_divida
    
    field dt_venc        like ttcontrato.dt_venc
    field dias_atraso   like ttcontrato.dias_atraso
    index idx is unique primary  CAMcod asc.

