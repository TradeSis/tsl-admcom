{admcab.i}
def var vnome as char format "x(12)".        /* nome do arquivo */
def var vcod as char format "x(10)".         /* codigo spc e associado */
def var vdata as date format "99/99/9999".   /* data movimento */
def var vseq  as int  format "9999999999".   /* sequencial de processamento */
def var vcod-ori as int format "9999999999". /* codigo spc associado origem */
def var vfiller  as char format "x(198)".
def var vseq-tran as int.
def var vestciv as char format "x".
def var vqtdman as int.

repeat:
    
    vdata = today.
    vqtdman = 0.
    vseq    = 1.


    update vdata label "Data Movimento"
           vseq  label "Sequencia" format ">>9" 
                with frame f1 side-label width 80.


    vnome = "drin" + string(day(vdata),"99") 
                   + string(month(vdata),"99") 
                   + "." + "e"
                   + substring(string(vseq,"9999999999"),9,2).

    output to value("l:\spc\" + vnome).
    /********************** REGISTRO HEADER ***********************/

    put "00" 
        vnome
        "RS00100160"
        day(vdata)   format "99"
        month(vdata) format "99"
        year(vdata) format "9999"
        vseq format "9999999999"
        "RS00100160"
        "001"
        vfiller
        "MA"
        "1" skip.


    /*************************  REGISTRO **************************/

    for each regcan no-lock:
        
        find clien where clien.clicod = regcan.clicod no-lock.
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
            vseq-tran format "999999"
            "RS00100160"
            "00000000000000"
            " "
            "0"
            day(clien.dtnas)   format "99"
            month(clien.dtnas) format "99"
            year(clien.dtnas) format "9999"
            clien.clinom format "x(65)"
            "R"
            "1"
            fill(" ",147) format "x(147)" skip.
    
        put "21"
            vseq-tran format "999999"
            clien.mae format "x(40)"
            clien.pai format "x(40)"
            clien.ciins format "x(13)"
            clien.ciccgc format "x(11)"
            vestciv
            fill(" ",67) format "x(67)"
            trim(clien.endereco[1] + " " +
                 string(clien.numero[1]) + " " + 
                 string(clien.compl[1])) format "x(50)" 
            clien.cidade[1] format "x(25)"
            " " skip.
    
        put "22"
            vseq-tran format "999999"
            regcan.contnum format "9999999999999"
            day(regcan.titdtemi)   format "99"
            month(regcan.titdtemi) format "99"
            year(regcan.titdtemi)  format "9999"
            (regcan.vltotal * 100) format "99999999999"
            day(regcan.titdtven)   format "99"
            month(regcan.titdtven) format "99"
            year(regcan.titdtven)  format "9999"
            fill(" ",40) format "x(40)"
            "C"
            fill(" ",105) format "x(105)"
            clien.cep[1]  format "x(08)"
            clien.ufecod[1] format "x(02)"
            fill(" ",30) format "x(30)"
            fill(" ",22) format "x(22)" skip.
    end.
    
    /*************************** REGISTRO TRAILER ***************************/
    put "99"
        vqtdman format "9999999999"
        fill(" ",243) format "x(243)" 
        "0" skip.
end.    

output close.

