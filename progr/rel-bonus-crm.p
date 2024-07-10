{admcab.i}

def var vetbcod like estab.etbcod.
def var vmes as int format "99".
def var vano as int format "9999".
def var vacao-cod as int.
def var vsit like titulo.titsit.

def stream stela.

vetbcod = setbcod.
vmes = month(today).
vano = year(today).

disp vetbcod with frame f1.
vsit = "LIB".
update vetbcod label "Filial" when setbcod = 999
       vmes    label "Mes"
       vano    label "Ano"
       vacao-cod label "Codigo Acao"
       vsit    label "Sit."
       with frame f1 side-label width 80.
       
def var vdti as date.
def var vdtf as date.
def var vdata as date.

vdti = date(vmes,01,vano).
vdtf = date(if vmes = 12 then 01 else vmes + 1, 01, 
            if vmes = 12 then vano + 1 else vano) - 1.

def var varquivo as char.
def var vacao as char.
       
varquivo = "/admcom/relat/relbonuscrm." + string(time).

/*varquivo = "/dados-apache/relat-loja/filial0" + string(vetbcod) + "/relbonuscrm." + string(time).*/

output stream stela to terminal.

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "150"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA COMERCIAL"""
            &Tit-Rel   = """RELATORIO BONUS CRM"""
            &Width     = "155"
            &Form      = "frame f-cabcab"}

disp with frame f1.

for each estab no-lock:
    if vetbcod > 0 and
       estab.etbcod <> vetbcod 
    then next.
    disp stream stela estab.etbcod with side-label.
    pause 0.
    do vdata = vdti to vdtf:    
        for each titulo where
             titulo.empcod = 19 and
             titulo.titnat = yes and
             titulo.modcod = "BON" and
             titulo.etbcod = estab.etbcod and
             titulo.titdtven = vdata and
             titulo.titsit = vsit
             no-lock:
            
            find clien where clien.clicod = titulo.clifor no-lock no-error.
            
            if vacao-cod > 0
               and titulo.titobs[1] <> string(vacao-cod)
            then next.
            
            vacao = "".
            if titulo.titobs[1] <> "" and
               titulo.titobs[1] <> "0"
            then vacao = titulo.titobs[1] + "-".

            if acha("BONUS",titulo.titobs[2]) <> ?
            then vacao = vacao + acha("BONUS",titulo.titobs[2]).
            else next.
            
            disp titulo.clifor                  column-label "Cliente"
                 clien.clinom when avail clien  column-label "Nome"
                            format "x(30)"
                 titulo.etbcod    format ">>9"  column-label "Fil"
                 clien.zona when avail clien format "x(30)" 
                                                column-label "Email"
                 clien.fax when avail clien column-label "Celuar"
                 titulo.titvlcob                column-label "Bonus"
                 vacao      format "x(30)"      column-label "Acao"
                 titulo.titdtven                column-label "Vencimento"
                 with frame f-disp down width 160
                 .
            down with frame f-disp.
            
        end.
    end.
end.
output close.
output stream stela close.

def var vpdf as char no-undo.

    /*if setbcod <> 999
    then do:
        run pdfout.p (input varquivo,
                      input "/admcom/kbase/pdfout/",
                      input "relbonuscrm-" + string(time) + ".pdf",
                      input "Portrait",
                      input 8.2,
                      input 1,
                      output vpdf).
        /*message ("Arquivo " + vpdf + " gerado com sucesso!").*/
    end.
    else do:
        run visurel.p(input varquivo, input "").
    end.*/
    
    /*if opsys = "UNIX"
    then do:*/
        sresp = yes.
        run mensagem.p (input-output sresp,
                        input "A opcao ENVIAR enviara o arquivo " +
                        entry(3,varquivo,"/") +
                        " para sua filial para ser visualizado" +
                         " ou impresso via PORTA RELATORIOS"
                        + "!!"
                        + "         O QUE DESEJA FAZER ? ",
                        input "",
                        input "Visualizar",
                        input "Enviar ").
        if sresp = yes
        then do:
            run visurel.p(input varquivo, input "").
        end.
        else do:
    
            unix silent value("sudo scp -p " + varquivo + /*".z" +*/
                              " filial" + string(setbcod,"999") +
                              ":/usr/admcom/porta-relat").
            message "ARQUIVO ENVIADO... " VARQUIVO. PAUSE.
        end.
    /*end.*/                