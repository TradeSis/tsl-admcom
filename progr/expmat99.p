/***************************************************************************
** Programa        : Expmat99.p
** Objetivo        : Exportacao de Dados para a Loja
** Ultima Alteracao: 24/06/96
** Programador     :
****************************************************************************/
{admcab.i}

{inc-cont.i}.

def var contcli as int.
def var contcon as int.
def var conttit as int.
def var contest as int.
def var contpro as int.
def var contpla as int.
def var contmov as int.

def buffer bestab for estab.
def var vdt as date format "99/99/9999".
def stream tela.
def var vdata as date initial today.

def new shared frame fmostra.
def new shared var conta1       as integer.
def new shared var conta2       as integer.
def new shared var conta3       as integer.
def new shared var conta4       as integer.
def new shared var conta5       as integer.
def new shared var conta6       as integer.
def var conta7 as int.


def var varq                    as char                     no-undo.
def var vachou                  as log                      no-undo.
def var v-dtini                 as date format "99/99/9999" init today no-undo.
def var v-dtfin                 as date format "99/99/9999" init today no-undo.
def var vtoday                  as date format "99/99/9999" init today no-undo.
def var vtime                   as int  format "999999"      .


def var v-etbcod                like estab.etbcod           no-undo.
def var i-cont                  as integer init 0           no-undo.
def var vmodcod                 like titulo.modcod.
def var verro                   as log.
def var funcao                  as char.
def var parametro               as char.
def var vregcod                 like regiao.regcod.

output stream tela  to terminal.

pause 0 before-hide.
form v-dtini         colon 16 label "Data Inicial"
     v-dtfin         label "Data Final"
     with overlay row 5 side-labels frame f-selecao centered color white/cyan
     2 column title " PERIODO ".

assign conta1 = 0
       conta2 = 0
       conta3 = 0
       conta4 = 0
       conta5 = 0
       conta7 = 0
       contcli = 0
       contcon = 0
       conttit = 0
       contest = 0
       contpro = 0
       contpla = 0
       contmov = 0.

form skip(1)
     "*** ATENCAO :  Saldo do Caixa nao fechou "
     "               com o Saldo Exportado !!"
     skip(1)
     with centered  color blink/red title " ERRO DE EXPORTACAO " 1 column
     no-label row 8 frame faviso.

form skip(1)
     "Arquivo de Saldos   :" conta2 skip
     "Arquivo de Controle :" conta1 skip
     "Titulos             :" conta3 skip
     "Clientes            :" conta4 skip
     "Contratos           :" conta5 skip
     "Fornecedores        :" conta7 
     skip(1)
     with frame fmostra row 9 column 18 color blue/cyan no-label
     title " EXPORTACAO DE DADOS - CPD ".

form skip(01)
     conta2 skip
     conta1 skip
     skip(04)
     with frame flimpa row 9 column 52 color blue/cyan no-label
     title " LIMPA ".

/*run contexp.p. */

view stream tela frame flimpa.
view stream tela frame fmostra.


def var dt like plani.pladat.
def temp-table tt-data
    field dt like plani.pladat.

for each tt-data:
    delete tt-data.
end.


repeat:
    dt = ?.
    update dt label "Data" with frame f-dt side-label centered.
    create tt-data.
    assign tt-data.dt = dt.
end.

hide frame f-dt no-pause.


update  sresp label "Confirma Exportacao de Dados ? "
        with row 19 column 03 color white/red side-labels frame f1.

if  not sresp then
    leave.

do on error undo, retry:
    update vregcod
           with row 19 column 42 color white/red side-labels frame f2.
    find regiao where regiao.regcod = vregcod no-lock no-error.
    if not avail regiao
    then do:
        bell.
        message "Regiao Nao Cadastrada !!".
        undo, retry.
    end.

    display regiao.regnom no-label format "x(20)"
            with frame f2.
end.
input from ..\admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
end.
input close.

find first tt-data.
v-dtini = tt-data.dt.
find last tt-data.
v-dtfin = tt-data.dt.
display v-dtini
        v-dtfin with frame f-selecao.
        
output to ..\EXPORT\export.d.
put setbcod " " v-dtini " " v-dtfin.
output close.

output to ..\export\titulo.d.

for each tt-data,
    each titulo where titulo.datexp = tt-data.dt no-lock:

    if titulo.titnat = yes
    then next.
    if titulo.modcod <> "CRE"
    then next.
    if titulo.clifor = 1
    then next.
    if titulo.etbcod <> 990
    then do:
        find estab where estab.etbcod = titulo.etbcod no-lock no-error.
        if not avail estab
          then next.
        if estab.regcod <> vregcod
           then next.
    end.

    vmodcod = titulo.modcod.
    if titulo.titdtpag = ?
    then
        vmodcod = "VDP".
    if titulo.titpar    = 0 or
       titulo.clifor    = 1
    then do:
        if titulo.clifor = 1
        then vmodcod = "VDV".
        else vmodcod = "ENT".
    end.
    if titulo.titsit = "IMP"
    then assign titulo.titsit = "LIB".

    
    export titulo.empcod     
           titulo.modcod      
           titulo.CliFor      
           titulo.titnum      
           titulo.titpar      
           titulo.titnat      
           titulo.etbcod      
           titulo.titdtemi    
           titulo.titdtven    
           titulo.titvlcob    
           titulo.titdtdes    
           titulo.titvldes    
           titulo.titvljur    
           titulo.cobcod      
           titulo.bancod      
           titulo.agecod      
           titulo.titdtpag    
           titulo.titdesc     
           titulo.titjuro     
           titulo.titvlpag   
           titulo.titbanpag    
           titulo.titagepag    
           titulo.titchepag    
           titulo.titobs[1]    
           titulo.titobs[2]    
           titulo.titsit       
           titulo.titnumger    
           titulo.titparger    
           titulo.cxacod       
           titulo.evecod       
           titulo.cxmdata      
           titulo.cxmhora      
           titulo.vencod       
           titulo.etbCobra     
           titulo.datexp       
           titulo.moecod.   
        
    {alt-cont.i Titulo}.
    
    conttit = conttit + 1.
    conta3 = conta3 + 1.
    display stream tela conta3 with frame fmostra.

    conta1 = conta1 + 1.
    display stream tela conta1 with frame fmostra.
    pause 0.
end.
output close.

verro = no.

output to ..\export\fabri.d.
for each tt-data,
    each fabri where fabri.fabdtcad = tt-data.dt no-lock:
    export fabri.
    {alt-cont.i Fabricante}.
    conta7 = conta7 + 1.
    display stream tela conta7 with frame fmostra.
    pause 0.
end.
output close.


i-cont = 0.
output to ..\export\clien.d.
for each tt-data,
    each clien where clien.datexp = tt-data.dt no-lock:
      export clien.
      {alt-cont.i Clientes}.
      contcli = contcli + 1.
      conta4 = conta4 + 1.
      display stream tela conta4 with frame fmostra.
      pause 0.
end.
output close.

/*
 dos silent del value("..\export\est" + string(vregcod,"99") + ".d").
 for each produ no-lock:
    find first movim where movim.procod = produ.procod and
                           movim.movdat >= v-dtini and
                           movim.movdat <= v-dtfin no-lock no-error.
               
    if not avail movim
    then next.
    
    for each estab where estab.regcod = vregcod no-lock: 
        
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
                
        output to value("..\export\est" + string(estab.regcod,"99") + ".d")                append.
            
            put chr(34) format "X"
                estoq.etbcod format "99" 
                estoq.procod format ">>>>>9" 
                estoq.estatual format "->>>>>9" chr(34) format "X" skip.
                
        output close.     
        {alt-cont.i Estoque}.
        conta4 = conta4 + 1.
        display stream tela conta4 with frame fmostra.
    end.
 end.
*/ 


output to ..\export\produ.d.
for each tt-data,
    each produ where produ.datexp = tt-data.dt no-lock:
    export produ.
    {alt-cont.i Produto}.
    contpro = contpro + 1.
end.
output close.

output to ..\export\glopre.d.
for each tt-data,
    each glopre where glopre.datexp = tt-data.dt no-lock:
    export glopre.
    {alt-cont.i Glopre}.
    contpro = contpro + 1.
end.
output close.


output to ..\export\finan.d.
for each cpag no-lock:
    find finan where finan.fincod = cpag.cpagcod no-lock no-error.
    if avail finan
    then do :
        export finan.
        {alt-cont.i Finan}.
    end.
end.
output close.

output to ..\export\plesp.d.
for each plesp no-lock:
    export plesp.
    {alt-cont.i PlEsp}.
end.
output close.


output to ..\export\sprint.txt.
for each sprint where sprint.sprtip = "N" no-lock:
     export sprint.
     {alt-cont.i Sprint}.
end.
output close.


output to ..\export\ecf.txt.
for each ecf no-lock:
    export ecf.
    {alt-cont.i Ecf}.
end.
output close.
                   /*
output to ..\export\propg.d.
for each tt-data,
    each propg where propg.prpdata = tt-data.dt no-lock:
    export propg.
    {alt-cont.i Propg}.
end.
output close.
                   */
output to ..\export\estoq.d.
for each tt-data,
    each estoq where estoq.datexp = tt-data.dt no-lock:
    find estab where estab.etbcod = estoq.etbcod no-lock no-error.
    if not avail estab
    then next.
    if estab.regcod = regiao.regcod
    then do:
        export estoq.
        {alt-cont.i Estoque}.
        contest = contest + 1.
    end.
end.
output close.

output to ..\export\tabmen.d.
for each tt-data,
    each tabmen where tabmen.datexp = tt-data.dt no-lock:
    if tabmen.regcod = vregcod
    then do :
        export tabmen.
        {alt-cont.i TabelaMensagem}.
    end.
end.
output close.
    
    output to ..\export\plani.d.
    for each tt-data,
        each plani use-index datexp where plani.datexp = tt-data.dt no-lock:
        if plani.usercod = "NAO"
        then next.
        if plani.movtdc = 6 or
           plani.movtdc = 7 or
           plani.movtdc = 8 or
           plani.movtdc = 17 or
           plani.movtdc = 18
        then do:
            export plani.
            {alt-cont.i NotaFiscal}.
            contpla = contpla + 1.
        end.
    end.
    output close.

    
    output to ..\export\plani.d append.
    for each tt-data,
        each retra where retra.dtsol = tt-data.dt no-lock,
        each plani use-index datexp where plani.datexp = retra.dtret  and
                                          plani.etbcod = retra.etbcod
                                          no-lock:
        if plani.usercod = "NAO"
        then next.
        if plani.movtdc = 6 or
           plani.movtdc = 7 or
           plani.movtdc = 8 or
           plani.movtdc = 17 or
           plani.movtdc = 18
        then do:
            export plani.
            {alt-cont.i NotaFiscal}.
            contpla = contpla + 1.
        end.
    end.
    output close.

     
    output to ..\export\movim.d.
    for each tt-data,
        each plani use-index datexp where plani.datexp = tt-data.dt no-lock:
        if plani.movtdc = 6 or
           plani.movtdc = 7 or
           plani.movtdc = 8 or
           plani.movtdc = 17 or
           plani.movtdc = 18
        then do:
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:
                export  movim.movtdc   
                        movim.PlaCod   
                        movim.etbcod   
                        movim.movseq   
                        movim.procod   
                        movim.movqtm   
                        movim.movpc    
                        movim.MovDev   
                        movim.MovAcFin 
                        movim.movipi   
                        movim.MovPro   
                        movim.MovICMS  
                        movim.MovAlICMS  
                        movim.MovPDesc   
                        movim.MovCtM     
                        movim.MovAlIPI   
                        movim.movdat     
                        movim.MovHr      
                        movim.MovDes     
                        movim.MovSubst   
                        movim.OCNum[1]   
                        movim.OCNum[2]   
                        movim.OCNum[3]   
                        movim.OCNum[4]   
                        movim.OCNum[5]   
                        movim.OCNum[6]   
                        movim.OCNum[7]   
                        movim.OCNum[8]   
                        movim.OCNum[9]   
                        movim.datexp.
                            
                {alt-cont.i ProdutoNota}.
                            
                contmov = contmov + 1.
            end.
        end.
    end.
    output close.
     
    output to ..\export\movim.d append.
    for each tt-data,
        each retra where retra.dtsol = tt-data.dt no-lock,
        each plani use-index datexp where plani.datexp = retra.dtret   and
                                          plani.etbcod = retra.etbcod no-lock:
        if plani.movtdc = 6 or
           plani.movtdc = 7 or
           plani.movtdc = 8 or
           plani.movtdc = 17 or
           plani.movtdc = 18
        then do:
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc and
                                 movim.movdat = plani.pladat no-lock:
                export  movim.movtdc  
                        movim.PlaCod   
                        movim.etbcod   
                        movim.movseq   
                        movim.procod   
                        movim.movqtm   
                        movim.movpc    
                        movim.MovDev   
                        movim.MovAcFin 
                        movim.movipi   
                        movim.MovPro   
                        movim.MovICMS  
                        movim.MovAlICMS  
                        movim.MovPDesc   
                        movim.MovCtM     
                        movim.MovAlIPI   
                        movim.movdat     
                        movim.MovHr      
                        movim.MovDes     
                        movim.MovSubst   
                        movim.OCNum[1]   
                        movim.OCNum[2]   
                        movim.OCNum[3]   
                        movim.OCNum[4]   
                        movim.OCNum[5]   
                        movim.OCNum[6]   
                        movim.OCNum[7]   
                        movim.OCNum[8]   
                        movim.OCNum[9]   
                        movim.datexp.    

                {alt-cont.i ProdutoNota}.
                
                contmov = contmov + 1.
            end.
        end.
    end.
    output close.


i-cont = 0.
output to ..\export\contrato.d.
for each tt-data,
    each contrato where contrato.datexp = tt-data.dt no-lock:

    if contrato.etbcod <> 990
    then do:
        find estab where estab.etbcod = contrato.etbcod no-lock no-error.
        if not avail estab
           then next.
        if estab.regcod <> vregcod
           then next.
    end.

    export contrato.
    {alt-cont.i Contrato}.
    contcon = contcon + 1.
    conta5 = conta5 + 1.
    display stream tela conta5 with frame fmostra.
    pause 0.
end.
output close.

    vtoday = today.
    vtime  = time.
    output to ..\export\controle.d.
        put contcli " "
            contcon " "
            conttit " "
            contpro " "
            contest " "
            contpla " "
            contmov " " 
            v-dtini " " 
            v-dtfin " "
            vtoday  " " 
            vtime .
            
    output close.
/*
    if not connected("suporte")
    then connect -db suporte -N tcp -S sdrebsup -H linux.
    
    if connected("suporte")
    then*/ do:
        for each estab where estab.regcod = vregcod no-lock: 
            run controle.p (input "cri", 
                            input contcli,  
                            input contcon, 
                            input conttit,  
                            input contpro,  
                            input contest,  
                            input contpla,  
                            input contmov,   
                            input v-dtini,   
                            input v-dtfin,  
                            input vtoday,    
                            input vtime,
                            input estab.etbcod).
        end.
        /*disconnect suporte.*/
    end.



output to value("..\export\cpd" + string(vregcod,"99") + "\log" + 
                   string(day(today)) + string(month(today)) + ".d" ). 
for each ttcontrole :
    put ttcontrole.nome format "x(30)"
        space(2)
        ttcontrole.qtd at 40 
        skip.
end.
output close.



