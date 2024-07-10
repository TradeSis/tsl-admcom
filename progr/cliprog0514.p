{admcab.i}

def buffer tt-venda for tabdicem.
def buffer tt-receb for tabdicre.

DEFINE temp-table tt-total  no-undo
  FIELD acrescimo_cancelamento_fdrebes   AS DECIMAL     DECIMALS 2
  FIELD acrescimo_fdrebes                AS DECIMAL     DECIMALS 2
  FIELD acrescimo_lebes                  AS DECIMAL     DECIMALS 2
  FIELD acrescimo_novacao                AS DECIMAL     DECIMALS 2
  FIELD acrescimo_novacao_fdrebes        AS DECIMAL     DECIMALS 2
  FIELD acrescimo_novacao_lebes          AS DECIMAL     DECIMALS 2
  FIELD acrescimo_venda_outras           AS DECIMAL     DECIMALS 2
  FIELD acrescimo_venda_semcupom         AS DECIMAL     DECIMALS 2
  FIELD cancelamentos_fdrebes            AS DECIMAL     DECIMALS 2
  FIELD cancelamentos_lebes              AS DECIMAL     DECIMALS 2
  FIELD compra_ativos_fdrebes            AS DECIMAL     DECIMALS 2
  FIELD DatRef                           AS DATE        FORMAT "99/99/9999" 
  LABEL "DatRef"
  FIELD define_recebimento_entrada_moeda AS CHARACTER   EXTENT 15 FORMAT "x(20)"
  FIELD define_recebimento_moeda         AS CHARACTER   EXTENT 15 FORMAT "x(20)"
  FIELD define_receb_cpess               AS CHARACTER   EXTENT 15 FORMAT "x(30)"
  FIELD define_receb_seguro              AS CHARACTER   EXTENT 15 FORMAT "x(30)"
  FIELD define_venda_cpess               AS CHARACTER   EXTENT 15 FORMAT "x(30)"
  FIELD define_venda_moeda               AS CHARACTER   EXTENT 15 FORMAT "x(20)"
  FIELD define_venda_recarga             AS CHARACTER   EXTENT 15 FORMAT "x(20)"
  FIELD define_venda_seguro              AS CHARACTER   EXTENT 15 FORMAT "x(30)"
  FIELD devolucao_prazo                  AS DECIMAL     DECIMALS 2
  FIELD devolucao_vista                  AS DECIMAL     DECIMALS 2
  FIELD estgornos_lebes                  AS DECIMAL     DECIMALS 2
  FIELD estorno_cancelamento_fdrebes     AS DECIMAL     DECIMALS 2
  FIELD estorno_devolucao                AS DECIMAL     DECIMALS 2
  FIELD etbcod                           AS INTEGER     FORMAT ">>9" 
  LABEL "Filial"
  FIELD juros_fdrebes                    AS DECIMAL     DECIMALS 2
  FIELD juros_lebes                      AS DECIMAL     DECIMALS 2
  FIELD moeda_fdrebes                    AS DECIMAL     EXTENT 10 DECIMALS 2
  FIELD moeda_lebes                      AS DECIMAL     EXTENT 10 DECIMALS 2
  FIELD novacao_fdrebes                  AS DECIMAL     DECIMALS 2
  FIELD novacao_lebes                    AS DECIMAL     DECIMALS 2
  FIELD recebimento_acrescimo_fdrebes    AS DECIMAL     DECIMALS 2
  FIELD recebimento_acrescimo_lebes      AS DECIMAL     DECIMALS 2
  FIELD recebimento_acrescimo_novacao    AS DECIMAL     DECIMALS 2
  FIELD recebimento_entrada              AS DECIMAL     DECIMALS 2
  FIELD recebimento_entrada_moeda        AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD recebimento_fdrebes              AS DECIMAL     DECIMALS 2
  FIELD recebimento_forasaldo            AS DECIMAL     DECIMALS 2
  FIELD recebimento_incobraveis          AS DECIMAL     DECIMALS 2
  FIELD recebimento_juros_fdrebes        AS DECIMAL     DECIMALS 2
  FIELD recebimento_juros_lebes          AS DECIMAL     DECIMALS 2
  FIELD recebimento_lebes                AS DECIMAL     DECIMALS 2
  FIELD recebimento_moeda_fdrebes        AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD recebimento_moeda_lebes          AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD recebimento_novacao              AS DECIMAL     DECIMALS 2
  FIELD recebimento_principal_fdrebes    AS DECIMAL     DECIMALS 2
  FIELD recebimento_principal_lebes      AS DECIMAL     DECIMALS 2
  FIELD recebimento_principal_novacao    AS DECIMAL     DECIMALS 2
  FIELD receb_cpess                      AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD receb_moeda_acrescimo_fdrebes    AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD receb_moeda_acrescimo_lebes      AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD receb_moeda_juros_fdrebes        AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD receb_moeda_juros_lebes          AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD receb_moeda_principal_fdrebes    AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD receb_moeda_principal_lebes      AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD receb_seguro                     AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD valor_novacao                    AS DECIMAL     DECIMALS 2
  FIELD venda_cpess                      AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD venda_cpess_fdrebes              AS DECIMAL     DECIMALS 2
  FIELD venda_cpess_lebes                AS DECIMAL     DECIMALS 2
  FIELD venda_cpess_novacao              AS DECIMAL     DECIMALS 2
  FIELD venda_cpresente                  AS DECIMAL     DECIMALS 2
  FIELD venda_moeda                      AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD venda_prazo_adicional            AS DECIMAL     DECIMALS 2
  FIELD venda_prazo_fdrebes              AS DECIMAL     DECIMALS 2
  FIELD venda_prazo_lebes                AS DECIMAL     DECIMALS 2
  FIELD venda_prazo_outras               AS DECIMAL     DECIMALS 2
  FIELD venda_prazo_semcupom             AS DECIMAL     DECIMALS 2
  FIELD venda_recarga                    AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD venda_seguro                     AS DECIMAL     EXTENT 15 DECIMALS 2
  FIELD venda_seguro_fdrebes             AS DECIMAL     DECIMALS 2
  FIELD venda_seguro_lebes               AS DECIMAL     DECIMALS 2
  FIELD venda_seguro_novacao             AS DECIMAL     DECIMALS 2
  FIELD venda_vista                      AS DECIMAL     DECIMALS 2
  field recebimento_novacao_lebes        AS DECIMAL     DECIMALS 2
  field recebimento_novacao_fdrebes      AS DECIMAL     DECIMALS 2
  field rec_principal_novacao_lebes      AS DECIMAL     DECIMALS 2
  field rec_principal_novacao_fdrebes    AS DECIMAL     DECIMALS 2
  field rec_acrescimo_novacao_lebes      AS DECIMAL     DECIMALS 2
  field rec_acrescimo_novacao_fdrebes    AS DECIMAL     DECIMALS 2
    .

def var vi as int.
def var va as int.
def var vb as int.
def shared var vdti as date.
def shared var vdtf as date.
disp vdti vdtf.

def var ok-venda as log.
def var ok-recebimento as log.
def var ok-entrada as log.
def var ok-recarga as log.
def var ok-seguro as log.
def var ok-crepes as log.
find first tt-venda where
           tt-venda.datref >= vdti and
           tt-venda.datref <= vdtf 
           no-lock no-error.
if not avail tt-venda
then do:
    bell.
    Message color red/with
    "Processamento para período de " vdti " Até " vdtf skip
    " ainda não foi realizado, impossível gerar relatório."
    view-as alert-box.
    return.
end.               
           
create tt-total.

if vdtf < 01/01/15
then do:
for each tt-venda where tt-venda.datref >= vdti and
                        tt-venda.datref <= vdtf no-lock:
    assign
        tt-total.venda_vista = tt-total.venda_vista +
                               tt-venda.venda_vista
        tt-total.venda_cpresente  = tt-total.venda_cpresente +
                                    tt-venda.venda_cpresente 
        tt-total.venda_prazo_lebes = tt-total.venda_prazo_lebes + 
                                     tt-venda.venda_prazo_lebes
        tt-total.venda_prazo_fdrebes = tt-total.venda_prazo_fdrebes +
                                       tt-venda.venda_prazo_fdrebes
        tt-total.acrescimo_lebes = tt-total.acrescimo_lebes +
                                   tt-venda.acrescimo_lebes
        tt-total.acrescimo_fdrebes = tt-total.acrescimo_fdrebes +
                                    tt-venda.acrescimo_fdrebes
        tt-total.novacao_lebes = tt-total.novacao_lebes + 
                                 tt-venda.novacao_lebes
        tt-total.novacao_fdrebes = tt-total.novacao_fdrebes +
                                   tt-venda.novacao_fdrebes
        tt-total.acrescimo_novacao_lebes = tt-total.acrescimo_novacao_lebes +
                                           tt-venda.acrescimo_novacao_lebes
        tt-total.acrescimo_novacao_fdrebes = tt-total.acrescimo_novacao_fdrebes
                                    + tt-venda.acrescimo_novacao_fdrebes
        tt-total.devolucao_vista = tt-total.devolucao_vista + 
                                   tt-venda.devolucao_vista
        tt-total.devolucao_prazo = tt-total.devolucao_prazo + 
                                   tt-venda.devolucao_prazo
        tt-total.estorno_devolucao = tt-total.estorno_devolucao +
                                     tt-venda.estorno_devolucao
        tt-total.recebimento_lebes = tt-total.recebimento_lebes +
                                     tt-venda.recebimento_lebes
        tt-total.recebimento_principal_lebes = 
                tt-total.recebimento_principal_lebes +
                                     tt-venda.recebimento_principal_lebes
        tt-total.recebimento_acrescimo_lebes = 
                tt-total.recebimento_acrescimo_lebes +
                                     tt-venda.recebimento_acrescimo_lebes
        tt-total.recebimento_fdrebes = tt-total.recebimento_fdrebes +
                                     tt-venda.recebimento_fdrebes
        tt-total.recebimento_principal_fdrebes = 
                tt-total.recebimento_principal_fdrebes +
                               tt-venda.recebimento_principal_fdrebes
        tt-total.recebimento_acrescimo_fdrebes = 
                    tt-total.recebimento_acrescimo_fdrebes +
                             tt-venda.recebimento_acrescimo_fdrebes
        tt-total.recebimento_entrada = tt-total.recebimento_entrada +
                                       tt-venda.recebimento_entrada
        tt-total.recebimento_novacao = tt-total.recebimento_novacao +
                                       tt-venda.recebimento_novacao
        tt-total.recebimento_principal_novacao = 
                tt-total.recebimento_principal_novacao +
                               tt-venda.recebimento_principal_novacao
        tt-total.recebimento_acrescimo_novacao = 
                tt-total.recebimento_acrescimo_novacao +
                               tt-venda.recebimento_acrescimo_novacao
        tt-total.juros_lebes = tt-total.juros_lebes +
                               tt-venda.juros_lebes        
        tt-total.juros_fdrebes = tt-total.juros_fdrebes +
                                 tt-venda.juros_fdrebes
        tt-total.recebimento_incobraveis = tt-total.recebimento_incobraveis +
                                           tt-venda.recebimento_incobraveis 
        tt-total.recebimento_forasaldo = tt-total.recebimento_forasaldo +
                                         tt-venda.recebimento_forasaldo  
        tt-total.cancelamentos_fdrebes = tt-total.cancelamentos_fdrebes +
                                         tt-venda.cancelamentos_fdrebes
        tt-total.acrescimo_cancelamento_fdrebes = 
                tt-total.acrescimo_cancelamento_fdrebes + 
                tt-venda.acrescimo_cancelamento_fdrebes
        tt-total.estorno_cancelamento_fdrebes =
                tt-total.estorno_cancelamento_fdrebes +
                tt-venda.estorno_cancelamento_fdrebes
        tt-total.venda_prazo_adicional = tt-total.venda_prazo_adicional + 
                                         tt-venda.venda_prazo_adicional
        tt-total.venda_prazo_semcupom  = tt-total.venda_prazo_semcupom +
                                         tt-venda.venda_prazo_semcupom
        tt-total.acrescimo_venda_semcupom = 
                                tt-total.acrescimo_venda_semcupom +
                                        tt-venda.acrescimo_venda_semcupom
        tt-total.venda_prazo_outras = tt-total.venda_prazo_outras +
                                      tt-venda.venda_prazo_outras
        tt-total.acrescimo_venda_outras = tt-total.acrescimo_venda_outras +
                                    tt-venda.acrescimo_venda_outras
                        .
    vi = 0.
    do vi = 1 to 15:
        ok-venda = no.
        if tt-venda.define_venda_moeda[vi] <> ""
        then
        do vb = 1 to 15:
            if tt-total.define_venda_moeda[vb] = ""
            then  tt-total.define_venda_moeda[vb] =
                    tt-venda.define_venda_moeda[vi].
            if tt-total.define_venda_moeda[vb] =
                    tt-venda.define_venda_moeda[vi]
            then do:
                ok-venda = yes.
                leave.
            end.
        end.          
        if ok-venda
        then tt-total.venda_moeda[vb] = tt-total.venda_moeda[vb] +
                                  tt-venda.venda_moeda[vi].
        ok-recarga = no.
        if tt-venda.define_venda_recarga[vi] <> ""
        then 
        do vb = 1 to 15:
            if tt-total.define_venda_recarga[vb] = ""
            then tt-total.define_venda_recarga[vb] =
                tt-venda.define_venda_recarga[vi].
            if tt-total.define_venda_recarga[vb] =
                    tt-venda.define_venda_recarga[vi]
            then do:
                ok-recarga = yes.
                leave.
            end.
        end.    
        if ok-recarga
        then tt-total.venda_recarga[vb] = tt-total.venda_recarga[vb] +
                                    tt-venda.venda_recarga[vi].
        ok-seguro = no.
        if tt-venda.define_venda_seguro[vi] <> ""
        then 
        do vb = 1 to 15:
            if tt-total.define_venda_seguro[vb] = ""
            then tt-total.define_venda_seguro[vb] =
                tt-venda.define_venda_seguro[vi].
            if tt-total.define_venda_seguro[vb] =
                    tt-venda.define_venda_seguro[vi]
            then do:
                ok-seguro = yes.
                leave.
            end.
        end.    
        if ok-seguro
        then tt-total.venda_seguro[vb] = tt-total.venda_seguro[vb] +
                                    tt-venda.venda_seguro[vi].
        
        ok-crepes = no.
        if tt-venda.define_venda_cpess[vi] <> ""
        then 
        do vb = 1 to 15:
            if tt-total.define_venda_cpess[vb] = ""
            then tt-total.define_venda_cpess[vb] =
                tt-venda.define_venda_cpess[vi].
            if tt-total.define_venda_cpess[vb] =
                    tt-venda.define_venda_cpess[vi]
            then do:
                ok-crepes = yes.
                leave.
            end.
        end.    
        if ok-crepes
        then tt-total.venda_cpess[vb] = tt-total.venda_cpess[vb] +
                                    tt-venda.venda_cpess[vi].
 
        ok-recebimento = no.
        if tt-venda.define_recebimento_moeda[vi] <> ""
        then
        do vb = 1 to 15:
            if tt-total.define_recebimento_moeda[vb] = ""
            then tt-total.define_recebimento_moeda[vb] =
                    tt-venda.define_recebimento_moeda[vi].
            if tt-total.define_recebimento_moeda[vb] =
                    tt-venda.define_recebimento_moeda[vi]
            then do:
                ok-recebimento = yes.
                leave.
            end.
        end.    
        if ok-recebimento
        then assign
             tt-total.recebimento_moeda_lebes[vb] =         
                    tt-total.recebimento_moeda_lebes[vb] +
                    tt-venda.recebimento_moeda_lebes[vi]
             tt-total.receb_moeda_principal_lebes[vb] =         
                    tt-total.receb_moeda_principal_lebes[vb] +
                    tt-venda.receb_moeda_principal_lebes[vi]
             tt-total.receb_moeda_acrescimo_lebes[vb] =         
                    tt-total.receb_moeda_acrescimo_lebes[vb] +
                    tt-venda.receb_moeda_acrescimo_lebes[vi]
             tt-total.receb_moeda_juros_lebes[vb] =         
                    tt-total.receb_moeda_juros_lebes[vb] +
                    tt-venda.receb_moeda_juros_lebes[vi]
             tt-total.recebimento_moeda_fdrebes[vb] =         
                    tt-total.recebimento_moeda_fdrebes[vb] +
                    tt-venda.recebimento_moeda_fdrebes[vi]
             tt-total.receb_moeda_principal_fdrebes[vb] =         
                    tt-total.receb_moeda_principal_fdrebes[vb] +
                    tt-venda.receb_moeda_principal_fdrebes[vi]
             tt-total.receb_moeda_acrescimo_fdrebes[vb] =         
                    tt-total.receb_moeda_acrescimo_fdrebes[vb] +
                    tt-venda.receb_moeda_acrescimo_fdrebes[vi]
             tt-total.receb_moeda_juros_fdrebes[vb] =         
                    tt-total.receb_moeda_juros_fdrebes[vb] +
                    tt-venda.receb_moeda_juros_fdrebes[vi]
                    .
        ok-entrada = no.
        if tt-venda.define_recebimento_entrada_moeda[vi] <> ""
        then
        do vb = 1 to 15:
            if tt-total.define_recebimento_entrada_moeda[vb] = ""
            then tt-total.define_recebimento_entrada_moeda[vb] =
                    tt-venda.define_recebimento_entrada_moeda[vi].
            if tt-total.define_recebimento_entrada_moeda[vb] =
                    tt-venda.define_recebimento_entrada_moeda[vi]
            then do:
                ok-entrada = yes.
                leave.
            end.
        end.    
        if ok-entrada
        then tt-total.recebimento_entrada_moeda[vb] =         
                    tt-total.recebimento_entrada_moeda[vb] +
                    tt-venda.recebimento_entrada_moeda[vi]
                    .
        
    end.
end.
end.
else do:
for each tt-venda where tt-venda.datref >= vdti and
                        tt-venda.datref <= vdtf no-lock:
    assign
        tt-total.venda_vista = tt-total.venda_vista +
                               tt-venda.venda_vista
        tt-total.venda_cpresente  = tt-total.venda_cpresente +
                                    tt-venda.venda_cpresente 
        tt-total.venda_prazo_lebes = tt-total.venda_prazo_lebes + 
                                     tt-venda.venda_prazo_lebes
        tt-total.venda_prazo_fdrebes = tt-total.venda_prazo_fdrebes +
                                       tt-venda.venda_prazo_fdrebes
        tt-total.acrescimo_lebes = tt-total.acrescimo_lebes +
                                   tt-venda.acrescimo_lebes
        tt-total.acrescimo_fdrebes = tt-total.acrescimo_fdrebes +
                                    tt-venda.acrescimo_fdrebes
        tt-total.novacao_lebes = tt-total.novacao_lebes + 
                                 tt-venda.novacao_lebes
        tt-total.novacao_fdrebes = tt-total.novacao_fdrebes +
                                   tt-venda.novacao_fdrebes
        tt-total.acrescimo_novacao_lebes = tt-total.acrescimo_novacao_lebes +
                                           tt-venda.acrescimo_novacao_lebes
        tt-total.acrescimo_novacao_fdrebes = tt-total.acrescimo_novacao_fdrebes
                                    + tt-venda.acrescimo_novacao_fdrebes
        tt-total.devolucao_vista = tt-total.devolucao_vista + 
                                   tt-venda.devolucao_vista
        tt-total.devolucao_prazo = tt-total.devolucao_prazo + 
                                   tt-venda.devolucao_prazo
        tt-total.estorno_devolucao = tt-total.estorno_devolucao +
                                     tt-venda.estorno_devolucao
        tt-total.cancelamentos_fdrebes = tt-total.cancelamentos_fdrebes +
                                         tt-venda.cancelamentos_fdrebes
        tt-total.acrescimo_cancelamento_fdrebes = 
                tt-total.acrescimo_cancelamento_fdrebes + 
                tt-venda.acrescimo_cancelamento_fdrebes
        tt-total.estorno_cancelamento_fdrebes =
                tt-total.estorno_cancelamento_fdrebes +
                tt-venda.estorno_cancelamento_fdrebes
        tt-total.venda_prazo_adicional = tt-total.venda_prazo_adicional + 
                                         tt-venda.venda_prazo_adicional
        tt-total.venda_prazo_semcupom  = tt-total.venda_prazo_semcupom +
                                         tt-venda.venda_prazo_semcupom
        tt-total.acrescimo_venda_semcupom = 
                                tt-total.acrescimo_venda_semcupom +
                                        tt-venda.acrescimo_venda_semcupom
        tt-total.venda_prazo_outras = tt-total.venda_prazo_outras +
                                      tt-venda.venda_prazo_outras
        tt-total.acrescimo_venda_outras = tt-total.acrescimo_venda_outras +
                                    tt-venda.acrescimo_venda_outras
                        .
    vi = 0.
    do vi = 1 to 15:
        ok-venda = no.
        if tt-venda.define_venda_moeda[vi] <> ""
        then
        do vb = 1 to 15:
            if tt-total.define_venda_moeda[vb] = ""
            then  tt-total.define_venda_moeda[vb] =
                    tt-venda.define_venda_moeda[vi].
            if tt-total.define_venda_moeda[vb] =
                    tt-venda.define_venda_moeda[vi]
            then do:
                ok-venda = yes.
                leave.
            end.
        end.          
        if ok-venda
        then tt-total.venda_moeda[vb] = tt-total.venda_moeda[vb] +
                                  tt-venda.venda_moeda[vi].
        ok-recarga = no.
        if tt-venda.define_venda_recarga[vi] <> ""
        then 
        do vb = 1 to 15:
            if tt-total.define_venda_recarga[vb] = ""
            then tt-total.define_venda_recarga[vb] =
                tt-venda.define_venda_recarga[vi].
            if tt-total.define_venda_recarga[vb] =
                    tt-venda.define_venda_recarga[vi]
            then do:
                ok-recarga = yes.
                leave.
            end.
        end.    
        if ok-recarga
        then tt-total.venda_recarga[vb] = tt-total.venda_recarga[vb] +
                                    tt-venda.venda_recarga[vi].
        ok-seguro = no.
        if tt-venda.define_venda_seguro[vi] <> ""
        then 
        do vb = 1 to 15:
            if tt-total.define_venda_seguro[vb] = ""
            then tt-total.define_venda_seguro[vb] =
                tt-venda.define_venda_seguro[vi].
            if tt-total.define_venda_seguro[vb] =
                    tt-venda.define_venda_seguro[vi]
            then do:
                ok-seguro = yes.
                leave.
            end.
        end.    
        if ok-seguro
        then tt-total.venda_seguro[vb] = tt-total.venda_seguro[vb] +
                                    tt-venda.venda_seguro[vi].
        ok-crepes = no.
        if tt-venda.define_venda_cpess[vi] <> ""
        then 
        do vb = 1 to 15:
            if tt-total.define_venda_cpess[vb] = ""
            then tt-total.define_venda_cpess[vb] =
                tt-venda.define_venda_cpess[vi].
            if tt-total.define_venda_cpess[vb] =
                    tt-venda.define_venda_cpess[vi]
            then do:
                ok-crepes = yes.
                leave.
            end.
        end.    
        if ok-crepes
        then tt-total.venda_cpess[vb] = tt-total.venda_cpess[vb] +
                                    tt-venda.venda_cpess[vi].
        
    end.
end.
for each tt-receb where tt-receb.datref >= vdti and
                        tt-receb.datref <= vdtf no-lock:
    assign
        tt-total.recebimento_lebes = tt-total.recebimento_lebes +
                                     tt-receb.recebimento_lebes
        tt-total.recebimento_principal_lebes = 
                tt-total.recebimento_principal_lebes +
                                     tt-receb.recebimento_principal_lebes
        tt-total.recebimento_acrescimo_lebes = 
                tt-total.recebimento_acrescimo_lebes +
                                     tt-receb.recebimento_acrescimo_lebes
        tt-total.recebimento_fdrebes = tt-total.recebimento_fdrebes +
                                     tt-receb.recebimento_fdrebes
        tt-total.recebimento_principal_fdrebes = 
                tt-total.recebimento_principal_fdrebes +
                               tt-receb.recebimento_principal_fdrebes
        tt-total.recebimento_acrescimo_fdrebes = 
                    tt-total.recebimento_acrescimo_fdrebes +
                             tt-receb.recebimento_acrescimo_fdrebes
        tt-total.recebimento_entrada = tt-total.recebimento_entrada +
                                       tt-receb.recebimento_entrada
        tt-total.recebimento_novacao = tt-total.recebimento_novacao +
                                       tt-receb.recebimento_novacao
        tt-total.recebimento_principal_novacao = 
                tt-total.recebimento_principal_novacao +
                               tt-receb.recebimento_principal_novacao
        tt-total.recebimento_acrescimo_novacao = 
                tt-total.recebimento_acrescimo_novacao +
                               tt-receb.recebimento_acrescimo_novacao
        
        tt-total.recebimento_novacao_lebes = 
                tt-total.recebimento_novacao_lebes + 
                tt-receb.recebimento_novacao_lebes
        tt-total.recebimento_novacao_fdrebes = 
                tt-total.recebimento_novacao_fdrebes + 
                tt-receb.recebimento_novacao_fdrebes
        tt-total.rec_principal_novacao_lebes =
          tt-total.rec_principal_novacao_lebes +
                tt-receb.rec_principal_novacao_lebes
        tt-total.rec_principal_novacao_fdrebes =
          tt-total.rec_principal_novacao_fdrebes +
                tt-receb.rec_principal_novacao_fdrebes
        
        tt-total.juros_lebes = tt-total.juros_lebes +
                               tt-receb.juros_lebes        
        tt-total.juros_fdrebes = tt-total.juros_fdrebes +
                                 tt-receb.juros_fdrebes
        tt-total.recebimento_incobraveis = tt-total.recebimento_incobraveis +
                                           tt-receb.recebimento_incobraveis 
        tt-total.recebimento_forasaldo = tt-total.recebimento_forasaldo +
                                         tt-receb.recebimento_forasaldo  
        tt-total.estorno_cancelamento_fdrebes =
                tt-total.estorno_cancelamento_fdrebes +
                tt-receb.estorno_cancelamento_fdrebes
        tt-total.receb_seguro[1] = 
        tt-total.receb_seguro[1] + tt-receb.receb_seguro[1]
        tt-total.receb_cpess[1] = 
        tt-total.receb_cpess[1] + tt-receb.receb_cpess[1]
                         .
    vi = 0.
    do vi = 1 to 15:
        ok-recebimento = no.
        if tt-receb.define_recebimento_moeda[vi] <> ""
        then
        do vb = 1 to 15:
            if tt-total.define_recebimento_moeda[vb] = ""
            then tt-total.define_recebimento_moeda[vb] =
                    tt-receb.define_recebimento_moeda[vi].
            if tt-total.define_recebimento_moeda[vb] =
                    tt-receb.define_recebimento_moeda[vi]
            then do:
                ok-recebimento = yes.
                leave.
            end.
        end.    
        if ok-recebimento
        then assign
             tt-total.recebimento_moeda_lebes[vb] =         
                    tt-total.recebimento_moeda_lebes[vb] +
                    tt-receb.recebimento_moeda_lebes[vi]
             tt-total.receb_moeda_principal_lebes[vb] =         
                    tt-total.receb_moeda_principal_lebes[vb] +
                    tt-receb.receb_moeda_principal_lebes[vi]
             tt-total.receb_moeda_acrescimo_lebes[vb] =         
                    tt-total.receb_moeda_acrescimo_lebes[vb] +
                    tt-receb.receb_moeda_acrescimo_lebes[vi]
             tt-total.receb_moeda_juros_lebes[vb] =         
                    tt-total.receb_moeda_juros_lebes[vb] +
                    tt-receb.receb_moeda_juros_lebes[vi]
             tt-total.recebimento_moeda_fdrebes[vb] =         
                    tt-total.recebimento_moeda_fdrebes[vb] +
                    tt-receb.recebimento_moeda_fdrebes[vi]
             tt-total.receb_moeda_principal_fdrebes[vb] =         
                    tt-total.receb_moeda_principal_fdrebes[vb] +
                    tt-receb.receb_moeda_principal_fdrebes[vi]
             tt-total.receb_moeda_acrescimo_fdrebes[vb] =         
                    tt-total.receb_moeda_acrescimo_fdrebes[vb] +
                    tt-receb.receb_moeda_acrescimo_fdrebes[vi]
             tt-total.receb_moeda_juros_fdrebes[vb] =         
                    tt-total.receb_moeda_juros_fdrebes[vb] +
                    tt-receb.receb_moeda_juros_fdrebes[vi]
                    .
        ok-entrada = no.
        if tt-receb.define_recebimento_entrada_moeda[vi] <> ""
        then
        do vb = 1 to 15:
            if tt-total.define_recebimento_entrada_moeda[vb] = ""
            then tt-total.define_recebimento_entrada_moeda[vb] =
                    tt-receb.define_recebimento_entrada_moeda[vi].
            if tt-total.define_recebimento_entrada_moeda[vb] =
                    tt-receb.define_recebimento_entrada_moeda[vi]
            then do:
                ok-entrada = yes.
                leave.
            end.
        end.    
        if ok-entrada
        then tt-total.recebimento_entrada_moeda[vb] =         
                    tt-total.recebimento_entrada_moeda[vb] +
                    tt-receb.recebimento_entrada_moeda[vi]
                    .
    end.
end.

end.

def var ct-resp as log format "Sim/Nao".
def var varquivo as char.
def var vetbcod like estab.etbcod.

varquivo =  "/admcom/relat/totais-arqclien_" + 
                trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999").
 
def var v_vista as dec.
def var v_recarga as dec.

varquivo = varquivo + ".csv".
output to value(varquivo).

v_vista = 0.
v_recarga = 0.
vi = 0.
do vi = 1 to 15:
        v_vista = v_vista + tt-total.venda_moeda[vi].
        v_recarga = v_recarga + tt-total.venda_recarga[1].
end.    

put  "Venda a VISTA             ;"
    replace(string(tt-total.venda_vista),".",",")
    format "x(15)"
    skip.
vi = 0.
do vi = 1 to 15:
    if tt-total.define_venda_moeda[vi] <> ""
    then  do:
        put "         " 
            tt-total.define_venda_moeda[vi] " ; "
            replace(string(tt-total.venda_moeda[vi]), ".",",")
                     format "x(15)" skip.
    end.
end. 
vi = 0.
do vi = 1 to 15:
    if tt-total.define_venda_recarga[vi] <> ""
    then  do:
        put "         " tt-total.define_venda_recarga[vi] " ; "
            replace(string(tt-total.venda_recarga[vi]),".",",") 
                format "x(15)" skip.
    end.
end.  
vi = 0.
do vi = 1 to 15:
    if tt-total.define_venda_seguro[vi] <> ""
    then  do:
        put "         " tt-total.define_venda_seguro[vi] " ; "
            replace(string(tt-total.venda_seguro[vi]),".",",") 
                format "x(15)" skip.
    end.
end. 
vi = 0.
do vi = 1 to 15:
    if tt-total.define_venda_cpess[vi] <> ""
    then  do:
        put "         " tt-total.define_venda_cpess[vi] " ; "
            replace(string(tt-total.venda_cpess[vi]),".",",") 
                format "x(15)" skip.
    end.
end.       

put  skip "Venda a PRAZO             ;"
     replace(string(tt-total.venda_prazo_lebes + tt-total.venda_prazo_fdrebes +
     tt-total.venda_prazo_adicional + tt-total.venda_prazo_semcupom +
     tt-total.venda_prazo_outras),".",",")  format "x(15)"
     skip "         Venda prazo LEBES             ;"  
     replace(string(tt-total.venda_prazo_lebes),".",",")  format "x(15)"
     skip "                Venda prazo ADICIONAL ;"
     replace(string(tt-total.venda_prazo_adicional),".",",") format "x(15)"
     skip "         Venda parzo FINANCEIRA        ;"
     replace(string(tt-total.venda_prazo_fdrebes),".",",")  format "x(15)"
     /*skip "         Venda prazo ADICIONAL         ;"
     replace(string(tt-total.venda_prazo_adicional),".",",")  format "x(15)"
   */  skip "         Venda prazo SEM CUPOM         ;"
     replace(string(tt-total.venda_prazo_semcupom),".",",")  format "x(15)"
     skip "         Venda prazo OUTRAS            ;"
     replace(string(tt-total.venda_prazo_outras),".",",")  format "x(15)"
     skip "ACRESCIMO venda prazo  ;"
     replace(string(tt-total.acrescimo_lebes + tt-total.acrescimo_fdrebes)
                        ,".",",")  format "x(15)"
     skip "         Acrescimo LEBES             ;"
     replace(string(tt-total.acrescimo_lebes),".",",")  format "x(15)"
     skip "         Acrescimo FINANCEIRA        ;"
     replace(string(tt-total.acrescimo_fdrebes),".",",")  format "x(15)"
     skip "RECEBIMENTOS               ;"
     replace(string(tt-total.recebimento_lebes + tt-total.recebimento_fdrebes +
     tt-total.recebimento_entrada + tt-total.recebimento_novacao),".",",")
       format "x(15)"
     skip "         Recebimentos LEBES             ;"
     replace(string(tt-total.recebimento_lebes),".",",")  format "x(15)"
     skip.
vi = 0.     
do vi = 1 to 15:
    if tt-total.define_recebimento_moeda[vi] <> ""
    then  do:
        put "              " tt-total.define_recebimento_moeda[vi] " ; "
            replace(string(tt-total.recebimento_moeda_lebes[vi])
             ,".",",") format "x(15)" skip.
        if tt-total.receb_moeda_principal_lebes[vi] > 0
        then put "                   PRINCIPAL ; "
            replace(string(tt-total.receb_moeda_principal_lebes[vi])
            ,".",",") format "x(15)" skip.
        if tt-total.receb_moeda_juros_lebes[vi] > 0
        then put "                   JUROS ; "
            replace(string(tt-total.receb_moeda_juros_lebes[vi])
            ,".",",") format "x(15)" skip.
        if tt-total.receb_moeda_acrescimo_lebes[vi] > 0
        then put "                   ACRESCIMO ; "
            replace(string(tt-total.receb_moeda_acrescimo_lebes[vi])
            ,".",",") format "x(15)" skip.

    end.
end.    

put       "         Recebimento NOVACAO ;"
        replace(string(tt-total.recebimento_novacao),".",",") format "x(15)"
        skip.
put       "            Recebimento NOVACAO LEBES     ;"
        replace(string(tt-total.recebimento_novacao_lebes),".",",") 
        format "x(15)"
        skip
        .
put       "            Recebimento NOVACAO FINANCEIRA;"
        replace(string(tt-total.recebimento_novacao_fdrebes),".",",") 
        format "x(15)"
        skip.
     
put  "         Recebimentos FINANCEIRA        ;"
     replace(string(tt-total.recebimento_fdrebes),".",",") format "x(15)"
     skip.
vi = 0.     
do vi = 1 to 15:
    if tt-total.define_recebimento_moeda[vi] <> ""
    then  do:
        put "              " tt-total.define_recebimento_moeda[vi] " ; "
            replace(string(tt-total.recebimento_moeda_fdrebes[vi])
             ,".",",") format "x(15)" skip.
    end.
end. 
     
put  skip "         Recebimentos ENTRADA           ;"
     replace(string(tt-total.recebimento_entrada),".",",") format "x(15)"
     skip.
vi = 0.     
do vi = 1 to 15:
    if tt-total.define_recebimento_entrada_moeda[vi] <> ""
    then  do:
        put "              " tt-total.define_recebimento_entrada_moeda[vi] " ; "
            replace(string(tt-total.recebimento_entrada_moeda[vi])
                    ,".",",") format "x(15)" skip.
    end.
end. 
/*
put  skip.
put "         Recebimentos SEGURO            ;".
put replace(string(tt-total.receb_seguro[1]),".",",") format "x(15)".
put skip.
*/
/****
vi = 0.     
do vi = 1 to 15:
    if tt-total.define_receb_seguro[vi] <> ""
    then  do:
        put "              " tt-total.define_receb_seguro[vi] " ; "
            replace(string(tt-total.receb_seguro[vi])
                    ,".",",") format "x(15)" skip.
    end.
end. 
****/
put  skip "JUROS recebimento   ;"
     replace(string(tt-total.juros_lebes + tt-total.juros_fdrebes)
                ,".",",") format "x(15)"
     skip "         Juros LEBES             ;"
     replace(string(tt-total.juros_lebes),".",",") format "x(15)"
     skip "         Juros FINANCEIRA        ;"
     replace(string(tt-total.juros_fdrebes),".",",") format "x(15)"
     skip "DEVOLUCAO venda             ;"
     replace(string(tt-total.devolucao_vista + tt-total.devolucao_prazo)
                    ,".",",") format "x(15)"
     skip "         Devolucao a VISTA           ;"
     replace(string(tt-total.devolucao_vista),".",",") format "x(15)"
     skip "         Devolucao a PRAZO           ;"
     replace(string(tt-total.devolucao_prazo),".",",") format "x(15)"
     skip "Estorno por DEVOLUCAO     ;"
     replace(string(tt-total.estorno_devolucao),".",",") format "x(15)"
     skip "NOVACAO de divida        ;"
     replace(string(tt-total.novacao_lebes + tt-total.novacao_fdrebes)
                    ,".",",") format "x(15)"
     skip "         Novacao LEBES             ;"
     replace(string(tt-total.novacao_lebes),".",",") format "x(15)"
     skip "         Novacao FINANCEIRA        ;"
     replace(string(tt-total.novacao_fdrebes),".",",") format "x(15)"
     skip "Acrescimo NOVACAO         ;"
     replace(string(tt-total.acrescimo_novacao_lebes +
            tt-total.acrescimo_novacao_fdrebes),".",",") format "x(15)"
     skip "         Acrecimo novacao LEBES ;"
     replace(string(tt-total.acrescimo_novacao_lebes),".",",") format "x(15)"
     skip "         Acrescimo novacao FINANCEIRA  ;"
     replace(string(tt-total.acrescimo_novacao_fdrebes),".",",") format "x(15)"
     skip "Cancelamentos FINANCEIRA  ;"
     replace(string(tt-total.cancelamentos_fdrebes),".",",") format "x(15)"
     skip "Cancelamento ACRESCIMO ;"
     replace(string(tt-total.acrescimo_cancelamento_fdrebes),".",",")
                format "x(15)"
     skip "Estorno por CANCELAMENTO  ;"
     replace(string(tt-total.estorno_cancelamento_fdrebes),".",",")
            format "x(15)"
     .

    put  skip.
    put   "Recebimentos SEGURO       ;".
    put replace(string(tt-total.receb_seguro[1]),".",",") format "x(15)".
    put skip.
    put   "Recebimentos CRE PESSOAL  ;".
    put replace(string(tt-total.receb_cpess[1]),".",",") format "x(15)".
    put skip.


output close.

message color red/with
        "Arquivo de totais gerado em:" skip
        varquivo
        view-as alert-box.

varquivo = varquivo + ".txt".


{mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""acr_fin""
        &Nom-Sis   = """SISTEMA CONTABIL/FISCAL"""
        &Tit-Rel   = """ REALTORIO DE TOTAIS "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "80"
        &Form      = "frame f-cabcab"}


run relatorio.

output close.

run visurel.p(varquivo,"").

procedure relatorio:

    v_vista = 0.
    v_recarga = 0.
    vi = 0.
    do vi = 1 to 15:
        v_vista = v_vista + tt-total.venda_moeda[vi].
        v_recarga = v_recarga + tt-total.venda_recarga[1].
    end.    

    put "Venda a VISTA"  format "x(40)" 
            tt-total.venda_vista  format ">>>,>>>,>>9.99"
            skip.
    vi = 0.
    do vi = 1 to 15:
        if tt-total.define_venda_moeda[vi] <> ""
        then put "     " + tt-total.define_venda_moeda[vi] format "x(40)"
                  tt-total.venda_moeda[vi] format ">>>,>>>,>>9.99"
                  skip.
    end. 
    vi = 0.
    do vi = 1 to 15:
        if tt-total.define_venda_recarga[vi] <> ""
        then put "     " + tt-total.define_venda_recarga[vi] format "x(40)"
                 tt-total.venda_recarga[vi] format ">>>,>>>,>>9.99"
                 skip.
    end.  
    vi = 0.
    do vi = 1 to 15:
        if tt-total.define_venda_seguro[vi] <> ""
        then put "     " + tt-total.define_venda_seguro[vi] format "x(40)"
                 tt-total.venda_seguro[vi] format ">>>,>>>,>>9.99"
                 skip.
    end.
    vi = 0.
    do vi = 1 to 15:
        if tt-total.define_venda_cpess[vi] <> ""
        then put "     " + tt-total.define_venda_cpess[vi] format "x(40)"
                 tt-total.venda_cpess[vi] format ">>>,>>>,>>9.99"
                 skip.
    end.  
    put  "Venda a PRAZO "   format "x(40)"
         tt-total.venda_prazo_lebes + tt-total.venda_prazo_fdrebes +
         tt-total.venda_prazo_adicional + tt-total.venda_prazo_semcupom +
         tt-total.venda_prazo_outras format ">>>,>>>,>>9.99"
         skip "     Venda prazo LEBES "  format "x(40)"
         tt-total.venda_prazo_lebes format ">>>,>>>,>>9.99"
         skip "          Venda prazo ADICIONAL " format "x(40)"
         tt-total.venda_prazo_adicional format ">>>,>>>,>>9.99"
         skip "     Venda parzo FINANCEIRA "   format "x(40)"
         tt-total.venda_prazo_fdrebes format ">>>,>>>,>>9.99"
         skip "     Venda prazo SEM CUPOM "   format "x(40)"
         tt-total.venda_prazo_semcupom format ">>>,>>>,>>9.99"
         skip "     Venda prazo OUTRAS "        format "x(40)"
         tt-total.venda_prazo_outras format ">>>,>>>,>>9.99"
         skip "ACRESCIMO venda prazo "      format "x(40)"
         tt-total.acrescimo_lebes + tt-total.acrescimo_fdrebes
                    format ">>>,>>>,>>9.99"
         skip "     Acrescimo LEBES "        format "x(40)"
         tt-total.acrescimo_lebes format ">>>,>>>,>>9.99"
         skip "     Acrescimo FINANCEIRA "    format "x(40)"
         tt-total.acrescimo_fdrebes format ">>>,>>>,>>9.99"
         skip "RECEBIMENTOS "             format "x(40)"
         tt-total.recebimento_lebes + tt-total.recebimento_fdrebes +
         tt-total.recebimento_entrada + tt-total.recebimento_novacao
                        format ">>>,>>>,>>9.99"
         skip "     Recebimentos LEBES " format "x(40)"
         tt-total.recebimento_lebes format ">>>,>>>,>>9.99"
         skip.
    
    vi = 0.     
    do vi = 1 to 15:
        if tt-total.define_recebimento_moeda[vi] <> ""
        then  do:
            put "          " + tt-total.define_recebimento_moeda[vi]
                        format "x(40)"
                 tt-total.recebimento_moeda_lebes[vi] format ">>>,>>>,>>9.99"
                 skip.
            if tt-total.receb_moeda_principal_lebes[vi] > 0
            then put "               PRINCIPAL " format "x(40)"
                      tt-total.receb_moeda_principal_lebes[vi]
                      format ">>>,>>>,>>9.99" skip.
            if tt-total.receb_moeda_juros_lebes[vi] > 0
            then put "               JUROS "     format "x(40)"
                      tt-total.receb_moeda_juros_lebes[vi]
                      format ">>>,>>>,>>9.99" skip.
            if tt-total.receb_moeda_acrescimo_lebes[vi] > 0
            then put "               ACRESCIMO "   format "x(40)"
                      tt-total.receb_moeda_acrescimo_lebes[vi] +
                      (tt-total.recebimento_moeda_lebes[vi] -
                      (tt-total.receb_moeda_principal_lebes[vi] +
                       tt-total.receb_moeda_acrescimo_lebes[vi]))
                      format ">>>,>>>,>>9.99" skip.
        end.
    end.    

    put "     Recebimento NOVACAO "  format "x(40)"
         tt-total.recebimento_novacao 
         format ">>>,>>>,>>9.99" skip.
     
    put "        Recebimento NOVACAO LEBES      "
        tt-total.recebimento_novacao_lebes 
         format ">>>,>>>,>>9.99" skip.

    put "        Recebimento NOVACAO FINANCEIRA "
        tt-total.recebimento_novacao_fdrebes
        format ">>>,>>>,>>9.99" skip.
     
    put "     Recebimentos FINANCEIRA "  format "x(40)"
         tt-total.recebimento_fdrebes
         format ">>>,>>>,>>9.99" skip.
    
    vi = 0.     
    do vi = 1 to 15:
        if tt-total.define_recebimento_moeda[vi] <> ""
        then put "          " + tt-total.define_recebimento_moeda[vi]
                        format "x(40)"
                 tt-total.recebimento_moeda_fdrebes[vi]
                 format ">>>,>>>,>>9.99" skip.
    end. 
     
    put "     Recebimentos ENTRADA "  format "x(40)"
         tt-total.recebimento_entrada
         format ">>>,>>>,>>9.99" skip.

    vi = 0.     
    do vi = 1 to 15:
        if tt-total.define_recebimento_entrada_moeda[vi] <> ""
        then put "          " + tt-total.define_recebimento_entrada_moeda[vi]
                            format "x(40)"
                 tt-total.recebimento_entrada_moeda[vi]
                 format ">>>,>>>,>>9.99" skip.
    end.

    /*
    put "     Recebimentos SEGURO "  format "x(40)"
         tt-total.receb_seguro[1]
         format ">>>,>>>,>>9.99" skip.
    */
    
    put  "JUROS recebimento "   format "x(40)"
         tt-total.juros_lebes + tt-total.juros_fdrebes
                        format ">>>,>>>,>>9.99" 
         skip "     Juros LEBES "   format "x(40)"
         tt-total.juros_lebes format ">>>,>>>,>>9.99"
         skip "     Juros FINANCEIRA "  format "x(40)"
         tt-total.juros_fdrebes format ">>>,>>>,>>9.99"
         skip "DEVOLUCAO venda "      format "x(40)"
         tt-total.devolucao_vista + tt-total.devolucao_prazo
                            format ">>>,>>>,>>9.99"
         skip "     Devolucao a VISTA "  format "x(40)"
         tt-total.devolucao_vista format ">>>,>>>,>>9.99"
         skip "     Devolucao a PRAZO "   format "x(40)"
         tt-total.devolucao_prazo format ">>>,>>>,>>9.99"
         skip "Estorno por DEVOLUCAO "    format "x(40)"
         tt-total.estorno_devolucao format ">>>,>>>,>>9.99"
         skip "NOVACAO de divida "     format "x(40)"
         tt-total.novacao_lebes + tt-total.novacao_fdrebes
                                format ">>>,>>>,>>9.99"
         skip "     Novacao LEBES "   format "x(40)"
         tt-total.novacao_lebes format ">>>,>>>,>>9.99"
         skip "     Novacao FINANCEIRA "  format "x(40)"
         tt-total.novacao_fdrebes format ">>>,>>>,>>9.99"
         skip "Acrescimo NOVACAO "  format "x(40)"
         tt-total.acrescimo_novacao_lebes + tt-total.acrescimo_novacao_fdrebes
                            format ">>>,>>>,>>9.99"
         skip "     Acrecimo novacao LEBES " format "x(40)"
         tt-total.acrescimo_novacao_lebes format ">>>,>>>,>>9.99"
         skip "     Acrescimo novacao FINANCEIRA "  format "x(40)"
         tt-total.acrescimo_novacao_fdrebes format ">>>,>>>,>>9.99"
         skip "Cancelamentos FINANCEIRA " format "x(40)"
         tt-total.cancelamentos_fdrebes format ">>>,>>>,>>9.99"
         skip "Cancelamento ACRESCIMO " format "x(40)"
         tt-total.acrescimo_cancelamento_fdrebes format ">>>,>>>,>>9.99"
         skip "Estorno por CANCELAMENTO "  format "x(40)"
         tt-total.estorno_cancelamento_fdrebes format ">>>,>>>,>>9.99"
         skip
         .

    put       "Recebimentos SEGURO      "  format "x(40)"
         tt-total.receb_seguro[1]
         format ">>>,>>>,>>9.99" skip.
    put       "Recebimentos CRE PESSOAL "  format "x(40)"
         tt-total.receb_cpess[1]
         format ">>>,>>>,>>9.99" skip.

end.