/* 14042022 helio - 214140 . EXPORTAÇÃO DE RELATÓRIOS RETROATIVO */

{admcab.i}

def var vperpagamento as log format "Sim/Nao".
def var vdtpagref as date format "99/99/9999".
def var vheader as char.

def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial no.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def stream stela.
def var vdata like plani.pladat.
def var totval like plani.platot.
def var totjur like plani.platot.
def var varquivo as char.

def temp-table ttx
    field chesit as char.

repeat with frame f-dep:
    
    empty temp-table ttx.
    
    update vsit    label "Situacao" colon 25
           vdti  label "Data Inicial" colon 25
           vdtf  label "Data Final  "
           skip(2)
                with frame f-dep centered side-label color blue/cyan row 4.

   update  vperpagamento label "Retroativo por Pagamento" colon 25 .
   vdtpagref = ?.
   disp vdtpagref.
   
        if vperpagamento
        then do on error undo:
            update vdtpagref label "Periodo de  Pagamento"
            skip(1).
            if vdtpagref = ? 
            then undo.
        end.

    /*    disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
        pause.

        if opsys = "UNIX"
        then varquivo = "/admcom/relat/cel8" + string(time).
        else varquivo = "l:~\relat~\cel8" + string(time).
      */
        if opsys = "UNIX"
        then varquivo = "../relat/cel8_" + string(today,"99999999") + replace(string(time,"HH:MM:SS"),":","") +
                        "_" + string(vdtf,"99999999") + ".txt".
        else varquivo = "l:~\relat~\cel8" + string(time).

    
    /*
    64
    66
    */
    vheader = " PERIODO: "  + string(vdti,"99/99/9999") + " A " + string(vdti,"99/99/9999").
    vheader = vheader +  
                if vperpagamento then " Retroativo Pagto: " +  string(vdtpagref,"99/99/9999")
                else "". 

        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "135"
            &Page-Line = "66"
            &Nom-Rel   = ""CHELI8""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS"" + "" - "" +
                            string(vsit,""PAG/LIB"") + vheader "
            &Width     = "135"
            &Form      = "frame f-cabcab"}

    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".


    create ttx. ttx.chesit = "LIB".
    create ttx. ttx.chesit = "PAG".
    
    for each ttx,
        each cheque where cheque.chesit = ttx.chesit  and
                          cheque.cheven >= vdti and
                          cheque.cheven <= vdtf
                                        no-lock break by cheque.cheetb:

            if cheque.cheetb = 900
            then next.
            output stream stela to terminal.
            disp stream stela
                 cheque.cheven
                 cheque.clicod
                  with frame fffpla centered 1 down.
            pause 0.
            output stream stela close.
            
            if vperpagamento
            then do:
                /* 14042022 helio - 214140 . EXPORTAÇÃO DE RELATÓRIOS RETROATIVO */
                    if cheque.chesit = "LIB"
                    then. 
                    else do:
                        if cheque.chepag >= vdtpagref
                        then.
                        else next.
                    end.
                /* 14042022 helio - 214140 . EXPORTAÇÃO DE RELATÓRIOS RETROATIVO */
                
            end.
            else do:
                if vsitu = cheque.chesit
                then.
                else next.
            end.        
            
            totval = totval + cheque.cheval.
            totjur = totjur + cheque.chejur.
            
            if last-of(cheque.cheetb)
            then do:
            
                display cheque.cheetb column-label "Fil" format ">>9"
                        totval(total) space(4)
                                with frame f-imp width 150 down.
                totval = 0.
                totjur = 0.
            end.

    end.
    
    output close.  
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
    {mrod.i}
    end.
end.
