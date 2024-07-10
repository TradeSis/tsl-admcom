/*****************************************************************************
 Programa           : Coloca todos os clientes que estao atrazados no SPC
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : RegSPC.p
 Criacao            : 31/10/1996
 Ultima Alteracao   : 31/10/1996
                      Jan.2017 - Selecao por periodo

#1 - helio - 05.2018 - modificado leitura tabela contrato para evitar problemas
     com contratos duplos nao usa mais da tabela contrato o etbcod nem o clicod

#2 - Ricardo - 15.08.18 - titulos "LIB" com data de pagamento informada
#3 - Claudir - TP 28874183
#4 - Claudir - Alterado de 30 para 45 dias de atraso para inclusão no SPC
***************************************************************************/

def var vvltotal as dec. /* #1 */
def buffer xtitulo for titulo.          /* #1 */

{admcab.i}

{tt-modalidade-padrao.i new}
/*#3*/ 
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CPN".
/*#3*/

def temp-table tt-regcan no-undo
    field etbcod like estab.etbcod 
    field contnum like contrato.contnum
    field clicod like clien.clicod
    field dtven  as date format "99/99/9999"
    field dtneg  as date format "99/99/9999"
    index i1 clicod
    .

def var varquivo as char.
def stream sarq.
def var vachou     as log.
def var vv         as integer.
def var vdata      like plani.pladat  initial today.
def var vdtrefini  as date initial today.
def var vdtreffim  as date initial today.
def var vdtvenini  as date.
def var vdtvenfim  as date.
def stream tela.
def var vproto     as i format ">>>>9".
def buffer bclispc for clispc.

form with frame f-ini.
do on error undo with frame f-ini
            width 80 color white/cyan row 4 side-label.
    update vdtrefini label "Data Referencia Inicial" colon 25
    help "Registro de SPC dos vencimentos 30 dias antes da Data de Referencia".
    update vdtreffim label "Final".

    vdtvenini = vdtrefini - 30.
    vdtvenfim = vdtreffim - 30.

    disp
        vdtvenini label "Vencimento de" colon 25
        vdtvenfim label "ate".
end.

sresp = no.
message "Confirma processamento?" update sresp.
if not sresp
then return.

for each regcan:
    delete regcan.
end.

find last bclispc no-lock.
vproto = bclispc.spcpro + 1.

output stream tela to terminal.

vachou = no.
for each estab  no-lock :
    do vdata = vdtrefini to vdtreffim.
        for each tt-modalidade-padrao no-lock,
            each titulo use-index titdtven
                            where titulo.empcod   = wempre.empcod and
                                  titulo.titnat   = no            and
                                  titulo.modcod   = 
                                                tt-modalidade-padrao.modcod and
                                  titulo.titdtven = vdata - 45 /*#4 30*/    and
                                  titulo.etbcod   = estab.etbcod  and
                                  titulo.clifor   > 1             and
                                  titulo.titsit   <> "PAG" and
                                  titulo.titsit   <> "EXC" and
                                  titulo.titvlcob > 0 no-lock:
            if titulo.clifor = 15
            then next.

            if titulo.titsit = "LIB" and titulo.titdtpag <> ? /* #2 */
            then next.

            find clien where clien.clicod = titulo.clifor NO-LOCK no-error.
            if not avail clien
            then next.

            if vv mod 10 = 0
            then do.
                display vv      label "Registrados"
                        with centered color white/cyan row 9 1 down 1 column
                        title " SPC ".
                display "Analizando Cliente"
                        clien.clicod when avail clien
                        estab.etbcod
                        titulo.titdtven
                        titulo.titsit
                        titulo.clifor
                        with no-label side-label
                        color red/white centered row 13 1 down frame sds.
            end.
            pause 0.

            vachou = yes.

            find first clispc where clispc.clicod = TITULO.clifor and
                                    clispc.dtcanc = ? NO-LOCK no-error.
            if not avail clispc
            then do:
                find current clien exclusive.
                vv = vv + 1.
                create clispc.
                assign clispc.clicod    = titulo.clifor
                       clispc.contnum   = int(titulo.titnum)
                       clispc.datexp    = today
                       clispc.dtneg     = today /*vdata*/
                       clispc.dtcanc    = ?
                       clispc.spcpro    = vproto.
                if avail clien
                then assign clien.dtspc[1]   = ?.
                if true /* #1 */
                then do: 
                    /* #1 */
                    vvltotal = 0.
                    for each xtitulo where 
                        xtitulo.empcod = 19 and 
                        xtitulo.titnat = no and 
                        xtitulo.modcod = titulo.modcod and 
                        xtitulo.etbcod = titulo.etbcod and 
                        xtitulo.clifor = titulo.clifor and 
                        xtitulo.titnum = titulo.titnum
                        no-lock.
                        vvltotal = vvltotal + xtitulo.titvlcob.
                    end.    
                     /* #1 */
                     create regcan.
                     assign regcan.etbcod   = estab.etbcod
                            regcan.clicod   = titulo.clifor.
                     if avail clien
                     then regcan.clinom   = clien.clinom.
                     assign regcan.clinom = string(regcan.clinom,"x(40)") 
                                + "  Inclusao: " +
                                string (clispc.dtneg,"99/99/9999")
                            regcan.munic    = estab.munic
                            regcan.contnum  = int(titulo.titnum) /* #1 */
                            regcan.vltotal  = vvltotal           /* #1 */
                            regcan.titdtemi = titulo.titdtemi
                            regcan.titdtven = titulo.titdtven.
                end.
                create tt-regcan.
                assign
                    tt-regcan.etbcod = estab.etbcod 
                    tt-regcan.contnum = int(titulo.titnum)
                    tt-regcan.clicod = clien.clicod
                    tt-regcan.dtven  = titulo.titdtven
                    tt-regcan.dtneg  = clispc.dtneg
                    .
            end.
            /*else 
            if clispc.contnum = int(titulo.titnum) and
                    clispc.dtneg   > vdata and
                    clispc.dtcanc = ?
            then do:
                find first tt-regcan where
                           tt-regcan.clicod = clien.clicod no-error.
                if not avail tt-regcan
                then do:           
                create tt-regcan.
                assign
                    tt-regcan.etbcod = estab.etbcod 
                    tt-regcan.contnum = int(titulo.titnum)
                    tt-regcan.clicod = clien.clicod
                    tt-regcan.dtven  = titulo.titdtven
                    tt-regcan.dtneg  = clispc.dtneg
                    .
                end.
            end.
            */
        end.
    end.
end.

message "Lista Relatorio para S.P.C. ?" update sresp.
if not sresp
then return.

if opsys = "UNIX"
then varquivo = "/admcom/relat/sarq" + string(time).
else varquivo = "..\relat\sarq" + string(time). 

                                                   
/***************
output stream sarq to value(varquivo).
 
{mdadmcab.i &Saida = "printer"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = """"
            &Nom-Sis   = """SISTEMA CREDIARIO""  +
                         ""                                                "" +
                         ""                    AO SPC DE SAO JERONIMO      """
            &Tit-Rel   = """ LISTAGEM DE CLIENTES PARA INCLUSAO""  +
                         "" EM "" + string(vdata) + "" - CODIGO : 160 "" "
            &Width     = "160"
            &Form      = "with frame f-cab1"}

********************/

{mdad.i
            &Saida     = "value(varquivo)"
                        &Page-Size = "64"
                                    &Cond-Var  = "180"
                                                &Page-Line = "66"
                                                            &Nom-Rel   = ""regspcmz""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
                        &Tit-Rel   = """ LISTAGEM DE CLIENTES PARA INCLUSAO"""
                                    &Width     = "180"
                                                &Form      = "frame f-cabcab"}
                                                
disp with frame f-ini.
                                      
/****
display skip
                fill("-",140)      format "x(140)" with width 160 3 column
                                with frame fff4.
***/                                


/*********************************
for each regcan break by regcan.etbcod
                      by regcan.clinom:
    find clien      where clien.clicod     = regcan.clicod  no-lock no-error.
    find estab      where estab.etbcod     = regcan.etbcod  no-lock.

 
    /* #1 */
    do:          
        /*if clien.dtcad       = ?  or
           clien.mae         = "" or 
           clien.ciccgc      = ?  or 
           clien.ciinsc      = "" or 
           clien.endereco[1] = ""  
        then do:
            display stream sarq estab.etbcod
                    clien.clicod   label "Codigo" format ">>>>>>>>>9"
                    regcan.contnum  /* #1 */
                    clien.clinom      format "x(40)"
                    clien.endereco[1] format "x(20)" label "Endereco"
                    regcan.titdtemi 
                    clien.dtnasc            when avail clien
                    clien.numero[1]  label "Numero" when avail clien
                    regcan.vltotal  at 15   /* #1 */
                    clien.mae format "x(30)" label "Mae" when avail clien
                    clien.pai format "x(30)" label "Pai" when avail clien
                    clien.compl[1]    format "x(5)" label "Compl."
                    clien.cep[1] label "CEP" when avail clien
                    regcan.titdtven
                    clien.cidade[1] when avail clien
                               format "x(20)"  label "Cidade"
                    clien.ciccgc   when avail clien label "CPF"
                    clien.ciinsc   when avail clien label "CI"
                            with width 160 3 column with frame sff1.
        end.
        else*/ do:
            display estab.etbcod
                    clien.clicod   label "Codigo"  format ">>>>>>>>>9"
                    regcan.contnum /* #1 */ format ">>>>>>>>>9"
                    regcan.clinom  format "x(70)" label "Nome"
                    /*
                    clien.clinom      format "x(40)" when avail clien
                    */
                    clien.endereco[1] format "x(20)"
                        label "Endereco" when avail clien
                    regcan.titdtemi  format "99/99/9999"
                    clien.dtnasc   when avail clien format "99/99/9999"
                    clien.numero[1]  label "Numero" when avail clien
                    regcan.vltotal     /* #1 */
                    clien.mae format "x(30)" label "Mae" when avail clien
                    clien.pai format "x(30)" label "Pai" when avail clien
                    clien.compl[1]    format "x(5)"
                                   label "Compl." when avail clien
                    clien.cep[1] label "CEP" when avail clien
                    regcan.titdtven
                    clien.cidade[1] when avail clien
                               format "x(20)"  label "Cidade"
                    clien.ciccgc   when avail clien label "CPF"
                    clien.ciinsc   when avail clien label "CI"
                            with width 160 3 column with frame ff1.        

        end.
        
        find first xtitulo use-index iclicod
                    where 
            xtitulo.clifor = regcan.clicod and
            xtitulo.titnat = no and
            xtitulo.titnum = string(regcan.contnum)
            no-lock no-error.
    
         find first titulo use-index titnum
                      where titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.modcod = xtitulo.modcod and /* *1 */
                            titulo.etbcod = regcan.etbcod and /* #1 */
                            titulo.clifor = regcan.clicod and
                            titulo.titnum = xtitulo.titnum and
                            titulo.titdtven > regcan.titdtven and
                            titulo.titsit = "PAG" and 
                            titulo.titvlcob > 0 no-lock no-error.

        if avail titulo
        then do:
            /*if clien.dtcad       = ?  or
               clien.mae         = "" or 
               clien.ciccgc      = ?  or 
               clien.ciinsc      = "" or 
               clien.endereco[1] = ""  
            then disp stream sarq 
                    " ********** Verificar Pagamentos ********** " 
                    with frame sff2.
            else*/  disp 
                    " ********** Verificar Pagamentos ********** " 
                    with frame ff2.
        end.

        display skip
                fill("-",140)      format "x(140)" with width 160 3 column
                with frame ff4.
        /*
        display stream sarq skip
                fill("-",140)      format "x(140)" with width 160 3 column
                with frame sff4.
        */
    end.
end.
********************************/

for each tt-regcan no-lock,
    first clien      where clien.clicod     = tt-regcan.clicod  no-lock 
                        by tt-regcan.etbcod
                        by clien.clinom:

    find estab      where estab.etbcod     = tt-regcan.etbcod  no-lock.

        display tt-regcan.etbcod column-label "Fil"
                tt-regcan.clicod column-label "Codigo"  format ">>>>>>>>>9"
                tt-regcan.contnum column-label "Contrato" format ">>>>>>>>>9"
                clien.clinom  format "x(30)" column-label "Nome"
                clien.ciccgc   column-label "CPF"
                clien.dtnasc  column-label "DtNasc" format "99/99/9999"
                clien.cep[1]  column-label "CEP"
                clien.endereco[1] column-label "Endereco" format "x(20)"
                clien.numero[1]   column-label "Numero"
                clien.cidade[1]   column-label "Cidade" format "x(20)"
                clien.mae          column-label "Mae" format "x(20)"
                tt-regcan.dtneg   column-label "DtNegCre"
                with frame f-ddisp width 200 down.

end.
output close.


/*message "imprimir listagem de clientes com problema?" update sresp.
if sresp
then*/ do:
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    /*else do:
        {mrod.i}
    end.*/
end.

