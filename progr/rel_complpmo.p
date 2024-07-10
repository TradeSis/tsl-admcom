{admcab.i}
 
prompt-for complpmo.mescomp label "Competencia Mes/Ano" format "99"
        validate(input complpmo.mescomp > 0 ,"Informe o mes de competencia.")
           "/"
           complpmo.anocomp no-label  format "9999"
           validate(input complpmo.anocomp > 0,"Informe o ano de competencia.")
           with frame f-ma side-label width 80
           .
 
{setbrw.i}                                                                      
{seltpmo.i " " "PREMIO"}


def var tot-blo as dec.
def var tot-lib as dec.
def var tot-exc as dec.
def var tot-pen as dec.
def var vtot-marcado as dec.
def var vqtd-marcado as int.

def var sit-premio as char format "x(22)" extent 5.
assign
    sit-premio[1] = "BLO - Bloqueado"
    sit-premio[2] = "LIB - Liberado"
    sit-premio[3] = "EXC - Excluido"
    sit-premio[4] = "NEG - Negado"
    sit-premio[5] = "PEN - Bloqueado P.Bis".
def var sit-p as char format "x(15)" extent 5.
assign
    sit-p[1] = "BLO"
    sit-p[2] = "LIB"
    sit-p[3] = "EXC"
    sit-p[4] = "NEG"
    sit-p[5] = "PEN".
    
def var vetbcod like estab.etbcod.
def var vdti    as date.
def var vdtf    as date.
def var vforcod like foraut.forcod.
def var vtitsit like titluc.titsit init "".

def temp-table tt-titsit
    field titsit like titulo.titsit.
create tt-titsit.
tt-titsit.titsit = "LIB".
create tt-titsit.
tt-titsit.titsit = "BLO".
create tt-titsit.
tt-titsit.titsit = "PEN".
create tt-titsit.
tt-titsit.titsit = "EXC". /*** Novo ***/
create tt-titsit.
tt-titsit.titsit = "AUT". /*** 04/12/2014 ***/

/*
assign
    vdti = today - 80.
*/

    update vetbcod label "     Filial" with frame f-ma.

    /*
    update vtitsit label "Sit".
    if vtitsit <> ""
    then do.
        find first tt-titsit where tt-titsit.titsit = vtitsit no-lock no-error.
        if not avail tt-titsit
        then do.
            message "Situacao invalida" view-as alert-box.
            undo.
        end.
    end.
    */

def temp-table tt-titluc like titluc
   index i1 titdtven .

form tt-titluc.agecod   format "x" no-label
     tt-titluc.etbcod   column-label "Etb"   format ">>9"
     tt-titluc.vencod
     tt-titluc.titnum   column-label "Venda"
     tt-titluc.titdtven column-label "Data"  format "99/99/99"
     tt-titluc.titvlcob column-label "Valor" format ">>>9.99"
     tt-titluc.titobs[2] format "x(18)" no-label 
     tt-titluc.titnumger no-label format "x(13)"     
     tt-titluc.titsit column-label "Sit"
     with frame frame-a screen-lines - 14 down centered row 8 width 80 overlay.
                                                                                
def var vquem as char format "x(23)"  extent 7 
    init["VENDEDOR","GERENTE","PROMOTOR","CREDIARISTA",
         "TREINEE CREDIARIO","TREINEE CONFECCAO","CREDIARISTA PLANO BIS"].
def var vindex as int.

disp vquem
     with frame f-quem 1 down no-label 1 col.
choose field vquem with frame f-quem.
vindex = frame-index.
hide frame f-quem.
disp vquem[vindex] with frame fff 1 down no-label .
 
def var vfuncod like func.funcod.
if vquem[vindex] = "CREDIARISTA"
THEN VFUNCOD = 150.
if vquem[vindex] = "VENDEDOR" or
  vquem[vindex] = "CREDIARISTA PLANO BIS"
THEN DO on error undo:
    update vfuncod with frame f10 1 down side-label column 27.
    if vfuncod > 0 and vetbcod > 0
    then do.
        find func where func.etbcod = vetbcod and
                        func.funcod = vfuncod
                        no-lock no-error.
        if not avail func
        then do.
            message "Vendedor invalido" view-as alert-box.
            next.
        end.
        disp func.funnom no-label with frame f10.
    end.
    PAUSE 0.
end.

def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "130" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA ADMINISTRATIVO""" 
                &Tit-Rel   = """RELATORIO DE PREMIOS FOLHA""" 
                &Width     = "130"
                &Form      = "frame f-cabcab"}

disp with frame f-ma.
/*
disp vquem[vindex] no-label.
*/
for each tbpmofol where
         tbpmofol.anocomp = input frame f-ma complpmo.anocomp and
         tbpmofol.mescomp = input frame f-ma complpmo.mescomp and 
         (if vetbcod > 0 then tbpmofol.etbcod = vetbcod else true) and
         (if vfuncod > 0 then tbpmofol.funcod = vfuncod 
         else if vquem[vindex] = "VENDEDOR"
            then tbpmofol.apelido = ""
            else tbpmofol.apelido = vquem[vindex])
         no-lock:
    find func where func.etbcod = tbpmofol.etbcod and
                    func.funcod = tbpmofol.funcod
                    no-lock no-error.
    disp tbpmofol.etbcod   column-label "Fil"
         tbpmofol.codfol   column-label "Cod.Fol."
         func.funnom   when avail func  column-label "Nome"  format "x(30)"
         tbpmofol.apelido  column-label "Apelido"            format "x(20)"
         string(tbpmofol.mescomp,"99") + 
         "/" + string(tbpmofol.anocomp,"9999")  format "x(8)"
          column-label "Compet"
         tbpmofol.valcre(total) column-label "Credito" format ">,>>>,>>9.99"
         tbpmofol.valdeb(total) column-label "Debito"  format ">,>>>,>>9.99"
         tbpmofol.valliq(total) column-label "Liquido" format ">,>>>,>>9.99"
         with frame f-disp down width 150.
end.

output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.

