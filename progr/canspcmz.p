/**************************************************************************
 Programa           : Cancela o SPC dos Clientes que estao em dia
 Nome do Programa   : CanSPC.p
 Criacao            : 01/11/1996
 Ultima Alteracao   : 01/11/1996
 #1 TP 24247636 - Ricardo - 30.04.18
 #3 Projeto Rigth Now - Ricardo - 31.07.18
 #4 - Claudir - TP 28874183
***************************************************************************/

/* #1 - helio - 05.2018 - modificado leitura tabela contrato para evitar problemas com contratos duplos 
                          nao usa mais da tabela contrato o etbcod nem o clicod  
                            */

def var vvltotal as dec. /* #1 */
def buffer xtitulo for titulo. /* #1 */
def buffer btitulo for titulo.
def buffer xestab for estab. /* #1 */

{admcab.i}

{tt-modalidade-padrao.i new}

/*#4*/
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CPN".
/*#4*/

def var vachou             as log no-undo.
def var vv1                as integer.
def var vdata              like plani.pladat initial today.
def buffer bregcan   for regcan.

message "Deletando Registros Anteriores...............".
for each bregcan:
    delete bregcan.
end.

update vdata label "Data de Referencia" colon 25 help "Cancela SPC  "
       with color white/cyan width 80 side-label row 4.

for each clispc where clispc.dtcanc = ?:

    disp clispc.clicod with 1 down frame fff centered.
    pause 0.

    vachou = no.
        for each titulo where titulo.empcod = 19 /* #1 */
                          and titulo.titnat = no /* #1 */
                          and titulo.clifor = clispc.clicod
                        no-lock:

            find first tt-modalidade-padrao where
                    tt-modalidade-padrao.modcod = titulo.modcod
                    no-lock no-error.
            if avail tt-modalidade-padrao and
               titulo.titsit = "LIB" and
               titulo.titdtven <= (vdata - 25)
            then do:
                disp titulo.titnum 
                     titulo.titpar 
                     titulo.modcod
                    with frame fff.
                pause 0.
                vachou = yes.
            end.        
        end.

    if vachou = no 
    then do:
        find clien of clispc. /* #1 */
        assign clispc.dtcanc  = vdata
               clispc.datexp  = today /* #3 */
               clien.dtspc[1] = ?.
            
        vv1 = vv1 + 1.
            /* #1 */
        find first xtitulo use-index iclicod
                    where 
            xtitulo.clifor = clispc.clicod and
            xtitulo.titnat = no and
            xtitulo.titnum = string(clispc.contnum)
            no-lock no-error.
        if avail xtitulo /* #1  */
        then do:
            /* #1 */
            find estab where estab.etbcod = xtitulo.etbcod no-lock no-error. /* #1 */
            if not avail estab
            then next.
            find clien where clien.clicod = clispc.clicod no-lock.
            
            vvltotal = 0.
            for each btitulo where 
                    btitulo.empcod = 19 and 
                    btitulo.titnat = no and 
                    btitulo.modcod = xtitulo.modcod and 
                    btitulo.etbcod = xtitulo.etbcod and 
                    btitulo.clifor = clien.clicod and 
                    btitulo.titnum = string(clispc.contnum)
                    no-lock.
                vvltotal = vvltotal + xtitulo.titvlcob.
            end.    
            
            create regcan.
            assign regcan.etbcod   = estab.etbcod
                   regcan.spcpro   = clispc.spcpro
                   regcan.clicod   = clien.clicod
                   regcan.clinom   = clien.clinom
                   regcan.munic    = estab.munic
                   regcan.contnum  = clispc.contnum
                   regcan.vltotal  = vvltotal. /* #1 */
        end.
        else do:
        
            create regcan.
            assign regcan.etbcod   = estab.etbcod
                   regcan.spcpro   = clispc.spcpro
                   regcan.clicod   = clien.clicod
                   regcan.clinom   = clien.clinom
                   regcan.munic    = estab.munic.
        
        end.
    end.

    display "Aguarde..." vdata  "Cancelando" vv1 "Cliente(s) no SPC..."
                      with no-box color red/white row 22 no-label.
    pause 0.
end.

message "Lista Relatorio ?" update sresp.
if not sresp then return.

{mdadmcab.i &Saida = "printer"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = """"
            &Nom-Sis   = """SISTEMA CREDIARIO""  +
                         ""                                                "" +
                         ""                    AO SPC DE SAO JERONIMO      """
            &Tit-Rel   = """ AVISO DE EXCLUSAO DE REGISTROS ""  +
                         "" EM "" + string(vdata) + "" - CODIGO : 160 "" "
            &Width     = "160"
            &Form      = "with frame f-cab1"}

for each regcan no-lock break by regcan.etbcod
                       by regcan.clinom:
    find clien where clien.clicod = regcan.clicod  no-lock.
    find estab where estab.etbcod = regcan.etbcod  no-lock.

    display clien.clicod       label "Codigo"
            clien.clinom       format "x(40)"
            clien.ciccgc       label "CPF"
            clien.ciinsc       label "CI"
            clien.dtnasc
            regcan.contnum
            estab.etbnom
            regcan.spcpro
            skip
            fill("-",140)      format "x(140)"
            with width 160 3 column.
end.
output close.

{mdadmcab.i &Saida = "PRINTER"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "66"
            &Nom-Rel   = """"
            &Nom-Sis   = """SISTEMA CREDIARIO"""
            &Tit-Rel   = """ PROTOCOLO DE CANCELAMENTO ""  +
                         "" EM "" + string(TODAY) "
            &Width     = "80"
            &Form      = "with frame f-cab22"}

for each regcan no-lock break by regcan.clinom :

    find clien where clien.clicod = regcan.clicod no-lock.
    find estab where estab.etbcod = regcan.etbcod no-lock.

    display clien.clicod
            clien.clinom
            regcan.spcpro label "Prot." format ">>>>9"
            regcan.contnum
            regcan.etbcod /* #1 */ (count) with width 80.
end.

display skip(3)
         "___________________________" colon 50
         skip(1)
         "RECEBIDO: _____/_____/_____" colon 50 with frame ffim22 width 80.

output close.

/* delete from regcan. */
