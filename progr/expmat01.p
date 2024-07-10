/***************************************************************************
** Programa        : Expmat.p
** Objetivo        : Exportacao de Dados para a Loja
** Ultima Alteracao: 24/06/96
** Programador     :
** Data Alteracao  : 20/07/2001
   Autor ..........: Andre
   Descricao ......: Alteracao para colocar Log de Controle de Exportacao
****************************************************************************/

{admcab.i}

/***** colocado por Andre em 20/07/2001 ********/
{inc-cont.i}.
/***********************************************/

def var contcli as int.
def var contcon as int.
def var conttit as int.
def var contest as int.
def var contpro as int.
def var contpla as int.
def var contmov as int.
def stream spla.
def stream smov.
def var vnom as char.
def buffer bestab for estab.
def var vdt as date.
def stream tela.
def var vdata as date initial today format "99/99/9999".

def var vreg as int.
def new shared frame fmostra.
def new shared var conta1 as integer.
def new shared var conta2 as integer.
def new shared var conta3 as integer.
def new shared var conta4 as integer.
def new shared var conta5 as integer.
def new shared var conta6 as integer.

def var conta7 as int.

def var varq              as char no-undo.
def var vachou            as log  no-undo.
def var v-dtini                 as date format "99/99/9999" init today no-undo.
def var v-dtfin                 as date format "99/99/9999" init today no-undo.
def var v-etbcod                like estab.etbcod           no-undo.
def var i-cont                  as integer init 0           no-undo.
def var vmodcod                 like titulo.modcod.
def var verro                   as log.
def var funcao                  as char.
def var parametro               as char.
def var vregcod                 like regiao.regcod format "99".

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
       conttit = 0
       contcon = 0
       contest = 0
       contpro = 0
       contpla = 0
       contmov = 0
       conttit = 0.

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
     "Movimento de Estoque:" conta6 skip
     "Fornecedores        :" conta7 skip
     skip(1)
     with frame fmostra row 9 column 18 color blue/cyan no-label
     title " EXPORTACAO DE DADOS - CPD ".

form skip(01)
     conta2 skip
     conta1 skip
     skip(04)
     with frame flimpa row 9 column 52 color blue/cyan no-label
     title " LIMPA ".

/* run contexp.p. */

view stream tela frame flimpa.
view stream tela frame fmostra.

update v-dtini
       v-dtfin
       with frame f-selecao.

update  sresp label "Confirma Exportacao de Dados ? "
        with row 19 column 03 color white/red side-labels frame f1.

if not sresp then
leave.

input from ..\admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
end.
input close.
/*********************************************/
/************* geracao de livro de preco *********************/
message "Gerar Livro de Preco" update sresp.
if sresp
then run expliv.p.

    
    for each lancxa where datlan >= v-dtini and
                          datlan <= v-dtfin:

        if lancxa.lanhis = 1
        then do:
            find forne where forne.forcod = lancxa.forcod no-lock no-error.
            if avail forne
            then lancxa.comhis = lancxa.titnum + " " + forne.fornom.
        end.
    end.
 
    output to ..\export\cpd02\estab.d.
    for each estab no-lock:
        export estab.
        {alt-cont.i estab}.
    end.
    output close.

    
    output to ..\export\cpd02\clien.d.
    for each clien where clien.datexp >= v-dtini and
                         clien.datexp <= v-dtfin:
        export clien.
        {alt-cont.i Clien}.
        contcli = contcli + 1.
        conta4 = conta4 + 1.
        display stream tela conta4 with frame fmostra.
        pause 0.
    end.
    output close.


    output to ..\export\cpd02\produ.d.
    for each produ where produ.datexp >= v-dtini and
                         produ.datexp <= v-dtfin no-lock:

        export produ.
        {alt-cont.i produto}.
        contpro = contpro + 1.
    end.
    output close.
 
    
    dos silent del ..\export\cpd02\est??.d.
    dos silent del ..\export\cpd06\est??.d.
    dos silent del ..\export\cpd16\est??.d.
    dos silent del ..\export\cpd20\est??.d.
    dos silent del ..\export\cpd24\est??.d.

    /*
    for each produ no-lock:
        find first movim where movim.procod = produ.procod and
                               movim.movdat >= v-dtini and
                               movim.movdat <= v-dtfin no-lock no-error.
               
        if not avail movim
        then next.
    
        for each estab where estab.etbcod < 900 no-lock: 
            if {conv_igual.i estab.etbcod} then next.
        
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if not avail estoq
            then next.
                
            output to value("..\export\cpd" + string(estab.regcod,"99") + 
                            "\est" + string(estab.regcod,"99") + ".d") append.

                put chr(34) format "X"
                    estoq.etbcod format "99" 
                    estoq.procod format ">>>>>9" 
                    estoq.estatual format "->>>>>9" chr(34) format "X" skip.
                
            output close.   
            {alt-cont.i estoque}.
        end.
        conta6 = conta6 + 1.
        display stream tela conta6 with frame fmostra.

    end.
    */
    
    output to ..\export\cpd02\glopre.d.
    for each glopre where glopre.datexp >= v-dtini and
                          glopre.datexp <= v-dtfin no-lock:

        export glopre.
        {alt-cont.i glopre}.
        contpro = contpro + 1.
    end.
    output close.

 

    output to ..\export\cpd02\finan.d.
    for each cpag no-lock:
        find finan where finan.fincod = cpag.cpagcod no-lock no-error.
        if avail finan
        then do : 
            export finan.
            {alt-cont.i finan}.
        end.   
    end.
    output close.

    output to ..\export\cpd02\plesp.d.
    for each plesp no-lock:
        export plesp.
        {alt-cont.i plesp}.
    end.
    output close.

    
    output to ..\export\cpd02\sprint.txt.
    for each sprint where sprint.sprtip = "N" no-lock:
        export sprint.
        {alt-cont.i sprint}.
    end.
    output close.


    output to ..\export\cpd02\ecf.txt.
    for each ecf no-lock:
        export ecf.
        {alt-cont.i ecf}.
    end.
    output close.

    output to ..\export\cpd02\tabecf.txt.
    for each impre no-lock:
        put impre.codimp
            impre.codti skip.
        {alt-cont.i impre}.
    end.
    output close.

    output to ..\export\cpd02\propg.d.
    for each propg where propg.prpdata >= v-dtini and
                         propg.prpdata <= v-dtfin no-lock:

        export propg.
        {alt-cont.i propg}.
    end.
    output close.

    
    output stream spla to ..\export\cpd02\plani.d.
    output stream smov to ..\export\cpd02\movim.d.
    
    /*
    for each plani where plani.datexp >= v-dtini and
                         plani.datexp <= v-dtfin no-lock:
       if plani.usercod = "NAO"
       then next.
       if plani.movtdc = 6 or
          plani.movtdc = 7 or
          plani.movtdc = 8 or
          plani.movtdc = 17 or
          plani.movtdc = 18
       then do:
           export stream spla plani.
           {alt-cont.i NotaFiscal}.
           contpla = contpla + 1.
           for each movim where movim.etbcod = plani.etbcod and
                                movim.placod = plani.placod and
                                movim.movtdc = plani.movtdc and
                                movim.movdat = plani.pladat no-lock:
               export stream smov 
                      movim.movtdc   
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

                {alt-cont.i ProdutosNota}.

               contmov = contmov + 1.
           end.
           conta6 = conta6 + 1.
           display stream tela conta6 with frame fmostra.
       end.
    end.
    output stream spla close.
    output stream smov close.


    
    output stream spla to ..\export\cpd02\plani.d append.
    output stream smov to ..\export\cpd02\movim.d append.
    for each retra where retra.dtsol >= v-dtini and
                         retra.dtsol <= v-dtfin,
        each plani where plani.etbcod = retra.etbcod and
                         plani.datexp >= retra.dtret and
                         plani.datexp <= retra.dtret no-lock:
       if plani.usercod = "NAO"
       then next.
       if plani.movtdc = 6 or
          plani.movtdc = 7 or
          plani.movtdc = 8 or
          plani.movtdc = 17 or
          plani.movtdc = 18
       then do:
           export stream spla plani.
           {alt-cont.i NotaFiscal}.
           contpla = contpla + 1.
           for each movim where movim.etbcod = plani.etbcod and
                                movim.placod = plani.placod and
                                movim.movtdc = plani.movtdc and
                                movim.movdat = plani.pladat no-lock:
               export stream smov 
                      movim.movtdc   
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

                {alt-cont.i ProdutosNota}.
                contmov = contmov + 1.
           end.
           conta6 = conta6 + 1.
           display stream tela conta6 with frame fmostra.
       end.
       retra.livre = "SIM".
    end.
    output stream spla close.
    output stream smov close.
    */
    
    output to ..\export\cpd02\fabri.d.
    for each fabri where fabri.fabdtcad >= v-dtini and
                         fabri.fabdtcad <= v-dtfin:
        export fabri.
        {alt-cont.i Fabricante}.
        conta7 = conta7 + 1.
        display stream tela conta7 with frame fmostra.
        pause 0.
    end.
    output close.

do vreg = 20 to 20:
    if vreg <> 6 and
       vreg <> 16 and
       vreg <> 20 and
       vreg <> 24
    then next.
    
    dos silent copy ..\export\cpd02\movim.d
          value("..\export\cpd" + string(vreg,"99")) /y .
    

    dos silent copy ..\export\cpd02\plani.d
          value("..\export\cpd" + string(vreg,"99")) /y .
     
    
    dos silent copy ..\export\cpd02\ecf.txt
          value("..\export\cpd" + string(vreg,"99")) /y .
    
    dos silent copy ..\export\cpd02\sprint.txt
          value("..\export\cpd" + string(vreg,"99")) /y .

    dos silent copy ..\export\cpd02\tabecf.txt
          value("..\export\cpd" + string(vreg,"99")) /y .
    
 
    dos silent copy ..\export\cpd02\estab.d
          value("..\export\cpd" + string(vreg,"99")) /y .

     
    dos silent copy ..\export\cpd02\clien.d
          value("..\export\cpd" + string(vreg,"99")) /y .
    

    dos silent copy ..\export\cpd02\fabri.d
          value("..\export\cpd" + string(vreg,"99")) /y .
    
    
    dos silent copy ..\export\cpd02\produ.d
          value("..\export\cpd" + string(vreg,"99")) /y .
    
    dos silent copy ..\export\cpd02\glopre.d
          value("..\export\cpd" + string(vreg,"99")) /y .

 
    dos silent copy ..\export\cpd02\plesp.d
          value("..\export\cpd" + string(vreg,"99")) /y .

    dos silent copy ..\export\cpd02\finan.d
          value("..\export\cpd" + string(vreg,"99")) /y .

    dos silent copy ..\export\cpd02\propg.d
          value("..\export\cpd" + string(vreg,"99")) /y .
end.

/*********************************************/

vreg = 2.
do vreg = 20 to 20:
                 
    assign conta1 = 0 conta2 = 0 conta3 = 0
           conta4 = 0 conta5 = 0 contcli = 0
           conttit = 0 contcon = 0 conttit = 0
           contest = 0 contpro = 0 contpla = 0
           contmov = 0.

    if vreg <> 2 and vreg <> 6 and
       vreg <> 16 and vreg <> 20 and
       vreg <> 24
    then next.

    vregcod = vreg.
    find regiao where regiao.regcod = vregcod no-lock no-error.
    if not avail regiao
    then do:
        bell. message "Regiao Nao Cadastrada !!".
        undo, retry.
    end.

    display regiao.regnom with frame f2 side-label row 19 overlay
                                color white/red column 50.


    output to value("..\export\cpd" + string(vregcod,"99") + "\export.d").
        put setbcod " " v-dtini " " v-dtfin.
    output close.

    do transaction:
        for each estab where estab.regcod = vregcod no-lock:
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
    end.


    output to value("..\export\cpd" + string(vregcod,"99") + "\estoq.d").
    for each estoq where estoq.datexp >= v-dtini and
                         estoq.datexp <= v-dtfin no-lock:
        find estab where estab.etbcod = estoq.etbcod no-lock no-error.
        if not avail estab
        then next.
        if estab.regcod <> vregcod
        then next.
        export estoq.
        {alt-cont.i Estoque}.
        contest = contest + 1.
    end.
    output close.



    output to value("..\export\cpd" + string(vregcod,"99") + "\titulo.d").
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
            /*
            then do on error undo, retry on endkey undo, retry:
                bell.
                message "ATENCAO C.P.D.!!! Estab" titulo.etbcod
                        "nao Existe !!!".
                pause.
                next.
            end.
            */
            then next.
            if titulo.etbcod = 12 or
               titulo.etbcod = 11
            then do:
                if titulo.etbcod = 12
                then do:
                    if vregcod <> 20 and
                       vregcod <> 24
                    then next.
                    if vregcod = 24 and titulo.titdtemi < 09/01/99
                    then next.
                    if vregcod = 20 and titulo.titdtemi > 09/01/99
                    then next.
                end.
                if titulo.etbcod = 11
                then do:
                    if vregcod = 16 and titulo.titdtemi < 01/01/2000
                    then next.
                    if vregcod = 20 and titulo.titdtemi > 01/01/2000
                    then next.
                end.
            end.
            else do:
                if estab.regcod <> vregcod
                then next.
            end.
        end.

        vmodcod = titulo.modcod.
        if titulo.titdtpag = ?
        then vmodcod = "VDP".
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
        assign
            conttit = conttit + 1
            conta3 = conta3 + 1.
        display stream tela conta3 with frame fmostra.

        conta1 = conta1 + 1.
        display stream tela conta1 with frame fmostra.
        pause 0.
    end.
    output close.

    verro = no.

    i-cont = 0.

    output to value("..\export\cpd" + string(vregcod,"99") + "\tabmen.d").
    for each tabmen where tabmen.datexp >= v-dtini and
                          tabmen.datexp <= v-dtfin no-lock:
        if tabmen.regcod = vregcod
        then do : 
            export tabmen.
            {alt-cont.i TabMensagem}.
        end.
    end.
    output close.


    i-cont = 0.
    output to value("..\export\cpd" + string(vregcod,"99") + "\contrato.d").
    for each contrato where contrato.datexp >= v-dtini and
                            contrato.datexp <= v-dtfin no-lock:

        if contrato.etbcod <> 990
        then do:
            find estab where estab.etbcod = contrato.etbcod no-lock no-error.
            if not avail estab
            /*
            then do on error undo, retry on endkey undo, retry:
                bell.
                message "ATENCAO C.P.D.!!! Estab" titulo.etbcod
                        "nao Existe !!!".
                pause.
                next.
            end.
            */
            then next.
            if contrato.etbcod = 12 or
               contrato.etbcod = 11
            then do:
                if contrato.etbcod = 12
                then do:
                    if vregcod <> 20 and
                       vregcod <> 24
                    then next.
                    if vregcod = 24 and contrato.dtinicial < 09/01/99
                    then next.
                    if vregcod = 20 and contrato.dtinicial > 09/01/99
                    then next.
                end.
                if contrato.etbcod = 11
                then do:
                    if vregcod = 16 and contrato.dtinicial < 01/01/2000
                    then next.
                    if vregcod = 20 and contrato.dtinicial > 01/01/2000
                    then next.
                end.
            end.
            else do:
                if estab.regcod <> vregcod
                then next.
            end.

        end.
        export contrato.
        {alt-cont.i Contrato}.
        contcon = contcon + 1.
        conta5 = conta5 + 1.
        display stream tela conta5 with frame fmostra.
        pause 0.
    end.
    output close.
      
    output to value("..\export\cpd" + string(vregcod,"99") + "\controle.d").
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

    output to value("..\export\cpd" + string(vregcod,"99") + "\log" + 
                   string(day(today)) + string(month(today)) + ".d" ). 
                    
    for each ttcontrole :
        put ttcontrole.nome format "x(30)"
            space(2)
            ttcontrole.qtd at 40 
            skip.
    end.
    output close.
end.
