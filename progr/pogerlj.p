{admcab.i}

def var vrel as char.
def var v-etbcod like estab.etbcod.
def var v-data1  as date format "99/99/9999".
def var v-data2  as date format "99/99/9999".
def var v-catcod like categoria.catcod.
def var v-movtdc like tipmov.movtdc.
def var v-tipo as int.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

def var vfilial as char.

def var vdt as date.

def var sal-atu as int.
def var vmovtnom like com.tipmov.movtnom.
def var vtip as char format "x(20)" extent 3 
        initial ["Numerico","Alfabetico","Nota Fiscal"].

def var vv as char format "x".
def var fila as char.
              
def temp-table tt-produ 
    field procod like com.produ.procod
    field pronom as char format "x(20)"
    field prorec as recid
    field numero like com.plani.numero
    field movtdc like com.plani.movtdc
    
    field plano like plani.pedcod
    field vende like plani.vencod
    
    index tt numero desc
             procod desc.
    
def var varquivo as char format "x(20)".
def stream stela.
def var vtipmov like com.tipmov.movtnom.

def var vtotdia like com.plani.platot.
def var vtot  like com.movim.movpc.
def var vtotg like com.movim.movpc.
def var vtotgeral like com.plani.platot.

def var vtotal like com.plani.platot.
def var vtoticm like com.plani.icms.
def var vtotmovim   like com.movim.movpc.
def var vtotpro like com.plani.platot.

              /**** Campo usado para guardar o no. da planilha ****/

form com.plani.pladat format "99/99/9999"
     com.plani.numero format ">>>>>>9"
     com.plani.emite column-label "Emite"
     com.plani.desti column-label "Dest" format ">>>>>>>>>9"
     com.movim.procod
     com.produ.pronom format "x(40)"
     com.movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
     com.movim.movpc  format ">,>>9.99"
     vtotpro column-label "Total"
     vtipmov column-label "Movimento" format "x(18)"
     sal-atu column-label "saldo" format "->>>>>9" 
                        with frame f-val down no-box width 200.

def var vtitulo as char.
def var vopcao as int.
def var vescolha as char format "x(50)" extent 2
        initial [" 1. POSICAO FINANCEIRA VENCIDOS/A VENCER ",
                 " 2. ANALITICO                            "].

def var vsaida              as      log format "Impressora/Tela".
def var vprograma           as      char.
def var varq-retorno        as      char.
def var varq-retorno-zip    as      char.
def var vparametros         as      char.
def var vdatref             as      date format "99/99/9999".

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.

def var etb-tit like fin.titulo.etbcod.

vtitulo = "POSICAO FINANCEIRA VENCIDOS/A VENCER".

find estab where estab.etbcod = setbcod no-lock no-error.

disp estab.etbcod   label "Estabelecimento"
     estab.etbnom   no-label 
     with frame f-dados width 80 row 4 side-labels.
pause 0.
def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int.    

vindex = 0.
    if estab.etbcod = 17
    then do:
         disp v-fil17 with frame f-17 1 down centered row 10 
            no-label.
         choose field v-fil17 with frame f-17.
         vindex = frame-index.   
    end.
 
/*
vsaida = yes.
update vsaida       no-label
       help " [ I ]   Impressora     [ T ]   Tela       "
       with frame f-dados.
*/
vsaida = no.

def var vdtref  as   date format "99/99/9999".
def var vetbcod     like estab.etbcod.
def var vdisp   as   char format "x(8)".
def var vmes    as   char format "x(3)" extent 12 initial
                        ["JAN","FEV","MAR","ABR","MAI","JUN",
                         "JUL","AGO","SET","OUT","NOV","DEZ"] .

def var vtot1   like fin.titulo.titvlcob.
def var vtot2   like fin.titulo.titvlcob.

def workfile wf
    field vdt   as date
    field vencido like fin.titulo.titvlcob label "Vencido"
    field vencer  like fin.titulo.titvlcob label "Vencer".

update vdatref      label "Data Referencia" colon 25
           with  frame f-vecvcer side-labels centered.

if setbcod = 13
or setbcod = 8
or setbcod = 20
or setbcod = 80
or setbcod = 125
or setbcod = 24
or setbcod = 29
or setbcod = 38
or setbcod = 45
or setbcod = 48
or setbcod = 52
or setbcod = 100
or setbcod = 101
or setbcod = 103
or setbcod = 104
or setbcod = 108
or setbcod = 113
or setbcod = 130
or setbcod = 134
or setbcod = 301
then 
update v-consulta-parcelas-LP label "Considera apenas LP" colon 25
        help 
        "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"
       with side-label  frame f-vecvcer.
else v-consulta-parcelas-LP = no.

update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
    with frame f-vecvcer.

for each fin.titulo use-index titsit
         where fin.titulo.empcod = WEMPRE.EMPCOD and
               fin.titulo.titnat = no and
               fin.titulo.modcod = "CRE" and
               fin.titulo.titsit = "lib" and
               fin.titulo.etbcod = estab.etbcod no-lock:

    if fin.titulo.titdtemi > vdatref
    then next.

    if setbcod = 100 and
    titulo.titdtemi < 01/01/2009
    then next.
    
    if estab.etbcod = 17 and
           vindex = 2 and
           titulo.titdtemi >= 10/20/2010
        then next.  
        else if estab.etbcod = 17 and
            vindex = 1 and
            titulo.titdtemi < 10/20/2010
        then next.

    if setbcod = 23 and
       estab.etbcod = 17 and
       titulo.titdtemi > 04/30/2011
    then next.   

    etb-tit = fin.titulo.etbcod.
        
    run muda-etb-tit.

    if fin.titulo.etbcod = 10 and
                etb-tit = 23
    then next.
    
    /***if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"***/
    if fin.titulo.tpcontrato = "L"
    then assign v-parcela-lp = yes.
    else assign v-parcela-lp = no.

    if v-consulta-parcelas-LP = no
        and v-parcela-lp = yes
    then next.
                                                    
    if v-consulta-parcelas-LP = yes
        and v-parcela-lp = no
    then next.

    {filtro-feiraonl.i}

    find first wf where wf.vdt = date(month(fin.titulo.titdtven), 01,
                                      year(fin.titulo.titdtven)) no-error.
    if not available wf
    then
        create wf.
    assign wf.vdt = date(month(fin.titulo.titdtven), 01,
                                       year(fin.titulo.titdtven)).

    if fin.titulo.titdtven <= vdatref
    then wf.vencido = wf.vencido + fin.titulo.titvlcob.
    else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
end.
if  estab.etbcod = 23
then
        for each fin.titulo 
                 where fin.titulo.empcod = WEMPRE.EMPCOD and
                       fin.titulo.titnat = no and
                       fin.titulo.modcod = "CRE" and
                       fin.titulo.titsit = "LIB" and
                       fin.titulo.etbcod = 10 no-lock:
    
            if fin.titulo.titdtemi >= 01/01/14
            then next.

            /***if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"***/
            if fin.titulo.tpcontrato = "L"
            then assign v-parcela-lp = yes.
            else assign v-parcela-lp = no.
    
            if v-consulta-parcelas-LP = no
            and v-parcela-lp = yes
            then next.
                                                    
            if v-consulta-parcelas-LP = yes
                and v-parcela-lp = no
            then next.

            {filtro-feiraonl.i}

            etb-tit = 23.

            find first wf where wf.vdt = date(month(fin.titulo.titdtven), 01,
                                      year(fin.titulo.titdtven)) no-error.
    if not available wf
    then create wf.
    assign wf.vdt = date(month(fin.titulo.titdtven), 01,
                                       year(fin.titulo.titdtven)).

    if fin.titulo.titdtven <= vdatref
    then wf.vencido = wf.vencido + fin.titulo.titvlcob.
    else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
end.
  
 /**  
 varquivo = "/admcom/relat/vecvcer_" + string(setbcod,"999") + ".rel".
 **/

varquivo = "/admcom/relat/vencidos_vencer_" + string(setbcod,"999") + "." +
                string(day(vdatref),"99") + 
                string(month(vdatref),"99") + 
                string(year(vdatref),"9999").

{/admcom/progr/mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "137"
        &Page-Line = "66"
        &Nom-Rel   = """VECVCER2"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """POSICAO FIN. VENCIDAS/A VENCER - FILIAL - ""
                       + string(setbcod) + ""  Data Base: "" + 
                         string(vdatref,""99/99/9999"")"
        &Width     = "137"
        &Form      = "frame f-cab"}

for each wf break by wf.vdt.

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

sresp = yes.
    run mensagem.p (input-output sresp,
                    input "A opcao ENVIAR enviara o arquivo " +
                     entry(4,varquivo,"/") + 
                     " para sua filial para ser visualizado" +
                     " ou impresso via PORTA RELATORIOS"
                     + "!!"   + "         O QUE DESEJA FAZER ? ",
                    input "",
                    input "Visualizar",
                    input "Enviar ").
    if sresp = yes
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        unix silent value("sudo scp -p " + varquivo + /*".z" +*/
                        " filial" + string(setbcod,"999") +
                        ":/usr/admcom/porta-relat").

        message "ARQUIVO ENVIADO... " VARQUIVO. PAUSE. 
    end.

   
procedure muda-etb-tit.

    if etb-tit = 10 and
        fin.titulo.titdtemi < 01/01/2014
    then etb-tit = 23.
    
end procedure.

