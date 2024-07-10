def var vobs as char.
def var vlinha     as   char.
def var vfilial    as   char.
def var varq       as   char.
def var varquivo   as   char.
def var varquivox  as   char.
def var vetbcod    like estab.etbcod.
def var varqdel    as   char.
def var vclicod    like con-agil2.clfcod. 

repeat:
        
    pause 1 no-message.

    assign vlinha = "" varquivo = "" varq = "" vfilial = "" vclicod = 0
           vobs   = "" vetbcod  = 0.

   do transaction:
       find first con-agil2 where con-agil2.consit = 0 
                              and con-agil2.etbcod <> 0
                              and con-agil2.clfcod <> 0 
                              exclusive no-wait no-error.
       if avail con-agil2
       then do:
            run cria-tt.
        
            vfilial = " filial" + string(con-agil2.etbcod,"99").
        
        os-command /*no-wait */
   /home/drebes/scripts/job-rcp-conn2 value(con-agil2.clfcod) value(vfilial) " &". 

 
            delete con-agil2.

        end.

   end. 
    
end.

procedure cria-tt.         
    varquivo = "".
    varquivo = "/admcom/connect/retorna2/" + string(con-agil2.clfcod).

    output to value(varquivo).

        /***Buscando Titulos no Linux***/
        for each fin.titulo use-index iclicod where 
                 fin.titulo.empcod = 19        and
                 fin.titulo.titnat = no        and
                 /*fin.titulo.modcod = "CRE"     and*/
                 fin.titulo.clifor = con-agil2.clfcod no-lock:

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
                    fin.titulo.titvlpag.

        end.

        /************************ Prestacoes Global ***********************/

        /*for each fin.titulo use-index iclicod where 
                 fin.titulo.empcod = 19        and
                 fin.titulo.titnat = no        and
                 fin.titulo.modcod = "GLO"     and
                 fin.titulo.clifor = con-agil2.clfcod  no-lock:

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
                    fin.titulo.titvlpag.
        
        end.*/
        
        /***Buscando no Dragao***/
        for each dragao.titulo use-index iclicod
                 where dragao.titulo.empcod = 19
                   and dragao.titulo.titnat = no
                   and dragao.titulo.modcod = "CRE"     
                   and dragao.titulo.clifor = con-agil2.clfcod
                   and dragao.titulo.titsit = "LIB" no-lock:
                
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
        
        for each fin.cheque where fin.cheque.clicod = con-agil2.clfcod
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
    
end procedure.
