{admcab.i}
def var vciccgc like clien.ciccgc.

def var ii as int.
def var vano as int format "9999".
def var vnome as char format "x(12)".        /* nome do arquivo */
def var vcod as char format "x(10)".         /* codigo spc e associado */
def var vdti as date format "99/99/9999".   /* data movimento */
def var vdtf as date format "99/99/9999".
def var vseq  as int  format "9999999999".   /* sequencial de processamento */
def var vcod-ori as int format "9999999999". /* codigo spc associado origem */
def var vfiller  as char format "x(198)".
def var vestciv as char format "x".
def var vqtdman as int.
def var vtran as int.
def stream stela.

repeat:
    
    vqtdman = 0.
    vseq    = 1.


    update vdti label "Data Inicial"
           vdtf label "Data Final"
           vtran label "Sequencia" format "99" 
                with frame f1 side-label width 80.
    /*
    message "Deseja Limpar Diretorio" update sresp.
    if sresp
    then dos silent del i:\spc\export\*.*.
    */
    message "Confirma geracao de arquivo" update sresp.
    if not sresp
    then next.
    
    find estab where estab.etbcod = 95.

    vseq = estab.vista + 1.
    

    vnome = "DREX" + string(day(vdti),"99") 
                   + string(month(vdti),"99") 
                   + "." + "E"
                   + substring(string(vtran,"99"),1,2).

    output to value("i:\spc\export\" + vnome).
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

        find clien where clien.clicod = clispc.clicod no-lock no-error.
        if not avail clien
        then next.

        
        vciccgc = "".
        do ii = 1 to 18:
            if substring(ciccgc,ii,1) = "-" or
               substring(ciccgc,ii,1) = " " or
               substring(ciccgc,ii,1) = "*" or
               substring(ciccgc,ii,1) = "." or
               substring(ciccgc,ii,1) = "/" 
            then next.
            else vciccgc = vciccgc + substring(ciccgc,ii,1).
        end.    
        

        
        
        
        vano = year(clien.dtnas).
        if vano > year(today)
        then vano = vano - 100.

        find contrato where contrato.contnum = clispc.contnum no-lock no-error.
        if not avail contrato
        then next.
        vqtdman = vqtdman + 1.
        
        display stream stela 
                clien.clicod
                vqtdman with frame ff side-label centered.
        pause 0.
                

        put "02"
            vqtdman format "999999"
            "RS00175580"
            int(vciccgc) format "99999999999999"
            " "
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
    
    do transaction:
        estab.vista = vseq.
    end.
    
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
    


    
        
end.    


