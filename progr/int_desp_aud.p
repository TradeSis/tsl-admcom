def var varq as char.
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vetb as char.
def var sparam as char.
def var varquivo as char.
def var vesc as char extent 2 format "x(25)".
def var vsc as char format "x(3)".
def var vtitvlpag like titulo.titvlpag.

vesc[1] = "DESPESAS COM ALUGUEL".
vesc[2] = "DESPESAS ENERGIA ELETRICA".
def var vindex as int.

sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
repeat:
    if opsys = "unix" and sparam <> "AniTA"
    then do:
        vindex = vindex + 1.
        if vindex = 3 then leave.
        if vindex = 1 then vsc = "ALG" . else vsc = "LUZ".
        input from /file_server/param_des.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).                       


            if vetbcod = 0
            then do:
            vetb = "".
            varquivo = "/file_server/des_" + vsc + "_" +
                    trim(string(vetb,"x(3)")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".
            end.
            else
            varquivo = "/file_server/des_" + vsc + "_" +
                    trim(string(vetbcod,"999")) + "_" +
                         string(day(vdti),"99") +  
                         string(month(vdti),"99") +  
                         string(year(vdti),"9999") + "_" +  
                         string(day(vdtf),"99") +  
                         string(month(vdtf),"99") +  
                         string(year(vdtf),"9999") + ".txt".


        end.
        input close.
    
    end.
    else do:
    
        update vetbcod with frame f1.
        if vetbcod = 0
        then display "GERAL" @ estab.etbnom with frame f1.
        else do:
            find estab where estab.etbcod = vetbcod no-lock.
            display estab.etbnom no-label with frame f1.
        end.
    
        update vdti label "Data Inicial" colon 15
               vdtf label "Data Final" with frame f1 side-label width 80.

    end.

    if vetbcod = 0
    then vetb = "".
    else vetb = string(vetbcod,"999").
   
    if sparam = "AniTA"
    then do:
    disp vesc no-label with frame f-esc 1 down centered.
    choose field vesc with frame f-esc.
    
    vindex = frame-index.
    
    if vindex = 1 then vsc = "ALG" . else vsc = "LUZ".

    if opsys = "unix"
    then varquivo = "/admcom/decision/des_" + vsc + "_" +
                trim(string(vetb,"x(3)")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
    end.
    /*else do:
        vindex = vindex + 1.
    
        if vindex = 3 then leave.
    end.    
    */

if vindex = 3
then leave.
    
output to value(varquivo).

if vindex = 1
then
for each estab where
            (if vetbcod > 0
             then estab.etbcod = vetbcod else true) no-lock:
    for each titulo where titulo.empcod = 19 and
                      titulo.titnat = yes and
                      titulo.modcod = "ALG" and
                      titulo.etbcod = estab.etbcod and
                      titulo.clifor <> 100090 and
                      titulo.clifor <> 101928 and
                      titulo.titdtpag >= vdti and
                      titulo.titdtpag <= vdtf
                      no-lock.
            
        vtitvlpag = 0.
        find first fatudesp where 
                   fatudesp.clicod = titulo.clifor and
                   fatudesp.fatnum = int(titulo.titnum) 
                   no-lock no-error.
        if avail fatudesp 
        then do:
            
            if fatudesp.modctb <> "ALJ"
            then next.

            for each titudesp where
                     titudesp.clifor = fatudesp.clicod and
                     titudesp.titnum = titulo.titnum and
                     titudesp.titdtemi = titulo.titdtemi and
                     titudesp.titpar = titulo.titpar
                     no-lock.
                
                if titudesp.modcod = "ALG"
                then vtitvlpag = vtitvlpag + titudesp.titvlpag.
                
            end. 
                    
        end.    
        else next.           

        run put-01.
            
    end.
end.
else
for each estab where
            (if vetbcod > 0
             then estab.etbcod = vetbcod else true) no-lock:
    for each titulo where titulo.empcod = 19 and
                      titulo.titnat = yes and
                      titulo.modcod = "LUZ" and
                      titulo.etbcod = estab.etbcod and
                      titulo.titdtpag >= vdti and
                      titulo.titdtpag <= vdtf
                      no-lock.
        
        find first plani where plani.etbcod = titulo.etbcod and
                               plani.movtdc = 37 and
                               plani.numero = int(titulo.titnum) and
                               plani.serie  = "U" and
                               plani.emite  = titulo.clifor 
                               no-lock no-error.
        if not avail plani
        then run put-02.
            
    end.
end.
    
output close.
        
if sparam = "AniTA"
then leave.

end.
         
procedure put-01:

    /* Alterado o valor do titvlcob e titvlpag */

    put unformatted
    /*1-3*/         string(titulo.etbcod,">>9")
    /*4-11*/        string(year(titulo.titdtpag),"9999")
                    string(month(titulo.titdtpag),"99")
                    string(day(titulo.titdtpag),"99")
    /*12-12*/       "0"
    /*13-30*/       "F" + string(titulo.clifor,"9999999999") format "x(18)"
    /*31-50*/       "ALUGUEL" format "x(20)"
    /*51-67*/       vtitvlPAG format "99999999999999.99"
    /*68-69*/       "53"
    /*70-86*/       vtitvlPAG format "99999999999999.99"
    /*87-93*/       string(1.65,"9999.99")
    /*94-110*/      string(vtitvlPAG * (1.65 / 100),"99999999999999.99")
    /*111-112*/     "53"
    /*113-129*/     vtitvlPAG format "99999999999999.99"
    /*130-136*/     string(7.60,"9999.99")
    /*137-153*/     string(vtitvlPAG * (7.60 / 100),"99999999999999.99")
    /*154-155*/     "05"
    /*156-158*/     "101"
    /*159-159*/     "0"
    /*160-187*/     "5.1.01.02.040" format "x(28)"
    /*188-215*/     " " format "x(28)"
    /*216-469*/     "PAGAMENTOS DE ALUGUEL" format "x(254)"
    /*470-484*/     " " format "x(15)"
    /*485-485*/     "9"
    skip.
    
end procedure.  
      
procedure put-02:
        
    put unformatted
    /*1-3*/         string(titulo.etbcod,">>9")
    /*4-11*/        string(year(titulo.titdtpag),"9999")
                    string(month(titulo.titdtpag),"99")
                    string(day(titulo.titdtpag),"99")
    /*12-12*/       "0"
    /*13-30*/       "F" + string(titulo.clifor,"9999999999") format "x(18)"
    /*31-50*/       "ENERGIA ELETRICA" format "x(20)"
    /*51-67*/       titulo.titvlcob format "99999999999999.99"
    /*68-69*/       "53"
    /*70-86*/       titulo.titvlcob format "99999999999999.99"
    /*87-93*/       string(1.65,"9999.99")
    /*94-110*/      string(titulo.titvlcob * (1.65 / 100),"99999999999999.99")
    /*111-112*/     "53"
    /*113-129*/     titulo.titvlcob format "99999999999999.99"
    /*130-136*/     string(7.60,"9999.99")
    /*137-153*/     string(titulo.titvlcob * (7.60 / 100),"99999999999999.99")
    /*154-155*/     "04"
    /*156-158*/     "199"
    /*159-159*/     "0"
    /*160-187*/     "5.1.01.02.045" format "x(28)"
    /*188-215*/     " " format "x(28)"
    /*216-469*/     "PAGAMENTOS DE ENERGIA ELETRICA" format "x(254)"
    /*470-484*/     " " format "x(15)"
    /*485-485*/     "9"
    skip.
    
end procedure.         
