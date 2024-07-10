/*****************************************************************************
 Programa           : Cancela o SPC dos Clientes que estao em dia
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : CanSPC.p
 Criacao            : 01/11/1996
 Ultima Alteracao   : 01/11/1996
 ***************************************************************************/

{admcab.i}


/* #1 - helio - 05.2018 - modificado leitura tabela contrato para evitar problemas com contratos duplos 
                          nao usa mais da tabela contrato o etbcod nem o clicod  
                            */

def var vvltotal as dec. /* #1 */
def buffer xtitulo for titulo. /* #1 */
def buffer btitulo for titulo. /* #1 */


def var varquivo as char.
def var vachou             as log                                  no-undo.
def var vv1                as integer.
def var vdata              like plani.pladat  initial today.
def var vcidade            as char     format "x(50)".
def buffer bregcan         for regcan.

for each bregcan:
    delete bregcan.
end.

 update vdata label "Data de Referencia"
 help "Cancela SPC  "
                with color white/cyan width 80 side-label row 4.

for each clispc where clispc.dtcanc = vdata no-lock:

    vv1 = vv1 + 1.

    find clien of clispc no-lock.

    find first xtitulo use-index iclicod
                    where 
        xtitulo.clifor = clispc.clicod and
        xtitulo.titnat = no and
        xtitulo.modcod = "CRE" and
        xtitulo.titnum = string(clispc.contnum)
        no-lock no-error.
    
    if avail xtitulo /* #1 contrato */
    then do: 
        find estab where estab.etbcod = xtitulo.etbcod no-lock. /* #1 */
        vvltotal = 0.
            for each btitulo where 
                    btitulo.empcod = 19 and 
                    btitulo.titnat = no and 
                    btitulo.modcod = xtitulo.modcod and 
                    btitulo.etbcod = estab.etbcod and 
                    btitulo.clifor = clien.clicod and 
                    btitulo.titnum = string(clispc.contnum)
                    no-lock.
                vvltotal = vvltotal + btitulo.titvlcob.
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
        assign regcan.spcpro   = clispc.spcpro
               regcan.clicod   = clien.clicod
               regcan.clinom   = clien.clinom.
    end.
    

    display "Aguarde..." vdata  "Cancelando" vv1 "Cliente(s) no SPC..."
                      with no-box color red/white row 21 no-label frame f-xx.
    pause 0.
end.

 message "Lista Relatorio ?" update sresp.
 if not sresp then return.

 varquivo = "..\relat\canspc" + string(time).

 {mdad.i &Saida = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "160"
         &Page-Line = "66"
         &Nom-Rel   = """"
         &Nom-Sis   = """SISTEMA CREDIARIO"""
         &Tit-Rel   = """EXCLUSAO DE REGISTROS ""  +
                       "" EM "" + string(vdata)"
         &Width     = "160"
         &Form      = "with frame f-cab1"}


 for each regcan break by regcan.etbcod
                       by regcan.clinom:
 
    find clien      where clien.clicod     = regcan.clicod  no-lock no-error.
    find estab      where estab.etbcod     = regcan.etbcod  no-lock no-error.
    
    display clien.clicod                        label "Codigo"
            clien.clinom        format "x(40)"
            clien.ciccgc                        label "CPF"
            clien.ciinsc                        label "CI"
            clien.dtnasc format "99/99/9999"
            regcan.contnum 
            estab.etbnom when avail estab
            regcan.spcpro
            skip fill("-",140)      format "x(140)" with width 160 3 column.
 
 end.

 output close.
 
 {mrod.i}

 varquivo = "..\relat\prot" + string(time).
 
 {mdad.i &Saida     = "value(varquivo)"
         &Page-Size = "64"
         &Cond-Var  = "80"
         &Page-Line = "66"
         &Nom-Rel   = ""prot""
         &Nom-Sis   = """SISTEMA CREDIARIO"""
         &Tit-Rel   = """ PROTOCOLO DE CANCELAMENTO ""  +
                       "" EM "" + string(TODAY)"
         &Width     = "80"
         &Form      = "with frame f-cab2"}

 for each regcan break by regcan.clinom:

    find clien      where clien.clicod     = regcan.clicod  no-lock no-error.

    display clien.clicod (count)
            clien.clinom
            regcan.spcpro label "Prot." format ">>>>9"
            regcan.contnum /* #1 */
            regcan.etbcod /* #1 */
            with width 80.
 end.

display skip(3)
        "___________________________" colon 50
        skip(1)
        "RECEBIDO: _____/_____/_____" colon 50 with frame ffim2 width 80.

output close.

{mrod.i}



