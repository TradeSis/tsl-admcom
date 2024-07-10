{admcab.i}
def var vlog as log format "Totais/Geral" initial yes.
def var vnum as int.
def var varquivo as char format "x(20)".
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vdata like plani.pladat.
def var vdt   like plani.pladat.
def var vmov  as char.

def var vdeb  like movcre.titvlcob.
def var vcre  like movcre.titvlcob.

def var totdeb  like movcre.titvlcob.
def var totcre  like movcre.titvlcob.
def var totsal  like movcre.titvlcob.

def stream stela.
form vmov column-label "Movimento" format "x(15)"
     vdt  column-label "Data Mov." 
     movcre.titnum 
     movcre.clifor column-label "Codigo" 
     forne.fornom   
     vdeb          column-label "Debito"
     vcre          column-label "Credito"
     totsal        column-label "Saldo"
                        with frame f2 down width 200.


repeat:
    
    update vdti colon 16 label "Data Inicial"
           vdtf colon 16 label "Data Final"
           vnum colon 16 label "Pagina" format ">9"
           vlog colon 16 label "Listagem" 
            with frame f1 side-label width 80.

    vnum = vnum - 1.
    find salcre where salcre.salano = year(vdti) and
                      salcre.salmes = month(vdti) no-lock no-error.
    if not avail salcre
    then do:
        message "Periodo sem saldo".
        undo, retry.
    end.
    totsal =  salcre.salini.
    
    varquivo = "i:\admcom\relat\cre" + STRING(day(vdti)). 

    {mdadmctb.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""movcre_3""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """ DIARIO AUXILIAR DE CREDORES PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" A "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "160"
            &Form      = "frame f-cabcab"}
    

       
    output stream stela to terminal.
    do vdata = vdti to vdtf:
        totcre = 0.
        totdeb = 0.
        for each movcre where movcre.titdtpag = vdata:
            if movcre.titman = "EXCLUIDO"
            then next.
            vmov = "PAGAMENTO".
            vdt  = titdtpag.
            vcre = 0.
            vdeb = movcre.titvlcob.
            totdeb = totdeb + movcre.titvlcob.
            totsal = totsal - movcre.titvlcob.
            find forne where forne.forcod = movcre.clifor no-lock no-error.
            if vlog = no
            then do:
                display vmov 
                        vdt
                        movcre.titnum
                        movcre.clifor 
                        forne.fornom when avail forne
                        vdeb
                        vcre 
                        totsal with frame f2.
                down with frame f2.
            end.
            display stream stela 
                    movcre.titdtemi with 1 down side-label. pause 0.

        end.
        
        for each movcre where movcre.titdtemi = vdata and
                              movcre.titsit   = "LIB" no-lock:

            if movcre.titman = "EXCLUIDO"
            then next.

            vmov = "COMPRA".
            vdt  = titdtemi.
            vdeb = 0.
            vcre = titvlcob.
            totcre = totcre + titvlcob.
            totsal = totsal + movcre.titvlcob.
            find forne where forne.forcod = movcre.clifor no-lock no-error.
            if vlog = no
            then do:
                display vmov 
                        vdt
                        movcre.titnum
                        movcre.clifor 
                        forne.fornom  when avail forne
                        vdeb
                        vcre 
                        totsal with frame f2.
                down with frame f2.
            end.
            display stream stela movcre.titdtemi 
                with 1 down side-label. pause 0.
        end.

 
        if totdeb <> 0 or
           totcre <> 0
        then do:
            put skip fill("-",160) format "x(160)" skip
                "TOTAL ATE O DIA  " vdata  " ................................"
                totdeb to 101
                totcre to 116 
                totsal to 131 skip fill("-",160) format "x(160)".
            totcre = 0.
            totdeb = 0.
        end.
    end.
    output stream stela close.
    
    output close.
    
    message "Deseja Imprimir relatorio" update sresp.
    if sresp
    then dos silent value("type " + varquivo + " > prn").  
    
end.



            
    
