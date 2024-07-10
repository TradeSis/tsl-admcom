def input param poperacao   like sicred_pagam.operacao.
def input param pstatus     like sicred_pagam.sstatus.

{admbatch.i}
{acha.i}

def var vjuros as dec.
def var vdescontos as dec.

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
            lotefin.aux-ch = "FINANCEIRA - EXPORTA PAGAMENTOS".
          
    assign vlote = lotefin.lotnum.                         
    end.

    varqexp = (if poperacao = "DESENROLA" then "dr" else "pg") + string(today,"999999") + "_" + string(vlote) + ".rem".
    varquivo = "/admcom/import/financeira/" + varqexp.

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
                no-lock no-error .
            if not avail pdvmov then next.    
            find pdvdoc of pdvmov where
                pdvdoc.seqreg = sicred_pagam.seqreg
                no-lock no-error.
            if not avail pdvdoc then next.
                
                create ttenviado.
                ttenviado.psicred = recid(sicred_pagam).
        
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
     put unformat skip
         "00"                      /* 001-002 */
         varqexp format "x(08)"    /* 003-010 */
          string(today,"99999999") /* 011-018 */
          " " format "x(776)"      /* 019-079  */
          vseq format "999999" /* NUMERICO  Sequencia  */.


end procedure.

procedure p-registro-10.
  def buffer benvfinan for envfinan.
  def var tp-baixa as char.

    /*** https://trello.com/c/sf0wj7Hj/43-importa%C3%A7%C3%A3o-financeira-parcela-aci ma
-de-31
***/
    def var vparcela like titulo.titpar.
    def buffer ctitulo for titulo.  
    vparcela = titulo.titpar.
    if vparcela > 30
    then do:
        find first ctitulo where
                   ctitulo.empcod = titulo.empcod and
                   ctitulo.titnat = titulo.titnat and
                   ctitulo.modcod = titulo.modcod and
                   ctitulo.etbcod = titulo.etbcod and
                   ctitulo.clifor = titulo.clifor and
                   ctitulo.titnum = titulo.titnum and
                   ctitulo.titpar > 30 and
                   ctitulo.titpar < 51
                   no-lock no-error.
        if avail ctitulo
        then vparcela = vparcela - 30.
        else if vparcela < 51
            then vparcela = vparcela - 30.
            else vparcela = vparcela - 50.
            
        if vparcela = ? or vparcela <= 0
        then vparcela = titulo.titpar.   
  end.
  
  /*** ***/

  vseq = vseq + 1.

  tp-baixa = "10".
  if pdvdoc.pago_parcial = "S" and titulo.titsit = "LIB"
  then tp-baixa = "12".
  
  vjuros = vjuros +  if pdvdoc.valor_encargo > 0 then pdvdoc.valor_encargo else 0.
  vdescontos = vdescontos +  if pdvdoc.valor_encargo < 0 then pdvdoc.valor_encargo * -1 else 0.
  
  put unformat skip 
      "10"                          /* 001-002  TIPO  FIXO –1 */
      "0001"                        /* 003-006 AGÊNCIA        */
      dec(titulo.titnum) format "9999999999"       /* 007-016 Contrato */
      vparcela format "999"                 /* 017-019 Parcela  */
      pdvdoc.titvlcob      * 100 format "99999999999999999" /* 020-036 Vlr Par */
      vjuros * 100 format "99999999999999999" /* 037-053 Encargos */
      vdescontos  * 100 format "99999999999999999" /* 054-070 Desc */
      pdvdoc.valor         * 100 format "99999999999999999" /* 071-087 valor pago */
      "00000000000000000"                        /* 088-104 CPMF */
      "00000000000000000"                        /* 105-121 Taxas */
      "000000000000000"                          /* 122-136 Comissão */
      pdvdoc.valor * 100 format "99999999999999999" /* 137-153 Vl repass. */
      "01"                                       /* 154-155 tipo pagto */
      /*29481 v-data-vecto */
      /*30477 titulo.titdtpag */
      pdvmov.datamov format "99999999"          /* 156-163 dat pag */
      tp-baixa format "x(2)"
      "00000000"                                 /* 166-173 */
      "00000"                                    /* 174-178 */
      " "                                        /* 179-179 */ 
      "N"                                        /* 180-180 */
      "   "                                      /* 181-183 */
      " " format "x(6)"                          /* 184-189 */
      " " format "x(30)"                         /* 190-219 */
      /* helio 17052022 Adição de Campo no arquivo de Remessa de Pagamentos */ 
      pdvdoc.ctmcod format "x(575)"                             /**** era" " format "x(575)"                        /* 220-794 */ ***/
      vseq format    "999999"                    /* 795-800 */.

  assign vqtoper = vqtoper + 1
         vtotal = vtotal + titulo.titvlcob.
  find benvfinan where rowid(benvfinan) = rowid(envfinan) 
                exclusive-lock no-error.
  if avail benvfinan
  then do:
        assign benvfinan.lotpag = vlote.
        if tp-baixa = "10"
        then benvfinan.envsit = "PAG".
        else
        benvfinan.c-1 = benvfinan.c-1 +
                "PAGAMENTO" + string(titulo.titpar,"999") + "=" +
                              string(titulo.titvlcob) + ";" +
                              string(titulo.titvlpag) + ";" +
                              string(titulo.titdtpag) + ";" +
                              string(today) + ";" +
                              string(time,"hh:mm:ss") + "|".
  end.
  
end procedure.


/* Trailer */
procedure p-registro-99.
  vseq = vseq + 1.

  put unformat skip
     "99"                                 /* 01-02 fixo "99" */
     varqexp format "x(6)"                /* 03-08 Nome do arquivo */
     string(today,"99999999")             /* 09-16 data movimento */
     vqtoper format "9999999999"          /* 17-26 QTD DE OPERAÇÕES */
     vtotal  format "99999999999999999"   /* 27-43 VLR TOTAL das OPERAÇÕES */
     " " format "x(751)"                  /* 44-794 FILLER */
     vseq format    "999999" skip.

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

 