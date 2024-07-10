{admcab.i}

def var vciccgc like clien.ciccgc.

def var ii as int.
def var vano as int format "9999".
def var vnome      as char format "x(12)".        /* nome do arquivo */
def var vcod as char format "x(10)".         /* codigo spc e associado */
def var vdti as date format "99/99/9999".   /* data movimento */
def var vdtf as date format "99/99/9999".
def var vseq  as int  format "9999999999".   /* sequencial de processamento */
def var vcod-ori as int format "9999999999". /* codigo spc associado origem */
def var vfiller  as char format "x(198)".
def var vestciv as char format "x".
def var vqtdman as int.
def var vtran as int.
def var vnro-aux as char.
def stream stela.

def buffer etitulo for titulo.

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


repeat:
    
    vqtdman = 0.
    vseq    = 1.


    update vdti label "Data Inicial"
           vdtf label "Data Final"
           vtran label "Sequencia" format "99" 
                with frame f1 side-label width 80.


    message "Confirma geracao de arquivo" update sresp.
    if not sresp
    then next.
    
    find estab where estab.etbcod = 995 no-lock no-error.

    vseq = estab.vista + 1.
    

    vnome = "DREX" + string(day(vdti),"99") 
                   + string(month(vdti),"99") 
                   + "." + "E"
                   + substring(string(vtran,"99"),1,2).
    
    output to value(trim("i:\spc\export\ ") + vnome). 
      
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


    /*************************  REGISTRO **************************/
    output stream stela to terminal.
    for each clispc where clispc.dtcanc >= vdti and
                          clispc.dtcanc <= vdtf no-lock:
        
        if clispc.clicod = 0 or
           clispc.clicod = 1
        then next.

        find clien where clien.clicod = clispc.clicod no-lock no-error.
        if not avail clien
        then next.
        
        vciccgc = "".
        do ii = 1 to 18:
            if substring(ciccgc,ii,1) = "-" or
               substring(ciccgc,ii,1) = " " or
               substring(ciccgc,ii,1) = "*" or
               substring(ciccgc,ii,1) = "+" or
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

        /*Elimina qualquer caracter diferente de numeros*/
        do ii = 1 to length(vciccgc):
        
            assign vnro-aux = substring(vciccgc,ii,1).
        
            if vnro-aux <> "0"
                and vnro-aux <> "1"
                and vnro-aux <> "2"
                and vnro-aux <> "3"
                and vnro-aux <> "4"
                and vnro-aux <> "5"
                and vnro-aux <> "6"
                and vnro-aux <> "7"
                and vnro-aux <> "8"
                and vnro-aux <> "9"
                and vnro-aux <> "0"
            then assign vciccgc = replace(vciccgc,vnro-aux,"").    
                
        end.
        
        if length(vciccgc) > 11 or
           length(vciccgc) < 11
        then vciccgc = substring(vciccgc,1,11).
        if vciccgc = "" 
        then vciccgc = "00000000000".
        
        vano = year(clien.dtnas).
        if vano > year(today)
        then vano = vano - 100.

        find contrato where contrato.contnum = clispc.contnum no-lock no-error.
        if not avail contrato
        then next.

        /*** Financeira 
        
        if clispc.dtneg > 09/28/2011
        then do:
        find first envfinan where envfinan.empcod = 19
                        and envfinan.titnat = no
                        and envfinan.modcod = contrato.modcod
                        and envfinan.etbcod = contrato.etbcod
                        and envfinan.clifor = contrato.clicod
                        and envfinan.titnum = string(contrato.contnum)
                        no-lock no-error.
        if not avail envfinan
        then.
        else do:
            find first etitulo use-index titnum
                      where etitulo.empcod = envfinan.empcod and
                            etitulo.titnat = envfinan.titnat and
                            etitulo.modcod = envfinan.modcod and
                            etitulo.etbcod = envfinan.etbcod and
                            etitulo.clifor = envfinan.clifor and
                            etitulo.titnum = envfinan.titnum and
                            etitulo.titpar = envfinan.titpar
                            no-lock no-error.

            if avail etitulo and etitulo.cobcod = 10
            then next.
        end.
        end.
        
        ***/

        vqtdman = vqtdman + 1.
        
        display stream stela 
                clien.clicod
                vqtdman with frame ff side-label centered.
        pause 0.
                

        put "02"
            vqtdman format "999999"
            "RS00175580"
            dec(f-troca(string(vciccgc))) format "99999999999999"
            "0"
            "0"
            day(clien.dtnas)   format "99"
            month(clien.dtnas) format "99"
            vano format "9999"
            clien.clinom format "x(65)"
            "R"
            "3"
            fill(" ",147) format "x(147)" skip.
    
        put "24"
            vqtdman format "999999"
            clien.mae format "x(40)"
            contrato.contnum format "9999999999999"
            fill(" ",195) format "x(195)" skip.
    end.
    output stream stela close.
    /*************************** REGISTRO TRAILER ***************************/
    
    put "99"
        vqtdman format "9999999999"
        fill(" ",243) format "x(243)" 
        "0" skip.
    
    find estab where estab.etbcod = 995.
    do transaction:
        estab.vista = vseq.
    end.
    find estab where estab.etbcod = 995 no-lock no-error.
    
    output close.
    
    output to i:\spc\exclusao.log append.
        put vdti " "
            vdtf " "
            vnome " "
            today format "99/99/9999" skip.
    output close.
    
    find logspc where logspc.lognome = vnome no-error.
    if not avail logspc
    then do transaction:
        create logspc.
        assign logspc.lognome = vnome
               logspc.dtini   = vdti
               logspc.dtfin   = vdtf
               logspc.dtenv   = today
               logspc.logseq  = vseq
               logspc.logtip  = no.
    end.
    leave.    
end.    

