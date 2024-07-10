propath = "/admcom/progr,/usr/dlc".
    
    
{/admcom/progr/admcab-batch.i new}

def var vfilial as char.

def var p-etbcod like estab.etbcod.
def var p-dtref  as   date format "99/99/9999".

def var /*input  parameter*/ p-parametros as char.
def var /*output parameter*/ p-arquivo as char.

p-parametros = SESSION:PARAMETER.

p-etbcod = (int(acha("ETBCOD",p-parametros))).
p-dtref  = (date(acha("DATREF",p-parametros))).


def stream stela.

def var varquivo as char.
def var vdtref  as   date format "99/99/9999".
def var vetbcod     like estab.etbcod.
def var vdisp   as   char format "x(8)".
def var vtotal  like fin.titulo.titvlcob.
def var vmes    as   char format "x(3)" extent 12 initial
                        ["JAN","FEV","MAR","ABR","MAI","JUN",
                         "JUL","AGO","SET","OUT","NOV","DEZ"] .

def var vtot1   like fin.titulo.titvlcob.
def var vtot2   like fin.titulo.titvlcob.

def workfile wf
    field vdt   as date
    field vencido like fin.titulo.titvlcob label "Vencido"
    field vencer  like fin.titulo.titvlcob label "Vencer".

    find estab where estab.etbcod = p-etbcod no-lock no-error.
 
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    /**
    display estab.etbcod colon 20
            estab.etbnom no-label.
    **/
/**
update vdtref   label "Data Referencia"  colon 20
       with side-labels width 80 row 4 .
**/

/**output stream stela to terminal.**/

for each fin.titulo use-index titsit
         where fin.titulo.empcod = WEMPRE.EMPCOD and
               fin.titulo.titnat = no and
               fin.titulo.modcod = "CRE" and
               fin.titulo.titsit = "lib" and
               fin.titulo.etbcod = estab.etbcod no-lock:

    if fin.titulo.titdtemi > p-dtref
    then next.

    find first wf where wf.vdt = date(month(fin.titulo.titdtven), 01,
                                      year(fin.titulo.titdtven)) no-error.
    if not available wf
    then
        create wf.
    assign wf.vdt = date(month(fin.titulo.titdtven), 01,                          year(fin.titulo.titdtven)).

    if fin.titulo.titdtven <= p-dtref
    then
        wf.vencido = wf.vencido + fin.titulo.titvlcob.
    else
        wf.vencer  = wf.vencer + fin.titulo.titvlcob.
        
    /**
    display stream stela fin.titulo.clifor with frame fcli
                centered.
    pause 0.            
    **/                    
end.
/**
message "Gerando o Relatorio ".
output stream stela close.
**/
   
 varquivo = "/admcom/connect/retorna-rel/vecvcer_" + string(p-etbcod,"999") 
          + ".rel".
 p-arquivo = varquivo.

 {/admcom/progr/mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "137"
        &Page-Line = "66"
        &Nom-Rel   = """VECVCER2"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """POSICAO FIN. VENCIDAS/A VENCER - FILIAL - ""
                       + string(estab.etbcod) + ""  Data Base: "" + 
                         string(p-dtref,""99/99/9999"")"
        &Width     = "137"
        &Form      = "frame f-cab"}

for each wf break by vdt.

    vdisp = trim(string(vmes[int(month(wf.vdt))]) + "/" +
                 string(year(wf.vdt),"9999") ) .

    disp vdisp          column-label "Mes/Ano"
         wf.vencido     column-label "Vencido" (TOTAL)
         wf.vencer      column-label "A Vencer" (TOTAL)
         with centered .

        vtot1  = vtot1  +  wf.vencido.

        vtot2  = vtot2  +  wf.vencer.

        vtotal = vtotal + (wf.vencer + wf.vencido).
end.

    display ((vtot1 / vtotal) * 100) format ">>9.99 %" at 39
            ((vtot2 / vtotal) * 100) format ">>9.99 %" at 64 skip(1)
            with frame fsub.

    display vtotal label "Total Geral" at 40 with side-labels frame ftot.
    
       

    output close. 

/*os-command silent /fiscal/lp value(varquivo).*/
 
/*run visurel.p (input varquivo, input "").*/


vfilial = "filial" + string(p-etbcod,"999").

os-command silent
   /home/drebes/scripts/job-rel value(varquivo) value(vfilial) " & ".

