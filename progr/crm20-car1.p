def input parameter p-clicod like clien.clicod.
def input-output parameter vmostra as log.

def shared temp-table tt-filtro
    field descricao  as char format "x(30)"
    field considerar as log  format "Sim/Nao"
    field tipo       as char
    field tecla-p    as char
    field log        as log  format "Sim/Nao"
    field data       as date format "99/99/9999" extent 2
    field dec        as dec  extent 2
    field int        as int  extent 2
    field etbcod     like estab.etbcod
    index ietbcod  etbcod.

def var vqtdpag as int.

find first tt-filtro where 
           tt-filtro.descricao = "ELEGIVEIS CARTAO"
           NO-ERROR.
if avail tt-filtro
then do:            
    vmostra = no.
    for each titulo where titulo.clifor = p-clicod no-lock
            by titulo.titdtven :
        if  titulo.titnat = yes or
            titulo.modcod <> "CRE" or
            titulo.tpcontrato <> "" /*titulo.titpar > 30*/
        then next.
        if titulo.moecod = "DEV" or
           titulo.moecod = "NOV"
        then next. 
        if titulo.titsit = "LIB" and
           (today - titulo.titdtven) > 30 then do:
           leave.        
        end.
        if titulo.titsit = "LIB" and
           titulo.titdtven < tt-filtro.data[1] 
        then do:
            vmostra = no.
            leave.
        end.
        if titulo.titsit = "LIB" and
           titulo.titdtven >= tt-filtro.data[1] 
        then do:
            vmostra = yes.
            /* leave. - Antonio - qdo tinha mais de um contrato
                        com parcelas LIB podia sair ok indevidamente */
        end.
        if titulo.titsit = "PAG" and
           titulo.titdtpag >= tt-filtro.data[1] 
        then do:
            vmostra = yes.
             /* leave. - Antonio - qdo tinha mais de um contrato
                         com parcelas pagas podia sair ok indevidamente */
        end.
    end.
    vqtdpag = 0.
    for each titulo where titulo.clifor = p-clicod no-lock:
        if  titulo.titnat = yes or
            titulo.modcod <> "CRE" or
            titulo.tpcontrato <> "" /*titulo.titpar > 30*/
        then next.
        if titulo.moecod = "DEV" or
           titulo.moecod = "NOV"
        then next. 
        if titulo.titsit = "LIB"
        then next.
        vqtdpag = vqtdpag + 1.
    end.
    if tt-filtro.int[1] > 0 and
       tt-filtro.int[1] > vqtdpag
    then vmostra = no.
        
    if tt-filtro.log = yes and vmostra = yes
    then do:
/***    connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld d
                                            no-error.
        if connected("d")
        then do:
***/
            run crm20-car2.p (input p-clicod,
                              input-output vmostra).
                                      
/***
            disconnect d.
        end.
***/
    end.        
 end.       
