/*****************************************************************************
 Programa           : Coloca todos os clientes que estao atrazados no SPC
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : RegSPC.p
 Criacao            : 31/10/1996
 Ultima Alteracao   : 31/10/1996
 ***************************************************************************/

/* #1 - helio - 05.2018 - modificado leitura tabela contrato para evitar problemas com contratos duplos 
                          nao usa mais da tabela contrato o etbcod nem o clicod  
                            */

def var vvltotal as dec. /* #1 */
def buffer xtitulo for titulo. /* #1 */
def buffer btitulo for titulo. /* #1 */
 {admcab.i}

 def var vdtemi like titulo.titdtemi.
 def var vdtven like titulo.titdtven.
 def var vachou     as log.
 def var vv         as integer.
 def var vcidade    as char     format "x(30)".
 def var vdata      like plani.pladat    initial today.
 def stream tela.
 def var vproto as i format ">>>>9".

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.

 def buffer bregcan   for regcan.

 for each bregcan:
    delete bregcan.
 end.

def var vdtrefini  as date initial today.
def var vdtreffim  as date initial today.
def var vdtvenini as date.
def var vdtvenfim as date.


do on error undo with width 80 color white/cyan row 4 side-label.
    update vdtrefini label "Data Referencia Inicial" colon 25
    help "Registro de SPC dos vencimentos 30 dias antes da Data de Referencia".
    update vdtreffim label "Final".

    vdtvenini = vdtrefini - 30.
    vdtvenfim = vdtreffim - 30.
    disp
        vdtvenini label "Vencimento de" colon 25
        vdtvenfim label "ate".
end.

output stream tela to terminal.

 vachou = no.
do vdata = vdtvenini to vdtvenfim: 
 for each clispc where clispc.dtneg = vdata no-lock:

    vproto = clispc.spcpro.

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
    
    find estab of titulo no-lock. /* #1 */
    
    for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = xtitulo.modcod and
                          titulo.etbcod = estab.etbcod and
                          titulo.clifor = clien.clicod and
                          titulo.titnum = xtitulo.titnum /* #1 */
                          no-lock use-index titnum:
        
        if fin.titulo.tpcontrato = "L"
        then assign v-parcela-lp = yes.
        else assign v-parcela-lp = no.
        
        /**** tirado a pedido agenda 02/03/2017                                
        if v-consulta-parcelas-LP = no
            and v-parcela-lp = yes
        then next.
                            
        if v-consulta-parcelas-LP = yes
            and v-parcela-lp = no
        then next.
        ****************/
        
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
                    btitulo.modcod = xtitulo.modcod and  /* #1 */
                    btitulo.etbcod = estab.etbcod and 
                    btitulo.clifor = clien.clicod and 
                    btitulo.titnum = string(clispc.contnum)
                    no-lock.
                vvltotal = vvltotal + xtitulo.titvlcob.
            end.    
    
    create regcan. 
    assign regcan.etbcod   = estab.etbcod
           regcan.clicod   = clien.clicod
           regcan.clinom   = clien.clinom
           regcan.munic    = estab.munic
           regcan.contnum  = int(xtitulo.titnum) /* #1 */
           regcan.vltotal  = vvltotal /* #1 */
           regcan.titdtemi = vdtemi
           regcan.titdtven = (vdata - 60).
 end.
end.

 message "Lista Relatorio para S.P.C. ? " update sresp.
 if not sresp
 then return.

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




 for each regcan break by regcan.etbcod
                       by regcan.clinom:
    find clien      where clien.clicod     = regcan.clicod  no-lock no-error.
    find estab      where estab.etbcod     = regcan.etbcod  no-lock.


        do:


        display estab.etbcod
                clien.clicod                        label "Codigo"
                regcan.contnum
                clien.clinom        format "x(40)"
                clien.endereco[1] format "x(20)"  label "Endereco"
                regcan.titdtemi at 15
                clien.dtnasc
                clien.numero[1]  label "Numero"
                regcan.vltotal  at 15  /* #1 */
                clien.mae format "x(30)" label "Mae" when avail clien
                clien.pai format "x(30)" label "Pai" when avail clien

                clien.compl[1]    format "x(5)"   label "Compl."
                clien.cep[1]                        label "CEP"
                regcan.titdtven
                clien.cidade[1]     format "x(20)"  label "Cidade"
                clien.ciccgc                        label "CPF"
                clien.ciinsc                        label "CI"
                with width 160 3 column with frame ff1.

        find first titulo use-index titnum
                      where titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.etbcod = regcan.etbcod and /* #1 */
                            titulo.clifor = regcan.clicod and /* #1 */
                            titulo.titnum = string(regcan.contnum) and
                            titulo.titdtven > regcan.titdtven and
                            titulo.titsit = "PAG" 
            no-lock no-error.

        if avail titulo
        then disp " ********** Verificar Pagamentos ********** " with frame ff2.

        display skip
                fill("-",140)      format "x(140)" with width 160 3 column
                with frame ff4.

        end.
      /*
        if last-of(regcan.munic)
        then page.                                          
      */
end.
output close.

 {mdadmcab.i &Saida = "PRINTER"
             &Page-Size = "64"
             &Cond-Var  = "80"
             &Page-Line = "66"
             &Nom-Rel   = """"
             &Nom-Sis   = """SISTEMA CREDIARIO"""
             &Tit-Rel   = """ PROTOCOLO "" + string(vproto) +
                          "" DE NEGATIVACAO ""  +
                          "" EM "" + string(TODAY) "
             &Width     = "80"
             &Form      = "with frame f-cab2"}

 for each regcan break by regcan.clinom:
    find clien      where clien.clicod     = regcan.clicod  no-lock.
    find estab      where estab.etbcod     = regcan.etbcod  no-lock.

    display clien.clicod
            clien.clinom
            regcan.contnum
            regcan.titdtven
            regcan.etbcod with width 80.
 end.

 display skip(2)
         "DECLARAMOS QUE OS CLIENTES ACIMA FORAM DEVIDAMENTE NOTIFICADOS."
         COLON 7
         "___________________________" colon 10
         "___________________________" colon 50
         skip(1)
         "          _____/_____/_____" colon 10
         "RECEBIDO: _____/_____/_____" colon 50
         with frame ffim2 width 80.

 output close.

/* delete from regcan. */
