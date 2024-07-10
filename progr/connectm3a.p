def var vdata  as date format "99/99/9999".
def var vdtini as date format "99/99/9999".
def var vdtfin as date format "99/99/9999".

def var v-conta-reg as int.
def var vdia1 as int format "99".
def var vmes1 as int format "99".
def var vano1 as int format "9999".
def var vdia2 as int format "99".
def var vmes2 as int format "99".
def var vano2 as int format "9999".

def var vtime      as int.
def var v-arq      as char.
def var vtipo      as int.
def var vparam     as char.
def var vobs       as char.
def var vlinha     as char.
def var vfilial    as char.
def var varq       as char.
def var varquivo   as char.
def var varquivox  as char.
def var vtipo-price as char.
def var vseri-price as char.
def var vped-etbcod like estab.etbcod.

def var vetbcod    like estab.etbcod.
def var varqdel    as   char.
def var vclicod    like ag3.clfcod. 

def temp-table tt-tbprice like tbprice.
def temp-table tt-estoq like estoq.
def var vetbcod-nf like plani.etbcod.
def var vnumero-nf like plani.numero.
def var vdata-aux  as   char.
def var vpladat-nf as   date format "99/99/9999".

def var vparam-fil as char.

def var vcalclim as dec.
def var vpardias as dec.
def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.

FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.

def buffer tcampanha for campanha.
def buffer bpedid for com.pedid.
def var vtipo-aux as int.
def var varq-aux as char.
def temp-table tr-clien like clien.
def temp-table tr-cpclien like clien.
repeat:
        
   pause 1 no-message.

   assign vlinha = "" varquivo = "" varq = "" vfilial = "" vclicod = 0
          vobs   = "" vetbcod  = 0 vtipo = 0 vparam = "" vparam-fil = "".

   vparam-fil = SESSION:PARAMETER.

   for each tr-clien: delete tr-clien. end.
   for each tr-cpclien: delete tr-cpclien. end. 

   do transaction:
       find first ag3 where ag3.consit = 0 
                        and ag3.etbcod = int(vparam-fil)
                        and ag3.clfcod <> 0  
                        exclusive no-wait no-error.

       if avail ag3
       then do:
            if ag3.aux-param2 <> "Recebe"
            then do:
            run cria-tt.
            
            vtipo = ag3.tipo.
            if length(string(ag3.etbcod)) > 2
            then vfilial = " filial" + string(ag3.etbcod,"999").
            else vfilial = " filial" + string(ag3.etbcod,"99").

            
            if ag3.aux-param1 = ""
            then
                 v-arq   = string(vtipo,"99")
                         + string(ag3.clfcod).
            else
                 v-arq   = string(vtipo,"99")
                         + string(ag3.aux-param1).
                 
        os-command silent
  /home/drebes/scripts/job-rcp-conn3 value(v-arq) value(vfilial) " &".
            if vtipo = 1
            then do:
                vtipo-aux = 15.
                varq-aux  = string(vtipo-aux,"99")
                         + string(ag3.clfcod).
                os-command silent
  /home/drebes/scripts/job-rcp-conn3 value(varq-aux) value(vfilial) " &".
                vtipo-aux = 18.
                varq-aux  = string(vtipo-aux,"99")
                         + string(ag3.clfcod).
                os-command silent
  /home/drebes/scripts/job-rcp-conn3 value(varq-aux) value(vfilial) " &".
                vtipo-aux = 19.
                varq-aux  = string(vtipo-aux,"99")
                         + string(ag3.clfcod).
                os-command silent
  /home/drebes/scripts/job-rcp-conn3 value(varq-aux) value(vfilial) " &".

            end.
            end.
            else if ag3.aux-param2 = "Recebe"
            then do:
                vtipo = ag3.tipo.
                if length(string(ag3.etbcod)) > 2
                then vfilial = " filial" + string(ag3.etbcod,"999").
                else vfilial = " filial" + string(ag3.etbcod,"99").
            
                if ag3.aux-param1 = ""
                then v-arq   = string(vtipo,"99") + string(ag3.clfcod).
                else v-arq   = string(vtipo,"99") + string(ag3.aux-param1).
             
                os-command silent
  /home/drebes/scripts/job-rcp-busca-agi value(v-arq) value(vfilial) " &".
                pause 1 no-message.
                run recebe-dados.
            end.
            vtime = 0.
            vtime = time.
            
            find log-ag3 where log-ag3.etbcod = ag3.etbcod
                           and log-ag3.clfcod = ag3.clfcod
                           and log-ag3.data   = today
                           and log-ag3.hora   = vtime no-error.
            if not avail log-ag3
            then do:
                create log-ag3.   
                assign log-ag3.etbcod       = ag3.etbcod
                       log-ag3.clfcod       = ag3.clfcod
                       log-ag3.consit       = 1
                       log-ag3.aux-param[1] = ag3.aux-param[1]
                       log-ag3.aux-param[2] = ag3.aux-param[2]
                       log-ag3.aux-param[3] = ag3.aux-param[3]
                       log-ag3.aux-param[4] = ag3.aux-param[4]
                       log-ag3.aux-param[5] = ag3.aux-param[5]
                       log-ag3.aux-param1   = ag3.aux-param1
                       log-ag3.aux-param2   = ag3.aux-param2
                       log-ag3.tipo         = ag3.tipo
                       log-ag3.cxacod       = 0
                       log-ag3.data         = today
                       log-ag3.hora         = vtime.
            end.
            
            delete ag3.
            
        end.
        run atualiza-dados.
   end. 
    
end.

procedure cria-tt.         

    varquivo = "".
    
    if ag3.aux-param1 = ""
    then do:
        varquivo = "/admcom/connect/retorna3/filial".
        if length(string(ag3.etbcod)) > 2
        then varquivo = varquivo + string(ag3.etbcod,"999").
        else varquivo = varquivo + string(ag3.etbcod,"99"). 
        varquivo = varquivo + "/" + string(ag3.tipo,"99") + string(ag3.clfcod).
    end.
    else do:
        varquivo = "/admcom/connect/retorna3/filial".
        if length(string(ag3.etbcod)) > 2
        then varquivo = varquivo + string(ag3.etbcod,"999").
        else varquivo = varquivo + string(ag3.etbcod,"99"). 
        varquivo = varquivo + "/" + string(ag3.tipo,"99") 
                                    + string(ag3.aux-param1).
    end.
    
    if ag3.tipo = 1
    then do:
      output to value(varquivo).

        /***Buscando Titulos no Linux***/
        for each fin.titulo use-index iclicod where 
                 fin.titulo.empcod = 19        and
                 fin.titulo.titnat = no        and
                 /*fin.titulo.modcod = "CRE"     and*/
                 fin.titulo.clifor = ag3.clfcod no-lock:
             
             if fin.titulo.modcod = "CHQ" then next.
             
             export fin.titulo.empcod
                    fin.titulo.modcod
                    fin.titulo.clifor
                    fin.titulo.titnum
                    fin.titulo.titpar
                    fin.titulo.titnat
                    fin.titulo.etbcod
                    fin.titulo.titdtemi
                    fin.titulo.titdtven
                    fin.titulo.titvlcob
                    fin.titulo.titsit    
                    fin.titulo.titdtpag
                    fin.titulo.titvlpag
                    fin.titulo.titobs[1]
                    fin.titulo.moecod.

        end.
        
        for each fin.titulo use-index iclicod where 
                 fin.titulo.empcod = 19        and
                 fin.titulo.titnat = yes       and
                 fin.titulo.modcod = "BON"     and
                 fin.titulo.clifor = ag3.clfcod no-lock:

             if fin.titulo.titobs[1] <> ""
             then find acao where
                       acao.acaocod = int(fin.titulo.titobs[1])
                       no-lock no-error.
                       
             export fin.titulo.empcod
                    fin.titulo.modcod
                    fin.titulo.clifor
                    fin.titulo.titnum
                    fin.titulo.titpar
                    fin.titulo.titnat
                    fin.titulo.etbcod
                    fin.titulo.titdtemi
                    fin.titulo.titdtven
                    fin.titulo.titvlcob
                    fin.titulo.titsit    
                    fin.titulo.titdtpag
                    fin.titulo.titvlpag
                    fin.titulo.titobs[1]
                    fin.titulo.moecod
                    fin.titulo.titagepag
                    acao.descricao when avail acao
                    .
        end.
        /***Buscando no Dragao***/
        for each dragao.titulo use-index iclicod
                 where dragao.titulo.empcod = 19
                   and dragao.titulo.titnat = no
                   and dragao.titulo.modcod = "CRE"     
                   and dragao.titulo.clifor = ag3.clfcod
                   /*and dragao.titulo.titsit = "LIB"*/ no-lock:
                
             export dragao.titulo.empcod
                    dragao.titulo.modcod
                    dragao.titulo.clifor
                    dragao.titulo.titnum
                    dragao.titulo.titpar
                    dragao.titulo.titnat
                    dragao.titulo.etbcod
                    dragao.titulo.titdtemi
                    dragao.titulo.titdtven
                    dragao.titulo.titvlcob
                    dragao.titulo.titsit
                    dragao.titulo.titdtpag
                    dragao.titulo.titvlpag.
   
        end.                                
        /***Buscando Cheques Devolvidos***/
        
        for each fin.cheque where fin.cheque.clicod = ag3.clfcod
                              and fin.cheque.chesit = "LIB" no-lock:
            
                vobs = "".
                vobs = "NOME="     + string(fin.cheque.nome).
                
                if fin.cheque.cheemi <> ?
                then vobs = vobs  + "|CHEEMI=" + string(fin.cheque.cheemi).
                else vobs = vobs  + "|CHEEMI=?".
                  
                if fin.cheque.cheven <> ?
                then vobs = vobs + "|CHEVEN=" + string(fin.cheque.cheven).
                else vobs = vobs + "|CHEVEN=?".

                vobs = vobs + "|CHEVAL="  + string(fin.cheque.cheval)
                            + "|CHENUM="  + string(fin.cheque.chenum)
                            + "|CHEBAN="  + string(fin.cheque.cheban)
                            + "|CHEAGE="  + string(fin.cheque.cheage)
                            + "|CHECID="  + string(fin.cheque.checid)
                            + "|CHEETB="  + string(fin.cheque.cheetb)
                            + "|CHEALIN=" + string(fin.cheque.chealin).
                       
                if fin.cheque.chedti <> ?
                then vobs = vobs + "|CHEDTI=" + string(fin.cheque.chedti).
                else vobs = vobs + "|CHEDTI=?".
                
                if fin.cheque.chedtf <> ?
                then vobs = vobs + "|CHEDTF="  + string(fin.cheque.chedtf).
                else vobs = vobs + "|CHEDTF=?".
                     
                vobs = vobs + "|CHESIT="  + string(fin.cheque.chesit)
                            + "|CODCOB="  + string(fin.cheque.codcob) 
                            + "|CLICOD="  + string(fin.cheque.clicod).
                            
                if fin.cheque.chepag <> ?
                then vobs = vobs + "|CHEPAG="  + string(fin.cheque.chepag).
                else vobs = vobs + "|CHEPAG=?".

                vobs = vobs + "|CHEJUR="  + string(fin.cheque.chejur).
                       
                export "19"
                       "CHQ"
                       fin.cheque.clicod
                       fin.cheque.chenum
                       "1"
                       "no"
                       fin.cheque.cheetb
                       fin.cheque.cheemi
                       fin.cheque.cheven
                       fin.cheque.cheval
                       "LIB"
                       ?
                       0
                       vobs.
        end.
        
      output close.
      varquivo = "/admcom/connect/retorna3/filial".
        if length(string(ag3.etbcod)) > 2
        then varquivo = varquivo + string(ag3.etbcod,"999").
        else varquivo = varquivo + string(ag3.etbcod,"99"). 
      varquivo = varquivo + "/" + "15" + string(ag3.clfcod).
      output to value(varquivo).
      for each tcampanha where
               tcampanha.clicod = ag3.clfcod no-lock,
        first acao where acao.acaocod = tcampanha.acaocod no-lock:
        if acao.dtini <= today and
           acao.dtfin >= today
        then export tcampanha.
      end.         
      output close.
      varquivo = "/admcom/connect/retorna3/filial".
        if length(string(ag3.etbcod)) > 2
        then varquivo = varquivo + string(ag3.etbcod,"999").
        else varquivo = varquivo + string(ag3.etbcod,"99"). 
      varquivo = varquivo + "/" + "18" + string(ag3.clfcod).
      output to value(varquivo).
      for each clien where
               clien.clicod = ag3.clfcod no-lock:
            vcalclim = 0.
            vpardias = 0.
            /*
            run calccredscore.p (input "",
                        input recid(clien),
                        output vcalclim,
                        output vpardias).
            */
            export clien.
            /*
            export vcalclim.
            */
      end.                
      output close.
      varquivo = "/admcom/connect/retorna3/filial".
        if length(string(ag3.etbcod)) > 2
        then varquivo = varquivo + string(ag3.etbcod,"999").
        else varquivo = varquivo + string(ag3.etbcod,"99"). 
      varquivo = varquivo + "/" + "19" + string(ag3.clfcod).
      output to value(varquivo).
      for each cpclien where
               cpclien.clicod = ag3.clfcod no-lock:
            export cpclien.
      end.          
      output close.
    end.
    if ag3.tipo = 2
    then do:
      output to value(varquivo).
         if ag3.aux-param1 = ""
         then do:
             for each plani where plani.movtdc = 5
                              and plani.desti  = ag3.clfcod no-lock:
             
                 export plani.
             
             end.
         end.
         else do:
             assign vetbcod-nf = 0
                    vnumero-nf = 0
                    vdata-aux  = ""
                    vpladat-nf = ?
                    vetbcod-nf = int(substring(ag3.aux-param1,1,3))
                    vnumero-nf = int(substring(ag3.aux-param1,4,10))
                    vdata-aux  =
                            substr(ag3.aux-param1,14,length(ag3.aux-param1))
                    vpladat-nf = date(vdata-aux).
                    
             v-conta-reg = 0.
             for each plani where plani.movtdc = 5
                              and plani.etbcod = vetbcod-nf
                              and plani.emite  = vetbcod-nf
                              and plani.serie  = "V"
                              and plani.numero = vnumero-nf no-lock:

                 v-conta-reg = v-conta-reg + 1.
                 export plani.
             
             end.
             
             if v-conta-reg = 0
             then put "NOTA_NAO_ENCONTRADA_NA_MATRIZ".
         
         end.
      output close.
    end.  

    if ag3.tipo = 3
    then do:
      output to value(varquivo).
         if ag3.aux-param1 = ""
         then do:
             for each plani where plani.movtdc = 5
                              and plani.desti  = ag3.clfcod no-lock:
                 for each movim where movim.etbcod = plani.etbcod
                                  and movim.placod = plani.placod
                                  and movim.movtdc = plani.movtdc
                                  and movim.movdat = plani.pladat no-lock:
                              
                     export movim.
                 end.
             end.
         end.
         else do:
             assign vetbcod-nf = 0
                    vnumero-nf = 0
                    vdata-aux  = ""
                    vpladat-nf = ?
                    vetbcod-nf = int(substring(ag3.aux-param1,1,3))
                    vnumero-nf = int(substring(ag3.aux-param1,4,10))
                    vdata-aux  =
                            substr(ag3.aux-param1,14,length(ag3.aux-param1))
                    vpladat-nf = date(vdata-aux).

             for each plani where plani.movtdc = 5
                              and plani.etbcod = vetbcod-nf
                              and plani.emite  = vetbcod-nf
                              and plani.serie  = "V"
                              and plani.numero = vnumero-nf no-lock:
          
                 for each movim where movim.etbcod = plani.etbcod
                                  and movim.placod = plani.placod
                                  and movim.movtdc = plani.movtdc
                                  and movim.movdat = plani.pladat no-lock:

                     export movim.
                     
                 end.
             end.
        end.             
      output close.
    end.  
    
    if ag3.tipo = 5
    then do:
      output to value(varquivo).
         if ag3.aux-param1 = ""
         then do:
             for each plani where plani.movtdc = 5
                              and plani.desti  = ag3.clfcod no-lock:

                 for each fin.contnf where 
                          fin.contnf.etbcod = plani.etbcod 
                      and fin.contnf.placod = plani.placod no-lock:

                     export fin.contnf.etbcod 
                            fin.contnf.placod
                            fin.contnf.contnum.
                 
                 end.
                 
             end.
         end.
         else do:

         
         
         end.
      output close.
    end.
    
    if ag3.tipo = 6
    then do:
      output to value(varquivo).
         if ag3.aux-param1 = ""
         then do:
             for each fin.contrato where 
                      fin.contrato.clicod = ag3.clfcod no-lock:
                 export fin.contrato.
             end.
         end.
         else do:
         
         end.
      output close.   
    end.

    if ag3.tipo = 7 /*Pedid*/
    then do:
      output to value(varquivo).
         if ag3.aux-param1 = ""
         then do:
            for each com.pedid where com.pedid.pedtdc = 3
                              and com.pedid.etbcod = ag3.etbcod
                              and com.pedid.peddat >= (today - 60) no-lock:
                export com.pedid.        
            end.
         end.
         else do:
            for each com.pedid where com.pedid.pedtdc = 3
                              and com.pedid.etbcod = ag3.etbcod
                              and com.pedid.peddat >= (today - 60) 
                              and com.pedid.modcod  = ag3.aux-param1
                               no-lock:
                export com.pedid.        
            end.
         end.
      output close.   
    end.
    
    if ag3.tipo = 8 /*Liped*/
    then do:
      output to value(varquivo).
         if ag3.aux-param1 = ""
         then do:
         for each com.pedid where com.pedid.pedtdc = 3
                              and com.pedid.etbcod = ag3.etbcod
                              and com.pedid.peddat >= (today - 60) no-lock:
            for each com.liped where
                     com.liped.etbcod = com.pedid.etbcod and
                     com.liped.pedtdc = com.pedid.pedtdc and
                     com.liped.pednum = com.pedid.pednum
                      no-lock:
            
                export com.liped.
            
            end.
            
         end.
         end.
         else do:
            for each com.pedid where com.pedid.pedtdc = 3
                              and com.pedid.etbcod = ag3.etbcod
                              and com.pedid.peddat >= (today - 60) 
                              and com.pedid.modcod  = ag3.aux-param1
                              no-lock:
                for each com.liped where
                     com.liped.etbcod = com.pedid.etbcod and
                     com.liped.pedtdc = com.pedid.pedtdc and
                     com.liped.pednum = com.pedid.pednum
                      no-lock:
                    export com.liped.
                end.                       
            end.
         end.

      output close.   
    end.

    if ag3.tipo = 9 /*Ass. Tec.*/
    then do:
      output to value(varquivo).
         for each adm.asstec where adm.asstec.etbcod = ag3.etbcod no-lock:
            export adm.asstec.         
         end.
      output close.   
    end.
    
    if ag3.tipo = 10 /* titulo - etbcod - dtven */
    then do:
        output to value(varquivo).
          if ag3.aux-param1 <> ""
          then do:
            assign vdia1 = 0 vmes1 = 0 vano1 = 0
                   vdia2 = 0 vmes2 = 0 vmes2 = 0

                   vdia1 = int(substring(ag3.aux-param1,4,2))
                   vmes1 = int(substring(ag3.aux-param1,6,2))
                   vano1 = int(substring(ag3.aux-param1,8,4))

                   vdia2 = int(substring(ag3.aux-param1,12,2))
                   vmes2 = int(substring(ag3.aux-param1,14,2))
                   vano2 = int(substring(ag3.aux-param1,16,4)) 
                   
                   vdtini = date(vmes1,vdia1,vano1)
                   vdtfin = date(vmes2,vdia2,vano2).

            do vdata = vdtini to vdtfin:
                FOR each fin.titulo use-index titdtven
                              where fin.titulo.empcod = 19 
                                and fin.titulo.titnat = no             
                                and fin.titulo.modcod = "CRE"          
                                and fin.titulo.titdtven = vdata        
                                and fin.titulo.etbcod   = ag3.etbcod  
                                and fin.titulo.titsit = "LIB" no-lock:
                 
                        export fin.titulo.
                            
                END.
            end.
            
          end.
          else put "Parametro nao invalido.".
        output close. 
    end.

    if ag3.tipo = 11 /*Cheque Presente.*/
    then do:
      output to value(varquivo).

         for each fin.titulo where fin.titulo.empcod = 19           
                               and fin.titulo.titnat = yes
                               and fin.titulo.modcod = "CHP"     
                               and fin.titulo.etbcod = 99
                               and fin.titulo.clifor = 110165
                               and fin.titulo.titnum = ag3.aux-param1
                               and fin.titulo.titpar = 1
                               no-lock:
              
              export fin.titulo.empcod
                     fin.titulo.modcod
                     fin.titulo.clifor
                     fin.titulo.titnum
                     fin.titulo.titpar
                     fin.titulo.titnat
                     fin.titulo.etbcod
                     fin.titulo.titdtemi
                     fin.titulo.titdtven
                     fin.titulo.titvlcob
                     fin.titulo.titsit    
                     fin.titulo.titdtpag
                     fin.titulo.titvlpag
                     fin.titulo.titobs[1]
                     fin.titulo.moecod.

         end.
      
      output close.   
    end.
    
    
    if ag3.tipo = 12    /**Contrato DRAGAO**/
    then do:
      output to value(varquivo).
         if ag3.aux-param1 = ""
         then do:
             for each dragao.contrato where 
                      dragao.contrato.clicod = ag3.clfcod no-lock:
                 export dragao.contrato.
             end.
         end.
      output close.   
    end.
    
    if ag3.tipo = 13    /**titluc - despesas financeiras**/
    then do:
      output to value(varquivo).
         if ag3.aux-param1 = ""
         then do:
             for each fin.titluc where
                      fin.titluc.etbcod = ag3.etbcod and
                      fin.titluc.titsit <> "PAG"
                      no-lock.
                 export fin.titluc.
             end.
         end.
      output close.   
    end.
    if ag3.tipo = 14    /**tbprice **/
    then do:
      output to value(varquivo).
         if ag3.aux-param1 <> ""
         then do:
             vtipo-price = "".
             vseri-price = ag3.aux-param1.
             /* */
             find first adm.tbprice where 
                  adm.tbprice.tipo = vtipo-price and
                  adm.tbprice.serial = vseri-price 
                  no-lock no-error.
             /* */
             if not avail adm.tbprice
             then find first adm.tbprice where 
                  adm.tbprice.serial = vseri-price 
                  no-lock no-error.
             /* */
             if avail adm.tbprice
             then do:
                export adm.tbprice.
             end.
             else do:
                find first adm.tbprice where
                           adm.tbprice.etb_venda = 
                                int(substr(string(ag3.aux-param1),1,3)) and
                           adm.tbprice.data_venda =
                                date(int(substr(string(ag3.aux-param1),6,2)),
                                     int(substr(string(ag3.aux-param1),4,2)),
                                     int(substr(string(ag3.aux-param1),8,4)))
                                      and
                           adm.tbprice.nota_venda =
                                int(substr(string(ag3.aux-param1),12,9))
                           no-lock no-error.
                if avail adm.tbprice
                then do:
                    export adm.tbprice.
                end.
                else do:
                    find first adm.tbcntgen where
                         tbcntgen.tipcon = 4 and
                         tbcntgen.etbcod = ag3.etbcod no-lock no-error.
                    if not avail tbcntgen
                    then do:
                        create tt-tbprice.
                        tt-tbprice.serial = vseri-price.
                        export tt-tbprice.
                        delete tt-tbprice.
                    end.
                end.
             end.
         end.
         else do:
         end.
      output close. 
    end.
    if ag3.tipo = 15    /**CRM-Campanha**/
    then do:
         /********
         if ag3.aux-param1 <> ""
         then do:
             input from /admcom/bonus/campanha.d
             .
             repeat:
                create tcampanha.
                import tcampanha.
                if tcampanha.clicod <> ag3.clfcod
                then delete tcampanha.
             end.   
             input close.
             output to value(varquivo).
             for each tcampanha:
                export tcampanha.
             end.   
             output close.
         end.
         *****/
      output close.   
    end.
    if ag3.tipo = 16    /**clitel**/
    then do:
      output to value(varquivo).
      for each clitel where clitel.clicod = ag3.clfcod no-lock.
        find tipcont of clitel no-lock no-error.
        export clitel.CliCod     
               clitel.teldat     
               clitel.telhor     
               clitel.FunCod     
               clitel.telobs     
               clitel.titcod     
               clitel.titnum     
               clitel.datac      
               clitel.tiphis     
               clitel.codcont    
               clitel.dtpagcont  
               clitel.fonecont   
               clitel.ndiascont  
               clitel.carta      
               clitel.spc        
               clitel.hrpagcont  
               clitel.etbcod     
               clitel.empcod    
               clitel.modcod  
               clitel.titnat  
               clitel.titpar  
               clitel.etbcobra
               if avail tipcont
               then tipcont.desccont
               else "".
      end.
      output close.   
    end.
    if ag3.tipo = 17    /**Estoque**/
    then do:
      def buffer bestoq for estoq.  
      def var vlipqtd like liped.lipqtd.
      find estoq where estoq.etbcod = 900 and
                         estoq.procod = ag3.clfcod no-lock no-error.
      if avail estoq
      then do:
          find bestoq where bestoq.etbcod = 995 and
                            bestoq.procod = ag3.clfcod no-lock no-error.
          create tt-estoq.
          buffer-copy estoq to tt-estoq.
          if avail bestoq and
                   bestoq.estatual > 0
          then tt-estoq.estatual = tt-estoq.estatual + bestoq.estatual.
          tt-estoq.estpedven = 0.
          do vdata = today - 10 to today.
            for each liped where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = estoq.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                tt-estoq.estpedven = tt-estoq.estpedven + liped.lipqtd.
            
            end.
          end.
          for each liped where /*liped.etbcod = 86 and*/
                                 liped.procod = estoq.procod and
                                 liped.pedtdc = 1 and
                                 (liped.predtf = ? or
                                 liped.predtf >= today - 30) no-lock,
              first pedid of liped where pedid.pedsit = yes and
                            pedid.sitped <> "F"  and
                            pedid.peddat > today - 180   no-lock:
                            
              find first bpedid where 
                        (bpedid.pedtdc = 4 or
                         bpedid.pedtdc = 6) and
                         bpedid.pedsit = yes and
                         bpedid.comcod = pedid.pednum
                         no-lock no-error.
              if avail bpedid
              then next.
              
              tt-estoq.estpedcom = tt-estoq.estpedcom + 
                        (liped.lipqtd - liped.lipent).
              
              if liped.predtf = ?
              then do:
                tt-estoq.estloc = tt-estoq.estloc +
                    "SEM PREVISAO=" +
                    string(liped.lipqtd - liped.lipent,">>>9") + " | ".
              end.
              else if liped.predtf >= today
              then do:
                tt-estoq.estloc = tt-estoq.estloc +
                    string(liped.predtf,"99/99/9999") + "=" +
                    string(liped.lipqtd - liped.lipent,">>>9") + " | ".
              end.
              else do:
                tt-estoq.estloc = tt-estoq.estloc +
                    "Previsao estourada=" +
                    string(liped.lipqtd - liped.lipent,">>>9") + " | ".
              end.
          end.
          find bestoq where bestoq.etbcod = ag3.etbcod and
                            bestoq.procod = ag3.clfcod no-lock no-error.
          if avail bestoq
          then  do:
            find last movim where 
                      movim.etbcod = ag3.etbcod and
                      movim.movtdc = 5 and
                      movim.procod = bestoq.procod
                      no-lock no-error.
            tt-estoq.estinvqtd = bestoq.estatual.
            if avail movim
            then tt-estoq.estinvctm = movim.placod.
            else tt-estoq.estinvctm = 0.
          end.  
          else tt-estoq.estinvqtd = 0.
      end.
      output to value(varquivo).
      for each tt-estoq no-lock:
        export tt-estoq.
      end.
      output close.
      for each tt-estoq:
        delete tt-estoq.
      end.  
    end.
    if ag3.tipo = 18    /**clien**/
    then do:
        /**
      output to value(varquivo).
      for each clien where clien.clicod = ag3.clfcod no-lock.
        export clien.
      end.  
      output close.
      ***/
    end.
    if ag3.tipo = 19 /**cpclien**/
    then do:
       /**
      output to value(varquivo).
      for each cpclien where cpclien.clicod = ag3.clfcod no-lock.
        export cpclien.
      end.  
      output close.
       **/
    end.
end procedure.

procedure recebe-dados:
    for each tr-clien: delete tr-clien. end.
    for each tr-cpclien: delete tr-cpclien. end.
    if vtipo = 18
    then do:
        v-arq =  "/admcom/connect/retorna/" + v-arq.
        input from value(v-arq).
        repeat:
            create tr-clien.
            import tr-clien.
        end.
        input close.
        for each tr-clien where tr-clien.clicod = 0:
            delete tr-clien.
        end.    
        unix silent value(" rm " + v-arq).
    end.
    if vtipo = 19
    then do:
        v-arq =  "/admcom/connect/retorna/" + v-arq.
        input from value(v-arq).
        repeat:
            create tr-cpclien.
            import tr-cpclien.
        end.
        input close.
        for each tr-cpclien where tr-cpclien.clicod = 0:
            delete tr-cpclien.
        end.    
        unix silent value (" rm " + v-arq).
    end.
end procedure.

procedure atualiza-dados:
        def buffer c-clien for clien.
        def buffer c-cpclien for cpclien.
        for each tr-clien where tr-clien.clicod > 0:
            find c-clien where c-clien.clicod = tr-clien.clicod no-error.
            if not avail c-clien
            then create c-clien.
            buffer-copy tr-clien to c-clien.
            delete tr-clien.
        end.        
        
        for each tr-cpclien where tr-cpclien.clicod > 0:
            find c-cpclien where c-cpclien.clicod = tr-cpclien.clicod no-error.
            if not avail c-cpclien
            then create c-cpclien.
            buffer-copy tr-cpclien to c-cpclien.
            delete tr-cpclien.
        end.        
end procedure.

