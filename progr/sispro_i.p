{admcab.i}
   
def temp-table tt-icms
        field etbcod like estab.etbcod
        field icms-ven as dec
        field icms-com as dec
        index i1 etbcod.
        
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
 
form vetbcod like estab.etbcod   at 1  LABEL "Filial"
     estab.etbnom                           no-label
     vdti as date label "Data Inicial" at 1
     vdtf as date label "Data Final"
     with frame f1 1 down width 80 side-label.
      
do on error undo, return with frame f1:
    update vetbcod.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom.
    end.
    update vdti vdtf.
    if vdti > vdtf
    then undo.
end.    

def var varquivo as char.

if opsys = "UNIX"
then varquivo = "/admcom/sispro/arquivos/"  + "gicms" +
                         string(day(vdti),"99") + 
                         "a" + 
                         string(day(vdtf),"99")  + 
                         string(month(vdtf),"99") + 
                         string(year(vdtf),"9999") + ".txt".
else varquivo = "l:~\sispro~\arquivos~\" + "gicms" +
                        string(day(vdti),"99") + 
                        "a" +  
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") +
                        string(year(vdtf),"9999") + ".txt".

if search(varquivo) <> ?
then do:
    input from value(varquivo).
    repeat:
        create tt-icms.
        import tt-icms.
    end.
    input close.
    for each tt-icms where tt-icms.etbcod = 0:
        delete tt-icms.
    end.    
end.
else do:
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock:
        find first tt-icms where tt-icms.etbcod = estab.etbcod no-error.
        if not avail tt-icms
        then do:
            create tt-icms.
            tt-icms.etbcod = estab.etbcod.
        end.                 
        for each mapctb where mapctb.etbcod = estab.etbcod and
                          mapctb.datmov >= vdti        and
                          mapctb.datmov <= vdtf        and
                          mapctb.ch2 <> "E" no-lock
                                    break by mapctb.etbcod:

            tt-icms.icms-ven = tt-icms.icms-ven 
                    + ((mapctb.t02 * 0.705889) * 0.17)
                    + (mapctb.t01 * 0.17)
                    + (mapctb.t03 * 0.07).
 
        end.
        for each fiscal where fiscal.desti = estab.etbcod   and
                          fiscal.plarec >= vdti and
                          fiscal.plarec <= vdtf no-lock:
                          
            tt-icms.icms-com = tt-icms.icms-com +
                fiscal.icms.
        end.
    end.
end.
form tt-icms.etbcod no-label
     estab.etbnom column-label "Filial"
     tt-icms.icms-ven column-label "ICMS Vendas"  format ">>,>>>,>>9.99"
     tt-icms.icms-com column-label "ICMS Compras" format ">>,>>>,>>9.99"
     with frame f-linha 10 down.
     
def var vtotal-ic as dec format ">>,>>>,>>9.99".
def var vtotal-iv as dec format ">>,>>>,>>9.99".
{setbrw.i}
l1: repeat:
for each tt-icms where if vetbcod > 0 
            then tt-icms.etbcod = vetbcod else true:
    assign
        vtotal-iv = vtotal-iv + tt-icms.icms-ven
        vtotal-ic = vtotal-ic + tt-icms.icms-com.
end.
disp vtotal-iv
     vtotal-ic
     with frame f-total 
     1 down no-box row 21 no-label column 33.
     
     pause 0.
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?.
    
{sklcls.i
    &help = "ENTER=Altera F1=Exporta F4=Retorna F8=Grava F9=Inc F10=Exclui" 
    &file = tt-icms
    &cfield = tt-icms.etbcod
    &noncharacter = /*
    &ofield = " estab.etbnom
                tt-icms.icms-ven
                tt-icms.icms-com
              "
    &aftfnd1 = "
        find estab where estab.etbcod = tt-icms.etbcod no-lock.
         "
    &where = " if vetbcod <> 0
               then tt-icms.etbcod = vetbcod else    true
            USE-INDEX I1
             "
    &aftselect1 = "
        if keyfunction(lastkey) = ""return""
        then do:
            assign
                vtotal-iv = vtotal-iv - tt-icms.icms-ven
                vtotal-ic = vtotal-ic - tt-icms.icms-com.
            repeat on endkey undo, retry: 
                update tt-icms.icms-ven
                       tt-icms.icms-com
                   with frame f-linha.
                leave.
            end.
            assign
                vtotal-iv = vtotal-iv + tt-icms.icms-ven
                vtotal-ic = vtotal-ic + tt-icms.icms-com.
            disp vtotal-iv vtotal-ic with frame f-total 
                .
                pause 0.
            next keys-loop.
        end.    "
    &abrelinha1 =
        " scroll from-current down with frame f-linha.
          create tt-icms.
          update tt-icms.etbcod
                 tt-icms.icms-ven
                 tt-icms.icms-com
                 with frame f-linha.
                 assign
                vtotal-iv = vtotal-iv + tt-icms.icms-ven
                vtotal-ic = vtotal-ic + tt-icms.icms-com.
            disp vtotal-iv vtotal-ic with frame f-total 
                .   pause 0.     next l1.
                         "
    &otherkeys1 = "
        if keyfunction(lastkey) = ""GO""    or
           keyfunction(lastkey) = ""CLEAR"" or
           keyfunction(lastkey) = ""delete-line""
        then leave keys-loop.
         "
    &form = " frame f-linha down "
}                 
    if keyfunction(lastkey) = "end-error"
    then leave l1.

    find first tt-icms no-lock.
    
    if keyfunction(lastkey) = "CLEAR"
    then do:
        sresp = yes.
        message "Confirma Gravar dados?"
        update sresp.
        if not sresp then next l1.
            
        if opsys = "UNIX"
        then varquivo = "/admcom/sispro/arquivos/"  + "gicms" +
                         string(day(vdti),"99") + 
                         "a" + 
                         string(day(vdtf),"99")  + 
                         string(month(vdtf),"99") + 
                         string(year(vdtf),"9999") + ".txt".
        else varquivo = "l:~\sispro~\arquivos~\" + "gicms" +
                        string(day(vdti),"99") + 
                        "a" +  
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") +
                        string(year(vdtf),"9999") + ".txt".

        output to value(varquivo).
        for each tt-icms:
            export tt-icms.
        end.
        output close.
 
    end.
    if keyfunction(lastkey) = "delete-line"
    then do:
        sresp = no.
        message "Confirma Excluir dados?"
        update sresp.
        if sresp
        then do:
            if opsys = "UNIX"
            then varquivo = "/admcom/sispro/arquivos/"  + "gicms" +
                         string(day(vdti),"99") + 
                         "a" + 
                         string(day(vdtf),"99")  + 
                         string(month(vdtf),"99") + 
                         string(year(vdtf),"9999") + ".txt".
            else varquivo = "l:~\sispro~\arquivos~\" + "gicms" +
                        string(day(vdti),"99") + 
                        "a" +  
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") +
                        string(year(vdtf),"9999") + ".txt".

            for each tt-icms where if vetbcod > 0
                                then tt-icms.etbcod = vetbcod else true:
                delete tt-icms.
            end.    
            output to value(varquivo).
            for each tt-icms:
                export tt-icms.
            end.
            output close.
            if vetbcod = 0
            then do:
                if opsys = "UNIX"
                then do:
                    unix silent rm value(varquivo).
                end.
                else do:
                    dos silent rm value(varquivo).
                end.
            end.
            leave l1.
 
        end.
    end.
    if keyfunction(lastkey) = "GO"
    then do:
        bell.
        sresp = no.
        message color red/with
        "Confirma Exportar Dados? "
        view-as alert-box buttons yes-no update sresp.
        if not sresp then return.
        
        for each tt-lanca: delete tt-lanca. end.
        for each tt-cab: delete tt-cab. end.
        
        find first tt-cab where tt-cab.data = vdtf no-error.
        if not avail tt-cab
        then do:
            create tt-cab.
            assign tt-cab.data   = vdtf
                   tt-cab.codlot = "11" + string(day(vdtf),"99").

        end.

        for each tt-icms:
            if tt-icms.icms-com > 0
            then do:
            find hispad where hispad.hiscod = 48 no-lock.
            create tt-lanca. 
            assign tt-lanca.etbcod  = 01001
                   tt-lanca.etbcre  = 
                            "01" +  string(tt-icms.etbcod,"999")
                   tt-lanca.etbdeb  = "01001"
                   tt-lanca.data    = vdtf
                   tt-lanca.cre     = "169"  
                   tt-lanca.deb     = "32"
                   tt-lanca.cod     = 0   
                   tt-lanca.val     = tt-icms.icms-com
                   tt-lanca.his     = "*LIVRE@" + hispad.hisdes
                   tt-cab.qtdlot = tt-cab.qtdlot + 1
                   tt-cab.totval = tt-cab.totval + tt-icms.icms-com
                   .
            end.
            if tt-icms.icms-ven > 0
            then do:
            find hispad where hispad.hiscod = 49 no-lock.
            create tt-lanca. 
            assign tt-lanca.etbcod  = 01001
                   tt-lanca.etbdeb  = 
                            "01" +  string(tt-icms.etbcod,"999")
                   tt-lanca.etbcre  = "01001"
                   tt-lanca.data    = vdtf
                   tt-lanca.cre     = "96"  
                   tt-lanca.deb     = "164"
                   tt-lanca.cod     = 0   
                   tt-lanca.val     = tt-icms.icms-ven
                   tt-lanca.his     = "*LIVRE@" + hispad.hisdes
                   tt-cab.qtdlot = tt-cab.qtdlot + 1
                   tt-cab.totval = tt-cab.totval + tt-icms.icms-ven
                   .
            end.
        end.
        run exporta-sispro.
    end.
end.


procedure exporta-sispro:
    def var v-seq as int.
    def var cd_batch as char.
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/sispro/arquivos/"  + "icms" +
                         string(day(vdti),"99") + 
                         "a" + 
                         string(day(vdtf),"99")  + 
                         string(month(vdtf),"99") + 
                         string(year(vdtf),"9999") + ".txt".
    else varquivo = "l:~\sispro~\arquivos~\" + "icms" +
                        string(day(vdti),"99") + 
                        "a" +  
                        string(day(vdtf),"99") + 
                        string(month(vdtf),"99") +
                        string(year(vdtf),"9999") + ".txt".

    output to value(varquivo).
    v-seq = 1000.

    for each tt-cab:
    
    /********************* HEADER ********************/
    cd_batch = "ICMS" +
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
    /* 07 */       "ICMS" format "x(15)" 
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
                   "ICMS" format "x(15)"  
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
         /* 07 */       "ICMS" format "x(15)"  
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

    message color red/with
        varquivo
        view-as alert-box.
        
end procedure.            
