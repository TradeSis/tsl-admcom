{admcab.i}   

def var v10 like plani.platot.
def var v15 like plani.platot.
def var v20 like plani.platot.
def var v25 like plani.platot.
def var vmes as char format "x(09)" extent 12.
def var vext1 as char format "x(40)".
def var vext2 as char format "x(40)".
def var vcomis like plani.platot.
def buffer bfree for free.
def var totqtd like free.fresal.
def var totpre like free.fresal.
def var x as i.
def var xx as i.
def var xxx as i.
def var vcre as int.
def var vpag as dec.
def var vetbcod like plani.etbcod.
def var vetbf like plani.etbcod.
def var vdti like plani.pladat initial today.
def var vdtf like plani.pladat initial today.
def var totfil as int.
def var vcheque as int format ">>>>>>9".
def var varquivo as char.
def var vcont as int.
def var vfuncod like func.funcod.
repeat:
    
    vmes[1]  = "Janeiro".
    vmes[2]  = "Fevereiro".
    vmes[3]  = "Marco".
    vmes[4]  = "Abril".
    vmes[5]  = "Maio".
    vmes[6]  = "Junho".
    vmes[7]  = "Julho".
    vmes[8]  = "Agosto".
    vmes[9]  = "Setembro".
    vmes[10] = "Outubro".
    vmes[11] = "Novembro".
    vmes[12] = "Dezembro".


    
    update vetbcod label "Filial"  colon 16
                with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1.
                
    update vfuncod label "Vendedor" colon 16 with frame f1.
    
    find func where func.funcod = vfuncod and
                    func.etbcod = estab.etbcod no-lock no-error.
    if not avail func
    then do:
        message "Funcionario nao Cadastrado".
        undo, retry.
    end.
    display func.funnom no-label with frame f1.
    
    update vcheque label "Cheque" colon 16
           vcomis  label "Premio" colon 16 with frame f1.

    message "Emitir Cheque" update sresp.
    if sresp
    then do:
        /*
        varquivo = "l:\relat\che" + 
                    string(day(vdti)) +
                    string(month(vdti)).
        */            
       
            
   /* Inicia o gerˆnciador de ImpressÆo */   
    varquivo = "..\relat\ra" + string(time).
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""chqavu.p""
        &Nom-Sis   = """SISTEMA NEWFREE"""
        &Tit-Rel   = """PREMIACAO NEW FREE COMPLEMENTACAO"""
        &Width     = "135"
        &Form      = "frame f-cabcab"}
      
        put chr(27) + chr(67) + chr(20).
            
        run extenso.p (input vcomis,
                       input "90",
                       output vext1,
                       output vext2).

        put skip "NUMERO.....  " to 20 vcheque format ">>>>>9"
                 "FILIAL.....  " to 50 estab.etbcod
                 "R$ "           to 100 vcomis format ">>>,>>9.99" skip(1)
                 "Pague por este"           at 10 skip
                 "Cheque a quantia de     " at 10 
                 vext1 
                 "*******************************"
                 skip
                 "***************************************************"
                 at 10
                 "       A  " func.funnom
                 "OU A SUA ORDEM" skip(1)
                 string(estab.munic) format "x(18)" to 80 ","
                 string(day(today),"99") " DE " 
                 vmes[month(today)] " DE "  
                 string(year(today),"9999") skip(3)

                 "____________________________________" to 100 skip
                 "         DREBES E CIA LTDA.         " to 100 skip(2)

                 "_____________________________" to 50 
                 "______________________________" to 90 skip
                 "         Ass.Gerente         " to 50 
                 "        Ass.Funcionario      " to 90 
                     skip(1) fill("-",120) format "x(120)" .
        output close.
    {mrod.i}
    
    end. 

end.
