/*
#1 - helio - 05.2018 - modificado leitura tabela contrato para evitar problemas      com contratos duplos nao usa mais da tabela contrato o etbcod nem o clicod
#2 - Claudir - 20/08/2018 - Correção inclusão indevida no SPC
#3 TP 29104916 - 30.01.2019
#4 - Claudir - Alterado de 30 para 45 dias de atraso para inclusão no SPC
#5 - Claudir - TP 29983229
*/

def var vvltotal as dec. /* #1 */
def buffer xtitulo for titulo.          /* #1 */
def buffer ctitulo for titulo. /* #2 */

{admcab.i}

def var vciins like clien.ciins.
def var vciccgc like clien.ciccgc.
def var vano as int format "9999".
def var vcep like clien.cep[1].
def var ii as int.
def var vendereco as char format "x(50)".
def var vnome as char format "x(12)".        /* nome do arquivo */
def var vcod as char format "x(10)".         /* codigo spc e associado */
def var vdti as date format "99/99/9999".   /* data movimento */
def var vseq  as int  format "9999999999".   /* sequencial de processamento */
def var vcod-ori as int format "9999999999". /* codigo spc associado origem */
def var vfiller  as char format "x(198)".
def var vseq-tran as int.
def var vestciv as char format "x".
def var vqtdman as int.
def var vdtf like titulo.titdtemi.
def var vtran as int.
def stream stela.

FUNCTION f-troca-num returns character
    (input cpo as char).
         
    def var vret as char.  
    
    if cpo = ?
    then cpo = "".
    else do:
         cpo = replace(cpo,"@","").
         cpo = replace(cpo,";","").
         cpo = replace(cpo,".","").
         cpo = replace(cpo,"*","").
         cpo = replace(cpo,"/","").
         cpo = replace(cpo,"-","").
         cpo = replace(cpo,">","").
         cpo = replace(cpo,"<","").
         cpo = replace(cpo,"!","").
         cpo = replace(cpo,"~~","").
         cpo = replace(cpo,"#","").
         cpo = replace(cpo,"$","").
         cpo = replace(cpo,"%","").
         cpo = replace(cpo,"¨","").
         cpo = replace(cpo,"&","").
         cpo = replace(cpo,"[","").
         cpo = replace(cpo,"]","").
         cpo = replace(cpo,"ª","").
         cpo = replace(cpo,"º","").
         cpo = replace(cpo,"ç","").
         cpo = replace(cpo,"ã","").
         cpo = replace(cpo,"õ","").
         cpo = replace(cpo,"ô","").
         cpo = replace(cpo,"â","").
         cpo = replace(cpo,"a","").
         cpo = replace(cpo,"b","").
         cpo = replace(cpo,"c","").
         cpo = replace(cpo,"d","").
         cpo = replace(cpo,"e","").
         cpo = replace(cpo,"f","").
         cpo = replace(cpo,"g","").
         cpo = replace(cpo,"h","").
         cpo = replace(cpo,"i","").
         cpo = replace(cpo,"j","").
         cpo = replace(cpo,"k","").
         cpo = replace(cpo,"l","").
         cpo = replace(cpo,"m","").
         cpo = replace(cpo,"n","").
         cpo = replace(cpo,"o","").
         cpo = replace(cpo,"p","").
         cpo = replace(cpo,"q","").
         cpo = replace(cpo,"r","").
         cpo = replace(cpo,"s","").
         cpo = replace(cpo,"t","").
         cpo = replace(cpo,"u","").
         cpo = replace(cpo,"v","").
         cpo = replace(cpo,"x","").
         cpo = replace(cpo,"y","").
         cpo = replace(cpo,"z","").
    end.
    return cpo. 
end FUNCTION.
 
   
FUNCTION f-troca returns character
    (input cpo as char).
         
    def var vret as char.  
    
    if cpo = ?
    then cpo = "".
    else do:
         cpo = replace(cpo,"@","").
         cpo = replace(cpo,";","").
         cpo = replace(cpo,".","").
         cpo = replace(cpo,"*","").
         cpo = replace(cpo,"/","").
         cpo = replace(cpo,"-","").
         cpo = replace(cpo,">","").
         cpo = replace(cpo,"<","").
         cpo = replace(cpo,"!","").
         cpo = replace(cpo,"~~","").
         cpo = replace(cpo,"#","").
         cpo = replace(cpo,"$","").
         cpo = replace(cpo,"%","").
         cpo = replace(cpo,"¨","").
         cpo = replace(cpo,"&","").
         cpo = replace(cpo,"[","").
         cpo = replace(cpo,"]","").
         cpo = replace(cpo,"ª","").
         cpo = replace(cpo,"º","").
         cpo = replace(cpo,"ç","c").
         cpo = replace(cpo,"ã","a").
         cpo = replace(cpo,"õ","o").
         cpo = replace(cpo,"ô","o").
         cpo = replace(cpo,"â","a").
    end.
    return cpo. 
end FUNCTION.
 
def buffer btitulo for titulo.
def buffer etitulo for titulo.

def var vdata-neg as date.
repeat:
    
    vqtdman = 0.
    vtran  = 0.

    for each regcan:
        do transaction:
            delete regcan.
        end.
    end.
    
    update vdti label "Data Inicial"
           vdtf label "Data Final"
           vtran label "Sequencia" format "99" 
                with frame f1 side-label width 80.
                
   if vdti = ? or vdtf = ?
   or vdti > vdtf
   then do:
        message "Data invalida! Favor informar corretamente.". pause.
        next.
   end.        
                
    message "Confirma geracao de arquivo" update sresp.
    if not sresp then next.


    find estab where estab.etbcod = 995 no-lock no-error.
    vseq = estab.vista + 1.
    
    vnome = "DRIN" + string(day(vdti),"99") 
                   + string(month(vdti),"99") 
                   + "." + "E"
                  + substring(string(vtran,"99"),1,2).

    output to value("i:~\spc~\export~\" + vnome). 
    
    /*
    output to value("i:" + ""\"" + "spc" + ""\"" + "export" + ""\"" + vnome).
    */
    
    /********************** REGISTRO HEADER ***********************/
      
    put "00" 
        vnome
        "RS00175580"
        day(vdti)   format "99"
        month(vdti) format "99"
        year(vdti) format "9999"
        vseq format "9999999999"
        "RS00175580"
        "002"
        vfiller
        "MA"
        "1" skip.


    output stream stela to terminal.
    for each clispc where clispc.dtneg >= vdti and
                          clispc.dtneg <= vdtf no-lock:
        
        display stream stela clispc.clicod with frame ff side-label
                                        centered.
        pause 0.

        if dtcanc <> ?
        then next.

        find clien where clien.clicod = clispc.clicod no-lock no-error.
        if not avail clien
        then next.
        /**
        if  year(today) - year(dtnasc) < 18 or 
            (year(today) - year(dtnasc) = 18 and
            (month(today) < month(dtnasc) or
            (month(today) = month(dtnasc) and 
            day(today) < day(dtnasc)))) 
        then next.
        **/

        find first xtitulo use-index iclicod
                    where 
            xtitulo.clifor = clispc.clicod and
            xtitulo.titnat = no and
            xtitulo.titnum = string(clispc.contnum)
            no-lock no-error.
        if not avail xtitulo
        then next.
        
        find first titulo use-index titnum
                      where titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.modcod = xtitulo.modcod and
                            titulo.etbcod = xtitulo.etbcod and
                            titulo.clifor = clien.clicod and
                            titulo.titnum = string(clispc.contnum) and
                            titulo.titdtven > (vdti - 45 /*#4 30*/) and
                            titulo.titsit = "PAG" no-lock no-error.

        if avail titulo
        then next.

        find first btitulo where
                   btitulo.empcod = 19 and
                   btitulo.titnat = no and
                   btitulo.modcod = xtitulo.modcod and
                   btitulo.etbcod = xtitulo.etbcod and
                   btitulo.titdtven <= clispc.dtneg  - 45 /*#4 30*/  and
                   btitulo.clifor = clispc.clicod and
                   btitulo.titsit = "LIB"
                   no-lock no-error.
                                                            
            vvltotal = 0.            
            /* #1
            for each btitulo where 
                    btitulo.empcod = 19 and 
                    btitulo.titnat = no and 
                    btitulo.modcod = xtitulo.modcod and  /* #1 */
                    btitulo.etbcod = xtitulo.etbcod and 
                    btitulo.clifor = clien.clicod and 
                    btitulo.titnum = string(clispc.contnum)
                    no-lock.
                vvltotal = vvltotal + btitulo.titvlcob.
            end.
            */

            /* #2 */
        for each ctitulo where 
                    ctitulo.empcod = 19 and 
                    ctitulo.titnat = no and 
                    ctitulo.modcod = xtitulo.modcod and  
                    ctitulo.etbcod = xtitulo.etbcod and 
                    ctitulo.clifor = clien.clicod and 
                    ctitulo.titnum = string(clispc.contnum)
                    no-lock.
                vvltotal = vvltotal + ctitulo.titvlcob.
        end.
        /*#5*/
        if avail btitulo
        then vdata-neg = btitulo.titdtven.
        else vdata-neg = clispc.dtneg - 45.
        
        if today - vdata-neg < 1800
        then /*#5*/
        do transaction:
            create regcan. 
            assign regcan.etbcod   = estab.etbcod
                   regcan.clicod   = clien.clicod
                   regcan.clinom   = clien.clinom
                   regcan.munic    = estab.munic
                   regcan.contnum  = clispc.contnum
                   regcan.vltotal  = vvltotal
                   regcan.titdtemi = xtitulo.titdtemi
                   regcan.titdtven = if avail btitulo
                                     then btitulo.titdtven
                                     else clispc.dtneg - 45 /*#4 30*/.
        end.
 
     end.
     output stream stela close.

    /*************************  REGISTRO **************************/

    for each regcan no-lock:
        
        find clien where clien.clicod = regcan.clicod no-lock.
        
        if  year(today) - year(dtnasc) < 18 or 
            (year(today) - year(dtnasc) = 18 and
            (month(today) < month(dtnasc) or
            (month(today) = month(dtnasc) and 
            day(today) < day(dtnasc)))) 
        then next.
 
        vano = year(clien.dtnasc).
        if vano > year(today)
        then vano = vano - 100.
        
        vciccgc = "".
        do ii = 1 to 18:
            if substring(ciccgc,ii,1) = "-" or
               substring(ciccgc,ii,1) = " " or
               substring(ciccgc,ii,1) = "+" or
               substring(ciccgc,ii,1) = "*" or
               substring(ciccgc,ii,1) = "." or
               substring(ciccgc,ii,1) = "/" or
               substring(ciccgc,ii,1) = "a" or
               substring(ciccgc,ii,1) = "b" or
               substring(ciccgc,ii,1) = "c" or
               substring(ciccgc,ii,1) = "d" or 
               substring(ciccgc,ii,1) = "e" or 
               substring(ciccgc,ii,1) = "f" or 
               substring(ciccgc,ii,1) = "g" or 
               substring(ciccgc,ii,1) = "h" or 
               substring(ciccgc,ii,1) = "i" or 
               substring(ciccgc,ii,1) = "j" or 
               substring(ciccgc,ii,1) = "k" or 
               substring(ciccgc,ii,1) = "l" or 
               substring(ciccgc,ii,1) = "m" or 
               substring(ciccgc,ii,1) = "n" or 
               substring(ciccgc,ii,1) = "o" or 
               substring(ciccgc,ii,1) = "p" or 
               substring(ciccgc,ii,1) = "q" or 
               substring(ciccgc,ii,1) = "r" or 
               substring(ciccgc,ii,1) = "s" or 
               substring(ciccgc,ii,1) = "t" or 
               substring(ciccgc,ii,1) = "u" or 
               substring(ciccgc,ii,1) = "v" or 
               substring(ciccgc,ii,1) = "x" or 
               substring(ciccgc,ii,1) = "z" 
            then next.
            else vciccgc = vciccgc + substring(ciccgc,ii,1).
        end.    

        run Pi-cic-number(input-output vciccgc).

        if length(vciccgc) > 11
        then vciccgc = substring(vciccgc,1,11).
        
        
        vciins = "".
        do ii = 1 to 25: 
            if substring(ciins,ii,1) = "-" or
               substring(ciins,ii,1) = " " or
               substring(ciins,ii,1) = "*" or
               substring(ciins,ii,1) = "." or
               substring(ciins,ii,1) = "/" or
               substring(ciins,ii,1) = "a" or
               substring(ciins,ii,1) = "b" or
               substring(ciins,ii,1) = "c" or
               substring(ciins,ii,1) = "d" or 
               substring(ciins,ii,1) = "e" or 
               substring(ciins,ii,1) = "f" or 
               substring(ciins,ii,1) = "g" or 
               substring(ciins,ii,1) = "h" or 
               substring(ciins,ii,1) = "i" or 
               substring(ciins,ii,1) = "j" or 
               substring(ciins,ii,1) = "k" or 
               substring(ciins,ii,1) = "l" or 
               substring(ciins,ii,1) = "m" or 
               substring(ciins,ii,1) = "n" or 
               substring(ciins,ii,1) = "o" or 
               substring(ciins,ii,1) = "p" or 
               substring(ciins,ii,1) = "q" or 
               substring(ciins,ii,1) = "r" or 
               substring(ciins,ii,1) = "s" or 
               substring(ciins,ii,1) = "t" or 
               substring(ciins,ii,1) = "u" or 
               substring(ciins,ii,1) = "v" or 
               substring(ciins,ii,1) = "x" or 
               substring(ciins,ii,1) = "z" 
            then next.
            else vciins = vciins + substring(ciins,ii,1).
        end.    

        run Pi-cic-number(input-output vciins).
        
        vcep = "".

        vcep = replace(clien.cep[1]," ", "") .
        if vcep = ""  or vcep = ?
        then vcep = "96700000".
        else do:
    
             if length(cep[1]) <= 8
             then do:
                 do ii = 1 to 8:
                    if substring(string(cep[1]),ii,1) = "-" or
                       substring(string(cep[1]),ii,1) = " " or
                       substring(string(cep[1]),ii,1) = "*" or
                       substring(string(cep[1]),ii,1) = "," or
                       substring(string(cep[1]),ii,1) = "." or
                       substring(string(cep[1]),ii,1) = "/" 
                    then vcep = vcep + "0".
                    else vcep = vcep + substring(cep[1],ii,1).
                 end.
             end.    

            if length(cep[1]) >= 09
            then do:
                do ii = 1 to 10:
                    if substring(string(cep[1]),ii,1) = "-" or
                       substring(string(cep[1]),ii,1) = " " or
                       substring(string(cep[1]),ii,1) = "*" or
                       substring(string(cep[1]),ii,1) = "," or
                       substring(string(cep[1]),ii,1) = "." or
                       substring(string(cep[1]),ii,1) = "/" 
                    then.
                    else vcep = vcep + substring(cep[1],ii,1).
                end.
            end.    
            
                
        end.
 
        vendereco = clien.endereco[1] + " ".
        if clien.numero[1] <> ?
        then vendereco = vendereco + string(clien.numero[1]) + " ".
        if clien.compl[1] <> ?
        then vendereco = vendereco + string(clien.compl[1]).

        
        vestciv = "S".

        if clien.estciv = 1
        then vestciv = "S".
            
        if clien.estciv = 2
        then vestciv = "C".

        if clien.estciv = 3
        then vestciv = "V".

        if clien.estciv = 4
        then vestciv = "D".

        vqtdman = vqtdman + 1.    
        
        put "02"
            int(f-troca-num(string(vqtdman))) format "999999"
            "RS00175580"
            dec(f-troca-num(string(vciccgc))) format "99999999999999"
            "0"
            "0"
            day(clien.dtnas)   format "99"
            month(clien.dtnas) format "99"
            vano               format "9999"
            f-troca(clien.clinom) format "x(65)"
            "R"
            "1"
            fill(" ",147) format "x(147)" skip.
    
        put "21"
            int(f-troca-num(string(vqtdman))) format "999999" 
            f-troca(clien.mae) format "x(40)" 
            f-troca(clien.pai) format "x(40)" 
            f-troca-num(vciins) format "x(13)"    
            dec(f-troca-num(string(vciccgc))) format "99999999999" 
            vestciv
            fill(" ",67) format "x(67)"
            f-troca(vendereco) format "x(50)" 
            f-troca(clien.cidade[1]) format "x(25)"
            " " skip.
    
        put "22"
            vqtdman format "999999" 
            int(f-troca-num(string(regcan.contnum))) format "9999999999999" 
            (if regcan.titdtemi = ?
            then vdti
            else regcan.titdtemi) format "99999999"
            (regcan.vltotal * 100) format "99999999999" 
            (if regcan.titdtven = ?
            then (vdti - 60)
            else regcan.titdtven) format "99999999"
            fill(" ",40) format "x(40)"
            "C"
            fill(" ",105) format "x(105)"
            f-troca-num(vcep)  format "x(08)"
            f-troca(clien.ufecod[1]) format "x(02)"
            fill(" ",30) format "x(30)"
            fill(" ",22) format "x(22)" skip.
    end.
    
    /*************************** REGISTRO TRAILER ***************************/
    put "99"
        vqtdman format "9999999999"
        fill(" ",243) format "x(243)" 
        "0" skip.
    output close. /* #3 */

    /* #3 uma transacao só */
    do transaction:
        find estab where estab.etbcod = 995.
        estab.vista = vseq.
        find estab where estab.etbcod = 995 no-lock.
    
        find logspc where logspc.lognome = vnome NO-LOCK no-error.
        if not avail logspc
        then do:
            create logspc.
            assign logspc.lognome = vnome
                   logspc.dtini   = vdti
                   logspc.dtfin   = vdtf
                   logspc.dtenv   = today
                   logspc.logseq  = vseq
                   logspc.logtip  = yes.
        end.
    end.
    
    output to i:\spc\inclusao.log append.
        put vdti " "
            vdtf " "
            vnome " "
            today format "99/99/9999" skip.
    output close.
end.    

Procedure Pi-cic-number.
    def input-output  parameter p-ciccgc  like clien.ciccgc.
    def var v-ciccgc like clien.ciccgc.
    def var jj          as int.
    def var ii          as int.
    def var v-carac     as char format "x(1)".

    assign v-ciccgc = "".
    do ii = 1 to length(p-ciccgc):
        assign v-carac = string(substr(p-ciccgc,ii,1)).
        do jj = 1 to 10:
            if string(jj - 1) = v-carac
            then assign v-ciccgc = v-ciccgc + v-carac.
        end.
   end.
   assign p-ciccgc = v-ciccgc.
end procedure.
   
