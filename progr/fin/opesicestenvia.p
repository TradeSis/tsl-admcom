def input param poperacao   like sicred_pagam.operacao.
def input param pstatus     like sicred_pagam.sstatus.

{admbatch.i}
{acha.i}


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
        datamov asc ctmcod asc
        modcod asc
        tpcontrato asc 
        lotnum  .

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
            lotefin.lottip = "EST"
            lotefin.aux-ch = "FINANCEIRA - EXPORTA ESTORNOS".
          
    assign vlote = lotefin.lotnum.                         
    end.

    varqexp = "es" + string(today,"999999") + "_" + string(vlote) + ".rem".
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
                no-lock .
            find pdvdoc of pdvmov where
                pdvdoc.seqreg = sicred_pagam.seqreg
                no-lock.
                
                create ttenviado.
                ttenviado.psicred = recid(sicred_pagam).
        
                run p-registro-60.    

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

procedure p-registro-60.
def var vvalor as dec.
  def buffer benvfinan for envfinan.
  def buffer bpdvdoc   for pdvdoc.
  vseq = vseq + 1.

  find last bpdvdoc where
        bpdvdoc.contnum = pdvdoc.contnum and
        bpdvdoc.titpar  = pdvdoc.titpar  and
        bpdvdoc.pstatus = yes and
        bpdvdoc.valor   = pdvdoc.valor * -1  and
        recid(bpdvdoc) <> recid(pdvdoc) and
        bpdvdoc.datamov <= pdvdoc.datamov
        no-lock no-error.

    vvalor = if pdvdoc.valor < 0 then pdvdoc.valor * -1 else pdvdoc.valor. /* helio 16102023 - ID 49213 - Arquivo exportador financeira */
    
  put unformat skip 
      "60"                          /* 001-002  TIPO  FIXO –1 */
      "0001"                        /* 003-006 AGÊNCIA        */
      dec(titulo.titnum) format "9999999999"       /* 007-016 Contrato */
      titulo.titpar format "999"                 /* 017-019 Parcela  */
      titulo.titdtven format "99999999"          /* 156-163 dat pag */
      "000"
      (if avail bpdvdoc
       then bpdvdoc.datamov
       else pdvdoc.datamov) format "99999999"          /* 156-163 dat pag */
       
      pdvdoc.datamov  format "99999999"          /* 156-163 dat pag */ /* helio 13012021 */
      "N000" format "x(04)"
      pdvdoc.datamov  format "99999999"        /* 156-163 dat pag */
      vvalor         * 100 format "999999999999" /* 071-087 valor pago */
      " " format "x(725)"                        /* 220-794 */
      vseq format    "999999"                    /* 795-800 */.

  assign vqtoper = vqtoper + 1
         vtotal = vtotal + (vvalor )  .
         
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
               lotefin.lottip = "EST".
   end.
   assign lotefin.datexp = today
          lotefin.hora = time
          lotefin.lotqtd = vqtoper
          lotefin.lotvlr = vtotal.

end procedure.

 