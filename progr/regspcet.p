/*****************************************************************************
 Programa           : Coloca todos os clientes que estao atrazados no SPC
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : RegSPC.p
 Criacao            : 31/10/1996
 Ultima Alteracao   : 31/10/1996
 ***************************************************************************/

 {admcab.i}

/* #1 - helio - 05.2018 - modificado leitura tabela contrato para evitar problemas com contratos duplos 
                          nao usa mais da tabela contrato o etbcod nem o clicod  
                            */

def var vvltotal as dec. /* #1 */
def buffer xtitulo for titulo. /* #1 */
def buffer btitulo for titulo . /* #1 */



def var vini as date format "99/99/99" label "Data Inicial".
def var vi as int.
def var vfim as date format "99/99/99" label  "Data Final".
def var diaini as int format ">>9" label "Dias Inicial".
def var diafim as int format ">>9" label "Dias Final".
def var vtotal      as char  extent 8 format "x(10)".
def var vcontrato like titulo.titnum.
def var vcli    like clien.clicod.
def var vclicod like clien.clicod  extent 2.
def var vclinom like clien.clinom format "x(25)"  extent 2.
def var vtitpar like titulo.titpar extent 2.
def var vtitnum like titulo.titnum format "x(7)" extent 2.
def var vnumero like clien.numero  extent 2 .
def var vendereco like clien.endereco format "x(32)" extent 2 .
def var vcep      like clien.cep extent 2 .
def var vcompl  like clien.compl extent 2.
def var vetbcod like titulo.etbcod extent 2 .
def var vcidade like clien.cidade format "x(12)" extent 2.
def var vtitvlpag like titulo.titvlpag extent 2 .
def var vtitdtven like titulo.titdtven extent 2 .
def var n-etiq  as int.
def var wetbcod like estab.etbcod.


def var t as i.
def var i as int.
def var v as i.

 def var vdtemi like titulo.titdtemi.
 def var vdtven like titulo.titdtven.
 def var vachou     as log.
 def var vv         as integer.
 def var vdata      as date     initial today.
 def stream tela.


 def buffer bregcan   for regcan.

 for each bregcan:
    delete bregcan.
 end.

 update vdata label "Data Referencia"
                with width 80 color white/cyan row 4 side-label.


 output stream tela to terminal.

 vachou = no.

 for each clispc where clispc.dtneg = vdata no-lock:

    disp stream tela clispc.clicod clispc.dtneg with 1 down.
    pause 0.

    if dtcanc <> ?
    then next.

    find clien where clien.clicod = clispc.clicod no-lock.

            /* #1 */
        find first xtitulo use-index iclicod
                    where 
            xtitulo.clifor = clispc.clicod and
            xtitulo.titnat = no and
            xtitulo.titnum = string(clispc.contnum)
            no-lock no-error.
        if not avail xtitulo
        then next.

        find estab of xtitulo no-lock. /* #1 */


    for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.etbcod = estab.etbcod and
                          titulo.clifor = clien.clicod and
                          titulo.titnum = xtitulo.titnum /* #1 */
                          no-lock
                          use-index titnum:
        if titulo.titsit = "LIB"
        then do:
            vdtemi = titulo.titdtemi.
            vdtven = titulo.titdtven.
            leave.
        end.
    end.
            
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
                                    regcan.clicod   = clien.clicod
                                    regcan.clinom   = clien.clinom
                                    regcan.munic    = estab.munic
                                    regcan.contnum  = int(xtitulo.titnum) /* #1 */
                                    regcan.vltotal  = vvltotal /* #1 */
                                    regcan.titdtemi = vdtemi
                                    regcan.titdtven = (vdata - 50).
 end.

 message "Lista Etiquetas para Aviso do S.P.C. ? " update sresp.
 if not sresp
 then return.

 output to printer page-size 0.

 vcontrato = "".
 vcli = 0.
 vi = 0.

 for each regcan break by regcan.etbcod
                       by regcan.clinom:
    find clien      where clien.clicod     = regcan.clicod  no-lock.
    find estab      where estab.etbcod     = regcan.etbcod  no-lock.

    vi = vi + 1.
    assign
            vetbcod[vi] = regcan.etbcod /* #1 */
        /*  vtitdtven[vi] = titulo.titdtven */
            vclicod[vi] = regcan.clicod /* #1 */
            vtitnum[vi] = string(regcan.contnum) /* 31 */
            vclinom[vi] = clien.clinom
            vendereco[vi] = trim(clien.endereco[1] + ","
                                       + string(clien.numero[1])
                                       + " - " +
                                       (if clien.compl[1] = ?
                                        then ""
                                        else string(clien.compl[1])))
            vcep[vi] = cep[1]
            vcidade[vi] = cidade[1].

    if vi = 2
    then do:
        put
                "Fil: " at 1  vetbcod[1] /* vtitdtven[1] at 20 */
                "Fil: " at 37 vetbcod[2] /* vtitdtven[2] at 56 */ skip
                "Cta: " at 1  vclicod[1] "Ctr: " at 20 vtitnum[1]
                "Cta: " at 37 vclicod[2] "Ctr: " at 56 vtitnum[2] skip
                vclinom[1] at 1
                vclinom[2] at 37 skip
                vendereco[1] at 1
                vendereco[2] at 37 skip
                "CEP: " at 1 vcep[1]  vcidade[1]   at 20
                "CEP: " at 37 vcep[2] vcidade[2]   at 56 skip(1).
        assign
            vetbcod[vi] = 0
            vtitdtven[vi] = ?
            vclicod[vi] = 0
            vtitnum[vi] = ""
            vclinom[vi] = ""
            vendereco[vi] = ""
            vcep[vi] = ""
            vcidade[vi] = "".
            vi = 0.
    end.
    vcli = titulo.clifor.
end.
    put
                "Fil: " at 1  vetbcod[1] /* vtitdtven[1] at 20 */
                "Fil: " at 37 vetbcod[2] /* vtitdtven[2] at 56 */ skip
                "Cta: " at 1  vclicod[1] "Ctr: " at 20 vtitnum[1]
                "Cta: " at 37 vclicod[2] "Ctr: " at 56 vtitnum[2] skip
                vclinom[1] at 1
                vclinom[2] at 37 skip
                vendereco[1] at 1
                vendereco[2] at 37 skip
                "CEP: " at 1 vcep[1]  vcidade[1]   at 20
                "CEP: " at 37 vcep[2] vcidade[2]   at 56 skip(1).

    output  close.
    message "Emissao de Etiquetas p/ Cobranca encerrada.".
