{admcab.i new}
   
def temp-table tt-icms
        field etbcod like estab.etbcod
        field icms-ven as dec
        field icms-com as dec
        index i1 etbcod.

def var vnumlan like lancxa.numlan.
def var vlivre as char.
def var vopfcod as int.
def buffer blancxa for lancxa.
        
def temp-table tt-lanca
    field etbcod like estab.etbcod
    field etbcre as char
    field etbdeb as char
    field subdeb as char
    field subcre as char
    field cre  as char
    field deb  as char
    field val  as dec format ">,>>>,>>9.99" 
    field cod  as int format "999"
    field his  as char format "x(50)"
    field data like fiscal.plarec
    field total_lote as int
    field seq  as int. 
 
def temp-table tt-cab
    field data   like fiscal.plarec
    field qtdlot as int
    field totval like fiscal.platot
    field codlot as char.
 
form /*vetbcod like estab.etbcod   at 1  LABEL "Filial"
     estab.etbnom                           no-label
    */
     vdti as date label "Data Inicial" at 1
     vdtf as date label "Data Final"
     with frame f1 1 down width 80 side-label.
      
form
    lancxa.datlan  colon 15
    skip
    lancxa.cxacod  colon 15 format ">>>>>9"  label "Deb"
    skip
    lancxa.lancod  colon 15 format ">>>>>9"  label "Cred"
    skip
    lancxa.vallan  colon 15  format ">>>,>>9.99" 
    skip
    lancxa.forcod  colon 15
    skip
    lancxa.titnum  colon 15 format "x(25)" 
    skip
    lancxa.comhis  colon 15  format "x(50)"
    with frame f-linha3 
        centered row 10 
        color white/red overlay side-labels 1 down title "Alterando ...".


do on error undo, return with frame f1:
    /*update vetbcod.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom.
    end. */
    update vdti vdtf.
    if vdti > vdtf
    then undo.
end.    

def var varquivo as char.

def var vtotal-ic as dec format ">>,>>>,>>9.99".
def var vtotal-iv as dec format ">>,>>>,>>9.99".

form
    lancxa.datlan
        help "ENTER=Altera F1=Exporta F8=Procura F10=Exclui"
    lancxa.cxacod  label "Deb"   format ">>>>>9"
    lancxa.lancod  label "Cred"  format ">>>>>9"
    lancxa.vallan  format ">>>,>>9.99"
    lancxa.lanhis  label "Hst" format ">>9"
    lancxa.comhis  format "x(35)"
    lancxa.lansit  format "x" column-label "S" 
    with frame f-linha
        centered
        color white/cyan
        down.
def var vlote as char.
{setbrw.i}
l1: repeat:
    
    for each lancxa where
             lancxa.datlan >= vdti and
             lancxa.datlan <= vdtf and
             lancxa.lantip = "X"   and
             not can-find(first titulo
                          where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = lancxa.modcod
                            and titulo.etbcod = lancxa.etbcod
                            and titulo.clifor = lancxa.forcod
                            and titulo.titnum = lancxa.titnum
                            and titulo.titdtemi = lancxa.datlan
                            and titulo.titsit = "BLO")
                         no-lock:
            vtotal-iv = vtotal-iv + lancxa.val.
    end.
    disp vtotal-iv
         with frame f-total 
         1 down no-box row 21 no-label column 33.
     
     pause 0.


        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.
    
        {sklcls.i
            &color  = withe
            &color1 = red
            &File   = lancxa
            &CField = lancxa.datlan    
            &Ofield = "lancxa.lancod lancxa.cxacod lancxa.comhis
                    lancxa.lanhis lancxa.vallan lancxa.lansit"
            &Color = "white/red"   
            &NonCharacter = /*        
            &Where = "lancxa.datlan >= vdti and
                      lancxa.datlan <= vdtf and
                      lancxa.lantip = ""X"" and
                      not can-find(first titulo
                          where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = lancxa.modcod
                            and titulo.etbcod = lancxa.etbcod
                            and titulo.clifor = lancxa.forcod
                            and titulo.titnum = lancxa.titnum
                            and titulo.titdtemi = lancxa.datlan
                            and titulo.titsit = ""BLO"")"
            &AftSelect1 =    "
                if keyfunction(lastkey) = ""RETURN"" 
                then do : 
                    update lancxa.datlan lancxa.cxacod lancxa.lancod
                            lancxa.vallan lancxa.forcod lancxa.titnum 
                            lancxa.comhis with frame f-linha3.
                    disp   lancxa.datlan lancxa.cxacod lancxa.lancod
                           lancxa.vallan  
                           lancxa.comhis with frame f-linha. 
                          next keys-loop.
                end. "
            &Otherkeys1  = " if keyfunction(lastkey) = ""GO"" 
                            then leave keys-loop. "
            &naoexiste1  = " bell.
                        message color red/with
                        ""Nenhum registro encontrado""
                        view-as alert-box.
                        leave l1.
                        "
            &procura1 = " prompt-for lancxa.titnum
                            with frame f-procura 1 down centered row 10
                            side-label overlay.
                          find first blancxa where
                                     blancxa.datlan >= vdti and
                                     blancxa.datlan <= vdtf and
                                     blancxa.lantip  = ""X"" and
                                     blancxa.titnum  = 
                                     input frame f-procura lancxa.titnum
                                     no-lock no-error.
                          if not avail blancxa
                          then do:
                              bell.
                              message color red/with
                              ""Nenhum registro encontrado""
                              view-as alert-box .
                              next keys-loop.
                          end.           
                          a-seeid = -1.
                          a-recid = recid(blancxa).
                          next keys-loop.
                         "    
            &Form = " frame f-linha "
        }.

    if keyfunction(lastkey) = "end-error"
    then leave l1.

    if keyfunction(lastkey) = "GO"
    then do:
        bell.
        vlote = "".
        message color red/with
        "Informe o numero do LOTE "
        update vlote.
        if vlote = ""
        then next l1.
        
        for each tt-lanca: delete tt-lanca. end.
        for each tt-cab: delete tt-cab. end.
        
        /*
        find first tt-cab where tt-cab.data = vdtf no-error.
        if not avail tt-cab
        then do:
            create tt-cab.
            assign tt-cab.data   = vdtf
                   tt-cab.codlot = vlote + string(day(vdtf),"99").

        end.
        */
        
        for each lancxa where
                      lancxa.datlan >= vdti and
                      lancxa.datlan <= vdtf and
                      lancxa.lantip = "X"   and
                      not can-find(first titulo
                          where titulo.empcod = 19
                            and titulo.titnat = yes
                            and titulo.modcod = lancxa.modcod
                            and titulo.etbcod = lancxa.etbcod
                            and titulo.clifor = lancxa.forcod
                            and titulo.titnum = lancxa.titnum
                            and titulo.titdtemi = lancxa.datlan
                            and titulo.titsit = "BLO")
                      no-lock: 

            find first tt-cab where tt-cab.data = lancxa.datlan no-error.
            if not avail tt-cab
            then do:
                create tt-cab.
                assign tt-cab.data   = lancxa.datlan.
            end.
            assign tt-cab.qtdlot = tt-cab.qtdlot + 1
               tt-cab.codlot = vlote + string(day(lancxa.datlan),"99")
               tt-cab.totval = tt-cab.totval + lancxa.val.
 
            find first hispad where
                       hispad.hiscod = lancxa.lanhis no-lock.
            create tt-lanca. 
            assign tt-lanca.etbcod  = 01001
                   tt-lanca.etbcre  = "01001"
                   tt-lanca.etbdeb  = "01" +  
                        if lancxa.etbcod = 999 
                        then "996" 
                        else if lancxa.etbcod = 98
                         then "093" else string(lancxa.etbcod,"999")
                   tt-lanca.data    = lancxa.datlan
                   tt-lanca.cre     = string(lancxa.lancod)  
                   tt-lanca.deb     = string(lancxa.cxacod)
                   tt-lanca.cod     = 0   
                   tt-lanca.subcre  = string(lancxa.forcod)
                   tt-lanca.val     = lancxa.val
                   tt-lanca.his     = "*LIVRE@" + STRING(hispad.hisdes) +
                                     " " + string(lancxa.comhis)
                   /*"*LIVRE@S/NT.N. " 
                               +  string(lancxa.comhis)*/
                   .
            end.
        end.
        run exporta-sispro.
end.


procedure exporta-sispro:
    def var v-seq as int.
    def var cd_batch as char.
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/sispro/extra_caixa/"  + "extc" +
                         string(day(vdti),"99") + 
                         "a" + 
                         string(day(vdtf),"99")  + 
                         string(month(vdtf),"99") + 
                         string(year(vdtf),"9999") + ".txt".
    else varquivo = "l:~\sispro~\extra_caixa~\" + "extc" +
                        string(day(vdti),"99") + 
                        "a" +  
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") +
                        string(year(vdtf),"9999") + ".txt".

    output to value(varquivo).
    v-seq = 1000.

    for each tt-cab:
    
    /********************* HEADER ********************/
    cd_batch = "EXTRA" +
               string(day(today),"99") +  
               string(month(today),"99") +    
               string(year(today),"9999") +   
               string(time,"HH:MM").
    
    
    put unformatted 
    /* 01 */       "FISCAL         "
    /* 02 */       " " format "x(01)" 
    /* 03 */       "01001" format "x(20)"
    /* 04 */       " " format "x(01)" 
    /* 05 */       cd_batch   format "x(30)" 
    /* 06 */       " " format "x(01)" 
    /* 07 */       "EXTRA" format "x(15)" 
    /* 08 */       " " format "x(01)" 
    /* 09 */       tt-cab.codlot   format "x(10)" 
    /* 10 */       " " format "x(01)"  
    /* 11 */       "HEADER    " 
    /* 12 */       " " format "x(01)"  
    /* 13 */       tt-cab.qtdlot  format "999999"  
    /* 14 */       " " format "x(01)"  
    /* 15 */       string(day(tt-cab.data),"99") format "99"  
                   string(month(tt-cab.data),"99") format "99"  
                   string(year(tt-cab.data),"9999") format "9999" 
    /* 16 */       " " format "x(01)"  
    /* 17 */       (tt-cab.totval * 100) format "999999999999999999"  
    /* 18 */       " " format "x(01)"  
    /* 19 */       (tt-cab.totval * 100) format "999999999999999999"  
    /* 20 */       " " format "x(01)"  
    /* 21 */       string(day(tt-cab.data),"99") format "99"  
                   string(month(tt-cab.data),"99") format "99"  
                   string(year(tt-cab.data),"9999") format "9999" 
    /* 22 */       " " format "x(01)"  
    /* 23 */       " " format "x(721)"  
    /* 24 */       " " format "x(01)"  
    /* 25 */       "000000"   
    /* 26 */       " " format "x(01)" skip.

    
    for each tt-lanca where tt-lanca.data   = tt-cab.data:

        v-seq = v-seq + 1.
        put unformatted
    /* 01 */       "FISCAL         "
                   " " format "x(01)"
                   "01001" format "x(20)"
                   " " format "x(01)" 
                   cd_batch   format "x(30)" 
                   " " format "x(01)"
                   "EXTRA" format "x(15)"  
                   " " format "x(01)" 
                   tt-cab.codlot   format "x(10)" 
     /* 10 */      " " format "x(01)"
                   "LANCTO    "  
                   " " format "x(01)"
                   string(day(tt-lanca.data),"99") format "99"  
                   string(month(tt-lanca.data),"99") format "99"  
                   string(year(tt-lanca.data),"9999") format "9999" 
                   " " format "x(01)" 
      /* 15 */     tt-lanca.deb format "x(30)" 
      /* 16 */             " " format "x(01)" 
      /* 17 */     tt-lanca.subdeb format "x(22)" 
      /* 18 */     " " format "x(01)" 
      /* 19 */     tt-lanca.cre format "x(30)"
      /* 20 */      " " format "x(01)" 
      /* 21 */      tt-lanca.subcre format "x(22)" 
                   " " format "x(01)" 
                   tt-lanca.etbdeb format "x(20)" 
                   " " format "x(01)"
                   tt-lanca.etbcre   format "x(20)" 
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
     /* 30 */      " " format "x(01)"  
                   " " format "x(06)"  
                   " " format "x(01)"  
                   " " format "x(15)"  
                   " " format "x(01)"  
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)"
     /* 40 */      " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)" 
     /* 50 */      " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)"
     /* 60 */      " " format "x(01)" 
                   " " format "x(15)"   
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)" 
     /* 70 */      " " format "x(01)" 
                   " " format "x(06)" 
                   " " format "x(01)" 
                   " " format "x(15)"  
                   " " format "x(01)" 
                   (tt-lanca.val * 100) format "999999999999999999" 
                   " " format "x(01)" 
                   "0    " format "x(05)" 
                   " " format "x(01)" 
                   tt-lanca.his format "x(119)"
     /* 80 */      " " format "x(01)" 
                   " " format "x(15)" 
                   " " format "x(01)" 
                   " " format "x(120)" 
                   " " format "x(01)" 
                   " " format "x(05)" 
                   " " format "x(01)" 
                   " " format "x(01)"   
                   " " format "x(01)"   
                   "EXC" format "x(03)"  
     /* 90 */      " " format "x(01)"   
                   " " format "x(10)"    
                   " " format "x(01)"   
                   " " format "x(10)"   
                   " " format "x(34)"   
                   " " format "x(01)"   
                   v-seq format "999999"
     /* 97 */      " " format "x(01)"  skip.

    end.
    
/******************** TRAILLER ******************************/
    
    
    put unformatted 
         /* 01 */       "FISCAL         "
         /* 02 */       " " format "x(01)"  
         /* 03 */       "01001" format "x(20)" 
         /* 04 */       " " format "x(01)"  
         /* 05 */       cd_batch   format "x(30)"  
         /* 06 */       " " format "x(01)"  
         /* 07 */       "EXTRA" format "x(15)"  
         /* 08 */       " " format "x(01)"  
         /* 09 */       tt-cab.codlot   format "x(10)"  
         /* 10 */       " " format "x(01)"   
         /* 11 */       "TRAILLER  "  
         /* 12 */       " " format "x(01)"  
         /* 13 */       " " format "x(785)"  
         /* 14 */       "000000" format "x(06)"  
         /* 15 */       " " format "x(01)" skip.

    end.    
    output close.

    /*
    if opsys = "UNIX"
    then do.
        output to ./unixdos.txt.
        unix silent unix2dos value(varquivo). 
        unix silent chmod 777 value(varquivo).
        output close.
        unix silent value("rm ./unixdos.txt -f").
    end.
    */
    
    output to value("./unixdos." + string(time)).
    unix silent value("unix2dos " + varquivo).
    output close.

    message color red/with
        varquivo
        view-as alert-box.
        
end procedure.            
