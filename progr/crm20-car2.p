def input parameter p-clicod like clien.clicod.
def input-output parameter vmostra as log.

def var v-lib as dec.
def var v-pag as dec.

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

def var vok as log init no.

find first tt-filtro where 
           tt-filtro.descricao = "ELEGIVEIS CARTAO"
           NO-ERROR.
if avail tt-filtro
then do:
    vok = no.
/***
    for each d.titulo where d.titulo.clifor = p-clicod no-lock
                by d.titulo.titdtven :
        if  d.titulo.titnat = yes or
            d.titulo.modcod <> "CRE" or
            d.titulo.titpar < 30
        then next.
        if d.titulo.moecod = "DEV" or
           d.titulo.moecod = "NOV"
        then next.   
        if d.titulo.titsit = "LIB" /**** Antonio and
           d.titulo.titdtven < today ****/
        then do:
            vok = no.
            leave.
        end.
        if d.titulo.titdtven >= tt-filtro.data[1]
        then vok = yes.
        if d.titulo.titsit = "LIB"
        then v-lib = v-lib + 1.
        if d.titulo.titsit = "PAG"
        then v-pag = v-pag + 1.
    end.
***/
    for each fin.titulo where fin.titulo.clifor = p-clicod no-lock
                by fin.titulo.titdtven :
        if fin.titulo.titnat = yes or
           fin.titulo.modcod <> "CRE" or
           fin.titulo.tpcontrato <> "L" /*fin.titulo.titpar < 50*/
        then next.
        if fin.titulo.moecod = "DEV" or
           fin.titulo.moecod = "NOV"
        then next.   
        if fin.titulo.titsit = "LIB" /******and ANTONIO
           fin.titulo.titdtven < today ******/
        then do:
            vok = no.
            leave.
        end.
        if fin.titulo.titdtven >= tt-filtro.data[1]
        then vok = yes.
        if fin.titulo.titsit = "LIB"
        then v-lib = v-lib + 1.
        if fin.titulo.titsit = "PAG"
        then v-pag = v-pag + 1.
    end.
    if vok = yes
    then do:
        if (v-pag / (v-lib + v-pag)) * 100 >= tt-filtro.dec[1]
        then vmostra = yes.
        else vmostra = no.       
    end.
end.