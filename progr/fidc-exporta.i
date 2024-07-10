/* 09022023 helio - ID 158541 - trocado f-troca por removeacento */
/***
    Projeto FIDC: junho,julho/2018
    Exportar CNAB444: item 6.2 Envio de arquivo de vencimentos
    #1 27.05.20 - TP 37162755
***/
{fqrecbanco.i}
{api/acentos.i}

FUNCTION f-troca returns character
    (input cpo as char).
    def var v-i as int.
    def var v-lst as char extent 60
       init ["+","@",":",";",".",",","*","/","-",">","!","'",'"',"[","]"].
         
    if cpo = ?
    then cpo = "".
    else do v-i = 1 to 30:
         cpo = replace(cpo,v-lst[v-i],"").
    end.
    return cpo. 
end FUNCTION.


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
    

def var vpasta    as char.
def var vseq      as int.
def var vmodcod   like titulo.modcod init "CRE".

/* Header */
def var vcodorig as char.  /* Código do Originador (Consultoria) */
def var vnomorig as char. /* Nome do Originador (Consultoria) */

assign
    vcodorig = fill("0",20).

/* Detalhe */
def var vcontrolpag as char. /* Nº de Controle do Participante */
def var vtitulo     as char.
def var vtitpar     like titulo.titpar.
def var vendereco   as char.
def var vcedente    as char.
def var vocorrencia as int.
def temp-table tt-moeda
    field moecod   like titpag.moecod
    field titvlpag like titpag.titvlpag
    index moeda is primary unique moecod.

run le_tabini.p (0, 0, "FIDC - ORIGINADOR", output vnomorig).
run le_tabini.p (0, 0, "FIDC - PASTA", output vpasta).
run le_tabini.p (0, 0, "FIDC - CEDENTE", output vcedente).


procedure exporta.
    def input parameter par-moecod   as char.
    def input parameter par-titvlpag as dec.

    def var vmoecod     as int.

    if par-moecod = "CHV" then vmoecod = 1.
    else if par-moecod = "PRE" then vmoecod = 2.
    else if par-moecod = "DIN" then vmoecod = 5.
    else if par-moecod begins "TD" or
            par-moecod = "CAR" then vmoecod = 3.
    else if par-moecod begins "TC" then vmoecod = 4.
    else if par-moecod = "BCO" then vmoecod = 6.
    else if par-moecod = "BOL" then vmoecod = 7.

        vseq = vseq + 1.
        put unformatted
            1           format "9"       /* 1 */
            ""          format "x(19)"   /* 2 */
            2           format "99"      /* 3 */
            0           format "99"      /* 4 */
            402         format "9999"    /* 5 */
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
            61          format "99"      /* 29 */
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
            removeAcento(clien.clinom)  format "x(40)" /* 41 */
            removeAcento(vendereco)     format "x(40)" /* 42 */
            0           format "999999999" /* 43 */
            0           format "999"     /* 44 */
            f-troca(clien.cep[1])  format "x(8)" /* 45 */
            vcedente    format "x(60)"   /* 46 */
            ""          format "x(44)"   /* 47 */
            vseq        format "999999"  /* 48 */
            skip.
end procedure.


procedure moedas.

    def var vpossui_boleto as log.
    def var vpossui_ted    as log.
    def var recatu2        as recid.
    def var vmoecod        as char.

    empty temp-table tt-moeda.
    for each titpag where 
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                      titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar and
                      titpag.titvlpag > 0 /* #1 */
                    no-lock.
        find tt-moeda where tt-moeda.moecod = titpag.moecod no-error.
        if not avail tt-moeda
        then do.
            create tt-moeda.
            tt-moeda.moecod = titpag.moecod.
        end.
        tt-moeda.titvlpag = tt-moeda.titvlpag + titpag.titvlpag.
        /***vtitvlpag = vtitvlpag  + titpag.titvlpag.***/
    end.
/***
        if vtitvlpag < titulo.titvlpag /* Nao localizou todo o valor pago */
        then do.
            find first tt-moeda where tt-moeda.moecod = titulo.moecod no-error.
            if not avail tt-moeda
            then do.
                create tt-moeda.
                assign
                    tt-moeda.moecod = titulo.moecod.
            end.
            assign
                tt-moeda.titvlpag = tt-moeda.titvlpag + 
                                (titulo.titvlpag - vtitvlpag).
        end.
***/
    find first tt-moeda no-lock no-error.
    if not avail tt-moeda
    then do.
        run receb_banco (titulo.titnum, titulo.titpar,
                 output vpossui_boleto, output vpossui_ted, output recatu2).
        vmoecod = titulo.moecod.

        if vpossui_boleto
        then vmoecod = "BOL". /* Boleto */

        if vpossui_ted
        then vmoecod = "BCO". /* TED */
        
        create tt-moeda.
        assign
            tt-moeda.moecod   = vmoecod
            tt-moeda.titvlpag = titulo.titvlpag.
    end.

end procedure.

