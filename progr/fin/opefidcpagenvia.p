/* 18022022 helio carteira FIDC FINANCEIRA 
    DESATIVADO

def input param poperacao   like sicred_pagam.operacao.
def input param pstatus     like sicred_pagam.sstatus.

{admbatch.i}
{acha.i}

    def var vpossui_boleto as log.
    def var vpossui_ted    as log.
    def var recatu2 as recid.
def var vlotqtde  as int.
def var vlottotal as dec.
    
def var vlottip   as char init "ENVPAGT".

def var vtpcontrato     like contrato.tpcontrato.

def buffer blotefin for lotefin.

def shared temp-table ttsicred no-undo
    field marca     as log format "*/ "
    field cobcod    like titulo.cobcod     
    field dtenvio   like lotefin.datexp
    field lotnum    like lotefin.lotnum
    
    field datamov   like pdvforma.datamov
    field ctmcod    like pdvforma.ctmcod        
    field modcod    like poscart.modcod
    field tpcontrato    like poscart.tpcontrato
    field qtd       as int 

    field titvlcob       like pdvdoc.titvlcob
    field valor_encargo  like pdvdoc.valor_encargo
    field desconto       like pdvdoc.desconto
    field valor          like pdvdoc.valor


    index idx is unique primary 
        cobcod asc
        dtenvio  asc
        datamov asc 
        ctmcod asc
        modcod asc
        tpcontrato asc   
        lotnum         
                 .

def temp-table ttenviado no-undo
    field psicred as recid.

def var varquivo as char.
def var varqexp  as char.
def var vseq as int.
def var vqtoper  as int.
def var vtotal   as dec.

def var vlote as int.

def buffer btitulo for titulo.


{fqrecbanco.i}

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



    for each ttenviado.
        delete ttenviado.
    end.        

    do on error undo.
        find last Blotefin no-lock no-error.
        create lotefin.
        assign lotefin.lotnum = (if avail Blotefin 
                                 then Blotefin.lotnum + 1
                             else 1)
            lotefin.lottip = "PAG"
            lotefin.aux-ch = "FIDC - EXPORTA PAGAMENTOS".
          
    assign vlote = lotefin.lotnum.                         

    varqexp = "cobranca_fidc_" + string(today,"999999") + "_" + string(vlote) + ".rem".
    varquivo = "/admcom/import/fidc/" + varqexp.

        create lotefidc.
        assign lotefidc.lotnum = vlote
              lotefidc.lottip  = vlottip
              lotefidc.funcod  = sfuncod
              lotefidc.arquivo = varquivo.
              /*
              lotefidc.dtinicial = vdtini
              lotefidc.dtfinal   = vdtfin.
              */
    
    end.

    hide message no-pause.
    message color normal "gerando arquivo" varquivo "... aguarde...".

    output to value(varquivo) page-size 0.

    assign vqtoper = 0
           vtotal = 0.

    run p-registro-00.

    for each  ttsicred where ttsicred.marca = yes no-lock:
    for each sicred_pagam where
        sicred_pagam.operacao = poperacao and
        sicred_pagam.cobcod   = ttsicred.cobcod   and
        sicred_pagam.sstatus  = pstatus and
        sicred_pagam.datamov  = ttsicred.datamov and
        sicred_pagam.ctmcod   = ttsicred.ctmcod 
        no-lock.
    
        find contrato where contrato.contnum = sicred_pagam.contnum
            no-lock no-error.
        if not avail contrato
        then next.   

            find titulo where titulo.contnum = contrato.contnum and
                      titulo.titpar  = sicred_pagam.titpar
                      no-lock no-error.
                if not avail titulo
                then do:
                    find first titulo where
                    titulo.empcod     = 19 and
                    titulo.titnat     = no and
                    titulo.modcod     = contrato.modcod and
                    titulo.etbcod     = contrato.etbcod and
                    titulo.clifor     = contrato.clicod and
                    titulo.titnum     = string(contrato.contnum) and 
                    titulo.titpar     = sicred_pagam.titpar and
                    titulo.titdtemi   = contrato.dtinicial
                    no-lock no-error.
                end.
            vtpcontrato = if avail titulo
                      then titulo.tpcontrato
                      else "".
 
        if  contrato.modcod   = ttsicred.modcod  and
            vtpcontrato = ttsicred.tpcontrato
        then. 
        else next.     

        find first pdvmov where 
                pdvmov.etbcod = sicred_pagam.etbcod and
                pdvmov.cmocod = sicred_pagam.cmocod and
                pdvmov.datamov = sicred_pagam.datamov and
                pdvmov.sequencia = sicred_pagam.sequencia and pdvmov.ctmcod = sicred_pagam.ctmcod
                no-lock .
            find pdvdoc of pdvmov where
                pdvdoc.seqreg = sicred_pagam.seqreg
                no-lock.
                
                create ttenviado.
                ttenviado.psicred = recid(sicred_pagam).
                vlotqtde = vlotqtde + 1.
                vlottotal = vlottotal + pdvdoc.valor.        
                run p-registro-10.    

    end.
    end.
    
    run p-registro-99.
    
    output close.
    
    
        output to ./unixdos.txt.
        unix silent unix2dos value(varquivo). 
        unix silent chmod 777 value(varquivo).
        output close.
        unix silent value("rm ./unixdos.txt -f").
    
    for each ttenviado.
        find sicred_pagam where recid(sicred_pagam) = ttenviado.psicred exclusive.
        sicred_pagam.sstatus = "ENVIADO".
        sicred_pagam.lotnum = vlote.        
    end.        
    hide message no-pause.
    message color normal "arquivo" varquivo "gerado!".
    pause 3 no-message.

/* header */
procedure p-registro-00.

vseq = 1.
/* Header */

put unformatted
    0           format "9"       /* 1 */
    1           format "9"       /* 2 */
    "REMESSA"   format "x(7)"    /* 3 */
    1           format "99"      /* 4 */
    "COBRANCA"  format "x(15)"   /* 5 */
    vcodorig    format "x(20)"   /* 6 "99999999999999999999"*/
    vnomorig    format "x(30)"   /* 7 */
    611         format "999"     /* 8 */
    "PAULISTA S.A." format "x(15)"
    today       format "999999"  /* 10 */
    ""          format "x(8)"    /* 11 */
    "MX"        format "x(2)"    /* 12 */
    vlote       format "9999999" /* 13 */
    ""          format "x(321)"  /* 14 */
    vseq        format "999999"  /* 15 */
    skip.
 

end procedure.

procedure p-registro-10.
  def buffer benvfinan for envfinan.
  def var par-moecod    like titulo.moecod.
  
    def var vvlseguro as dec. 
    find clien where clien.clicod = titulo.clifor no-lock.

    vendereco = clien.endereco[1].
    if clien.numero[1] <> ?
    then vendereco = vendereco + " " + string(clien.numero[1]).
    if clien.compl[1] <> ?
    then vendereco = vendereco + " " + clien.compl[1].
    if vendereco = ?
    then vendereco = "".


       run receb_banco (titulo.titnum, titulo.titpar,
                 output vpossui_boleto, output vpossui_ted, output recatu2).
        par-moecod = pdvdoc.ctmcod.

        if vpossui_boleto
        then par-moecod = "BOL". /* Boleto */

        if vpossui_ted
        then par-moecod = "BCO". /* TED */
  
    def var vmoecod     as int.

    if par-moecod = "CHV" then vmoecod = 1.
    else if par-moecod = "PRE" then vmoecod = 2.
    else if par-moecod = "DIN" then vmoecod = 5.
    else if par-moecod begins "TD" or
            par-moecod = "CAR" then vmoecod = 3.
    else if par-moecod begins "TC" then vmoecod = 4.
    else if par-moecod = "BCO" then vmoecod = 6.
    else if par-moecod = "BOL" then vmoecod = 7.

    vocorrencia = 77.
    if pdvdoc.pago_parcial = "S"
    then vocorrencia = 14.

    vvlseguro = 0.
    if contrato.vlseguro > 0 and contrato.nro_parcelas > 0
    then vvlseguro = contrato.vlseguro / contrato.nro_parcelas.
             

        vtitulo = string(int(titulo.titnum), "9999999999").
        vcontrolpag = string(titulo.etbcod, "999") +
                      string(int(titulo.titnum), "9999999999") +
                      string(titulo.titpar, "999").
        vocorrencia = 0.

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
            pdvdoc.valor * 100 format "9999999999" /* 15 */
            ""          format "x(2)"    /* 16,17 */
            FormataData(pdvdoc.datamov) /* 18 */
            ""          format "x(8)"    /* 19 A 22 */
            vocorrencia format "99"      /* 23 */
            vtitulo     format "x(10)"   /* 24 */
            FormataData(titulo.titdtven) /* 25 */
            (pdvdoc.titvlcob /*- vvlseguro*/ ) * 100 format "9999999999999" /* 26 */ /* Helio 02.10.2020 */ /* helio 12.04.2021 retirei o seguro
                                                https://trello.com/c/H7jaKDtQ/223-chamado-id-45581-exporta%C3%A7%C3%A3o-pgto-fidc-revitaliza%C3%A7%C3%A3o 
                                                */
            0           format "99999999" /* 27 e 28 */
            01          format "99"      /* 29 */
            ""          format "x(1)"    /* 30 */
            FormataData(titulo.titdtemi) /* 31 */
            0           format "999"     /* 32 e 33 */
            2           format "99"      /* 34 */
            0           format "999999999999" /* 35 */
            fill("0",19) format "x(19)"  /* 36 */
            ((if titulo.titvltot > 0 then titulo.titvltot else titulo.titvlcob) - vvlseguro) * 100 format "9999999999999" /* 37 */ /*19022021*/
            0           format "9999999999999" /* 38 */
            1           format "99"      /* 39 */
            dec(trata-numero(clien.ciccgc)) format "99999999999999"
            f-troca(clien.clinom)  format "x(40)" /* 41 */
            f-troca(vendereco)     format "x(40)" /* 42 */
            0           format "999999999" /* 43 */
            0           format "999"     /* 44 */
            f-troca(clien.cep[1])  format "x(8)" /* 45 */
            vcedente    format "x(60)"   /* 46 */
            ""          format "x(44)"   /* 47 */
            vseq        format "999999"  /* 48 */
            skip.


        find envfidc where envfidc.empcod = titulo.empcod
                       and envfidc.titnat = titulo.titnat
                       and envfidc.modcod = titulo.modcod
                       and envfidc.etbcod = titulo.etbcod
                       and envfidc.clifor = titulo.clifor
                       and envfidc.titnum = titulo.titnum
                       and envfidc.titpar = titulo.titpar
                       and envfidc.lottip = vlottip
                       and envfidc.lotnum = vlote
                    exclusive-lock no-error.
        if not avail envfidc
        then do: 
             create envfidc.
             assign envfidc.empcod = titulo.empcod
                    envfidc.titnat = titulo.titnat
                    envfidc.modcod = titulo.modcod
                    envfidc.etbcod = titulo.etbcod
                    envfidc.clifor = titulo.clifor
                    envfidc.titnum = titulo.titnum
                    envfidc.titpar = titulo.titpar
                    envfidc.lottip = vlottip
                    envfidc.lotnum = vlote
                    envfidc.lotseq = vseq.
        end.


    
      assign vqtoper = vqtoper + 1
             vtotal = vtotal + titulo.titvlcob.
  
end procedure.


/* Trailer */
procedure p-registro-99.

vseq = vseq + 1.
put unformatted
    9           format "9"       /* 1 */
    ""          format "x(437)"  /* 2 */
    vseq        format "999999"  /* 3 */
    skip.

do on error undo.
    find lotefidc where lotefidc.lottip = vlottip
                    and lotefidc.lotnum = vlote
                  exclusive-lock no-error.
    assign lotefidc.data   = today
           lotefidc.hora   = time
           lotefidc.lotqtd = vlotqtde
           lotefidc.lotvlr = vlottotal.
    find current lotefidc no-lock.
end.


   find lotefin where lotefin.lotnum = vlote exclusive-lock no-error.
   if not avail lotefin
   then do:
        create lotefin.
        assign lotefin.lotnum = vlote
               lotefin.lottip = "PAG".
   end.
   assign lotefin.datexp = today
          lotefin.hora = time
          lotefin.lotqtd = vqtoper
          lotefin.lotvlr = vtotal.

end procedure.

18022022 helio carteira FIDC FINANCEIRA */

