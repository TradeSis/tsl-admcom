/* 26112021 helio venda carteira */
{admcab.i}

{/admcom/progr/api/acentos.i}

def buffer blotefin for lotefin.

def var vnfe-chave  as char.
def var vnfe-num    as int.
def var vnfe-ser    as int.

def shared temp-table ttcontrato no-undo
    field marca     as log format "*/ "
    field contnum   like contrato.contnum    format ">>>>>>>>9"
    field dtemi     like contrato.dtinicial
    field vlabe     as dec
    field vlatr     as dec
    field vlpag     as dec
    field cobcod    like titulo.cobcod
    field vlf_principal as dec
    field vlf_acrescimo as dec
    field vlpre         as dec
    field qtdpag        as int
    field diasatraso    as int format "999"
    index contnum is unique primary contnum asc.

function trata-numero returns character
    (input par-num as char).

    def var par-ret as char init "".
    def var vletra  as char.
    def var vi      as int.

    if par-num = ?
    then par-num = "".

    do vi = 1 to length(par-num).
        vletra = substr(par-num, vi, 1).
        if (asc(vletra) >= 48 and asc(vletra) <= 57) /* 0-9 */
        then par-ret = par-ret + substring(par-num,vi,1).
    end.

    return par-ret.

end function.


function formatadata returns character
    (input par-data  as date). 
    
    def var vdata as char.  

    if par-data <> ? 
    then vdata = string(par-data, "999999").
    else vdata = "000000". 

    return vdata. 

end function. 
    

def var vpasta    as char init "/admcom/import/fidc/".
def var vseq      as int.
def var vmodcod   like titulo.modcod init "CRE".

/* Header */
def var vcodorig as char.  /* Código do Originador (Consultoria) */

assign
    vcodorig = fill("0",20).

/* Detalhe */
def var vcontrolpag as char. /* Nº de Controle do Participante */
def var vtitulo     as char.
def var vtitpar     like titulo.titpar.
def var vendereco   as char.
def var vocorrencia as int.



def var varquivo  as char.
def var vdata     as date.

def var vlote as int.

    do on error undo.
        find last Blotefin no-lock no-error.
        create lotefin.
        assign lotefin.lotnum = (if avail Blotefin 
                                 then Blotefin.lotnum + 1
                             else 1)
            lotefin.lottip = "INC"
            lotefin.aux-ch = "FINANCEIRA - EXPORTA CONTRATOS".
          
    assign vlote = lotefin.lotnum.                         
    end.


varquivo = "remessa_fidc" + string(today,"99999999") + "_" + string(vlote) + ".rem".


    varquivo = vpasta + varquivo.


    hide message no-pause.
    message color normal "gerando arquivo" varquivo "... aguarde...".



output to value(varquivo) page-size 0.

vseq = 1.
/* Header */

put unformatted
    0           format "9"       /* 1 */
    1           format "9"       /* 2 */
    "REMESSA"   format "x(7)"    /* 3 */
    1           format "99"      /* 4 */
    "COBRANCA"  format "x(15)"   /* 5 */
    vcodorig    format "x(20)"   /* 6 "99999999999999999999"*/
    "FIDC LEBES               "    format "x(30)"   /* 7 */
    611         format "999"     /* 8 */
    "PAULISTA S.A." format "x(15)"
    today       format "999999"  /* 10 */
    ""          format "x(8)"    /* 11 */
    "MX"        format "x(2)"    /* 12 */
    /*vlote*/ 1      format "9999999" /* 13 */
    ""          format "x(321)"  /* 14 */
    vseq        format "999999"  /* 15 */
    skip.
    
/* Detalhe */
for each ttcontrato where ttcontrato.marca = yes no-lock.
    find contrato where contrato.contnum = ttcontrato.contnum no-lock.

    vnfe-chave  = "".
    vnfe-num    = 0.
    vnfe-ser    = 0.
    find first contnf where contnf.contnum = contrato.contnum
                  AND contnf.etbcod  = contrato.etbcod 
                  no-lock no-error.
    if avail contnf
    then do:
        find first plani where plani.placod = contnf.placod
                       and plani.etbcod = contnf.etbcod
                       and plani.serie  = contnf.notaser
                     no-lock no-error.
        if avail plani
        then
        if plani.ufdes <> "" and length(plani.ufdes) = 44
        then do:
            vnfe-chave = plani.ufdes.
            vnfe-num   = plani.numero.
            vnfe-ser   = int(substring(trim(plani.serie),1,3)) no-error.
            if vnfe-ser = ? then vnfe-ser = 0.
        end.        
    end.

    for each titulo where titulo.empcod = 19 and titulo.titnat = no and     
            titulo.etbcod = contrato.etbcod and titulo.modcod = contrato.modcod and
            titulo.clifor = contrato.clicod and titulo.titnum = string(contrato.contnum)
            no-lock.
        if titulo.titpar = 0 then next.
        if titulo.titsit = "LIB"
        then.
        else next.

        find clien where clien.clicod = titulo.clifor no-lock.

        vendereco = clien.endereco[1].
        if clien.numero[1] <> ?
        then vendereco = vendereco + " " + string(clien.numero[1]).
        if clien.compl[1] <> ?
        then vendereco = vendereco + " " + clien.compl[1].
        if vendereco = ?
        then vendereco = "".

        vtitpar = titulo.titpar.

        assign
        vtitulo = string(int(titulo.titnum), "9999999999")
        vcontrolpag = string(titulo.etbcod, "999") +
                      string(int(titulo.titnum), "9999999999") +
                      string(vtitpar, "999").
        vocorrencia = 01.

        if titulo.titdtpag = ?
        then run exporta ("", 0).
        else do.
    
            /*
            if acha("PAGAMENTO-PARCIAL", titulo.titobs[1]) = "SIM"
            then vocorrencia = 14.
            else 
            */
            vocorrencia = 77.

            run exporta (titulo.moecod, titulo.titvlpag).
        
        end.

    end.
end.

/* Trailer */
vseq = vseq + 1.
put unformatted
    9           format "9"       /* 1 */
    ""          format "x(437)"  /* 2 */
    vseq        format "999999"  /* 3 */
    skip.

output close.

unix silent unix2dos -q value(varquivo).


message "Arquivo gerado:" varquivo view-as alert-box.
return.



procedure exporta.
    def input parameter par-moecod   as char.
    def input parameter par-titvlpag as dec.

    def var vmoecod     as int init 0.

    if par-moecod = "CHV" then vmoecod = 1.
    else if par-moecod = "PRE" then vmoecod = 2.
    else if par-moecod = "DIN" then vmoecod = 5.
    else if par-moecod begins "TD" or
            par-moecod = "CAR" then vmoecod = 3.
    else if par-moecod begins "TC" then vmoecod = 4.
    else if par-moecod = "BCO" then vmoecod = 6.
    else if par-moecod = "BOL" then vmoecod = 7.
    if par-moecod <> "" and vmoecod = 0 
    then vmoecod = 5.
    if titulo.titsit = "LIB"
    then vmoecod = 0.


        vseq = vseq + 1.
        put unformatted
            1           format "9"       /* 1 */
            ""          format "x(19)"   /* 2 */
            2           format "99"      /* 3 */
            0           format "99"      /* 4 */
            302         format "9999"    /* 5 */
            16          format "99"      /* 6 */
            199         format "9999"    /* 7 */
            "A"         format "x(2)"    /* 8 */
            vmoecod     format "9"       /* 9 */
            vcontrolpag format "x(25)"   /* 10 */
            0           format "999"     /* 11 */
            0           format "99999"   /* 12 */
            ""          format "x(12)"   /* 13,14 */
            par-titvlpag * 100 format "9999999999" /* 15 */
            ""          format "x(2)"    /* 16,17 */
            FormataData(titulo.titdtpag) /* 18 */
            ""          format "x(8)"    /* 19 A 22 */
            vocorrencia format "99"      /* 23 */
            vtitulo     format "x(10)"   /* 24 */
            FormataData(titulo.titdtven) /* 25 */
            titulo.titvlcob * 100 format "9999999999999" /* 26 */
            0           format "99999999" /* 27 e 28 */
            01          format "99"      /* 29 */
            ""          format "x(1)"    /* 30 */
            FormataData(titulo.titdtemi) /* 31 */
            0           format "999"     /* 32 e 33 */
            2           format "99"      /* 34 */
            0           format "999999999999" /* 35 */
            fill("0",19) format "x(19)"  /* 36 */
            titulo.titvlcob * 100 format "9999999999999" /* 37 */
            0           format "9999999999999" /* 38 */
            1           format "99"      /* 39 */
            dec(trata-numero(clien.ciccgc)) format "99999999999999"
            RemoveAcento(clien.clinom)  format "x(40)" /* 41 */
            RemoveAcento(vendereco)     format "x(40)" /* 42 */
            vnfe-num    format "999999999" /* 43 */
            vnfe-ser    format "999"     /* 44 */
            if clien.cep[1] <> ? then int(clien.cep[1]) else 0  format "99999999" /* 45 */
            "DREBES E CIA LTDA                             96662168000131" format "x(60)"   /* 46 */
            vnfe-chave          format "x(44)"   /* 47 chave da nota fiscal */ 
            vseq        format "999999"  /* 48 */
            skip.
            

end procedure.


