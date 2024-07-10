/***************************************************************************
** Programa        : Expmatb4.p
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

update v-dtini
       v-dtfin
       with frame f-selecao.

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
input from ..\gener\admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
end.
input close.

output to ..\EXPORT\export.d.
put setbcod " " v-dtini " " v-dtfin.
output close.

output to ..\export\titulo.d.
for each titulo where
         titulo.datexp >= v-dtini  and
         titulo.datexp <= v-dtfin no-lock:
         
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
    /*
    if titulo.titsit = "IMP"
    then assign titulo.titsit = "LIB".
    */
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
for each fabri where fabri.fabdtcad >= v-dtini and
                     fabri.fabdtcad <= v-dtfin:
    export fabri.
    {alt-cont.i Fabricante}.
    conta7 = conta7 + 1.
    display stream tela conta7 with frame fmostra.
    pause 0.
end.
output close.

 


i-cont = 0.
output to ..\export\clien.d.
for each clien where clien.datexp >= v-dtini and
                     clien.datexp <= v-dtfin:
      export clien.
      {alt-cont.i Clientes}.
      contcli = contcli + 1.
      conta4 = conta4 + 1.
      display stream tela conta4 with frame fmostra.
      pause 0.
end.
output close.

output to ..\export\produ.d.
for each produ where produ.datexp >= v-dtini and
                     produ.datexp <= v-dtfin no-lock:
    export produ.
    {alt-cont.i Produto}. 
    contpro = contpro + 1.
end.
output close.


output to ..\export\glopre.d.
for each glopre where glopre.datexp >= v-dtini and
                      glopre.datexp <= v-dtfin no-lock:
    export glopre.
    {alt-cont.i GloPre}.
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
    {alt-cont.i Plesp}.
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

output to ..\export\propg.d.
for each propg where propg.prpdata >= v-dtini and
                     propg.prpdata <= v-dtfin no-lock:
    export propg.
    {alt-cont.i Propg}.
end.
output close.

output to ..\export\estoq.d.
for each estoq where estoq.datexp >= v-dtini and
                     estoq.datexp <= v-dtfin no-lock:
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
for each tabmen where tabmen.datexp >= v-dtini and
                      tabmen.datexp <= v-dtfin no-lock:
    if tabmen.regcod = vregcod
    then do :
        export tabmen.
        {alt-cont.i TabelaMensagem}.
    end.
end.
output close.
    output to ..\export\plani.d.
    do vdt = v-dtini to v-dtfin:
        for each plani use-index datexp where plani.datexp = vdt no-lock:
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
    end.
    output close.

    output to ..\export\movim.d.
    do vdt = v-dtini to v-dtfin:
        for each plani use-index datexp where plani.datexp = vdt no-lock:
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
    end.
    output close.

i-cont = 0.
output to ..\export\contrato.d.
for each contrato where contrato.datexp >= v-dtini and
                        contrato.datexp <= v-dtfin:

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

    output to ..\export\controle.d.
        put contcli " "
            contcon " "
            conttit " "
            contpro " "
            contest " "
            contpla " "
            contmov " " 
            v-dtini " " 
            v-dtfin.
    output close.


/*


bell.
bell.

def var vi as int.
def var vmarcado as dec format ">>>,>>>,>>>,>>9 Bytes" .
def var vtotal   as dec format ">>>,>>>,>>>,>>9 Bytes".
def var vCOPIADO as dec format ">>>,>>>,>>>,>>9 Bytes".
DEF VAR vunida-origem  AS CHAR INITIAL ".." label "Unidade Origem".
DEF VAR vunida-destino AS CHAR INITIAL "A:" label "Unidade Destino".
def var vdir as char.
def var vaux as char.
def var vokdos  as log.
DEF VAR A AS CHAR FORMAT "X(40)".
def var B   as char  format "x(40)".
def var C   as char  format "x(40)".
def var D   as char  format "x(40)".
def var E   as char  format "x(40)".
def var F   as char format "x(40)".
def var G   as char format "x(40)".
def var H   as char format "x(40)".
def var I   as char format "x(40)".
def var J   as char format "x(40)".
def temp-table wf-dir
    field diretorio as char format "x(50)".

def temp-table wf-prog
    field ast   as char format "x" column-label "*"
    field dir as char   format "x(25)" column-label "Diretorio"
    field prog as char  format "x(8)" column-label "Arquivo"
    field exten as char  format "x(3)" column-label "Ext"
    field taman as int                column-label "Tamanho"
    field data  as date                column-label "Alteracao".



DOS SILENT DIR VALUE("..\export\*.d /OD ") > exporta.arq.

INPUT FROM ./exporta.arq no-echo.
REPEAT:
    pause 0.
    SET A
        B
        C
        D
        E
        F
        G
        H
        I
        J
      WITH 1 DOWN 1 column
            side-labels.
    if b <> "D" then next.

    do:
        do vi = 1 to 20:
            substring(c,vi,1) = if substring(c,vi,1) = "."
                                then ""
                                else substring(c,vi,1).
        end.
        create wf-prog.
        assign
            wf-prog.ast  = if b = "p" or
                              b begins "i"
                           then "*"
                           else ""
            wf-prog.dir  = lc(vdir)
            wf-prog.prog = lc(a)
            wf-prog.exten = lc(b)

            wf-prog.taman = dec(c).
            wf-prog.data = if opsys = "UNIX"
                           then ?
                           else date(int(substring(d,4,2)),
                                int(substring(d,1,2)),
                                 1900 + int(substring(d,7,2))).
            if wf-prog.ast = "*"
            then vmarcado = vmarcado + wf-prog.taman.
            vtotal   = vtotal   + wf-prog.taman.
    end.
end.
input close.


message "Confirma a Geracao de DISQUETE ?" update sresp.

if sresp
then do:
    if vtotal > 1440000 and sresp
    then do on endkey undo:
        bell.
        bell.
        bell.
        message
            "Houve falta de espaco no Disquete  /  Comunicar ao *** CPD ***".
        pause.

        varq = "..\relat\" + STRING(TIME) + ".REL".
        message "Imprime o Arquivo" varq "?" update sresp.
        if sresp
        then dos silent value("type " + varq + " > prn").

        do transaction:
            find first estab where estab.regcod = vregcod no-lock no-error.
            do vdata = v-dtini to v-dtfin:
                find exporta where exporta.etbcod  = estab.etbcod and
                                   exporta.exporta = vdata no-error.
                if not avail exporta
                then do:
                    create exporta.
                    assign exporta.etbcod  = estab.etbcod
                           exporta.exporta = vdata.
                end.
            end.
        end.

        run exprel.p ( input v-dtini,
                       input v-dtfin,
                       input setbcod).

        leave.
    end.

    bell.
    pause message "Coloque Diskette na Unidade A: e pressione uma tecla".

    dos silent "copy /y ..\export\contrato.d  a: ".
    dos silent "copy /y ..\export\clien.d     a: ".
    dos silent "copy /y ..\export\titulo.d    a: ".
    dos silent "copy /y ..\export\salexpor.d  a: ".
    dos silent "copy /y ..\export\export.d    a: ".
    dos silent "copy /y ..\export\produ.d    a: ".
    dos silent "copy /y ..\export\plesp.d    a: ".
    dos silent "copy /y ..\export\finan.d    a: ".
    dos silent "copy /y ..\export\propg.d    a: ".
    dos silent "copy /y ..\export\estoq.d    a: ".
end.

varq = "..\relat\" + STRING(TIME) + ".REL".

output to value(varq).
view frame fmostra.
output to close.

message "Imprime o Arquivo" varq "?" update sresp.
if sresp
then dos silent value("type " + varq + " > prn").


run exprel.p ( input v-dtini,
               input v-dtfin,
               input setbcod).

 */

output to value("..\export\cpd" + string(vregcod,"99") + "\log" + 
                   string(day(today)) + string(month(today)) + ".d" ). 
for each ttcontrole :
    put ttcontrole.nome format "x(30)"
        space(2)
        ttcontrole.qtd at 40 
        skip.
end.
output close.


