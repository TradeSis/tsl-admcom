/*****************************************************************************
 Programa           : Coloca todos os clientes que estao atrazados no SPC
 Programador        : Cristiano Borges Brasil
 Nome do Programa   : RegSPC.p
 Criacao            : 31/10/1996
 Ultima Alteracao   : 31/10/1996
 ***************************************************************************/

 {admcab.i}
 
 def var fila as char.
 def var varquivo as char.
 def stream sarq.
 def var vachou     as log.
 def var vv         as integer.
 def var vcidade    as char     format "x(30)".
 def var vdata      like plani.pladat  initial today.
 def stream tela.
 def var vproto     as i format ">>>>9".
 def buffer bclispc for clispc.


 def buffer bregcan   for regcan.

 for each bregcan:
    delete bregcan.
 end.

 update vdata label "Data Referencia"
 help "Registro de SPC dos vencimentos 30 dias antes da Data de Referencia"
                with width 80 color white/cyan row 4 side-label.

 find last bclispc no-lock.
 vproto = bclispc.spcpro + 1.

 output stream tela to terminal.

 vachou = no.
 for each estab no-lock :

            for each titulo use-index titdtven
                            where titulo.empcod     = wempre.empcod and
                                  titulo.titnat     = no            and
                                  titulo.modcod     = "CRE"         and
                                  titulo.titdtven   = (vdata - 30)  and
                                  titulo.etbcod     = estab.etbcod  and
                                  titulo.clifor     > 1             and
                                  titulo.titsit     <> "PAG" and
                                  titulo.titvlcob > 0 no-lock:
                    if titulo.clifor = 15
                    then next.
                    find clien where clien.clicod = titulo.clifor no-error.
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
                    pause 0.

                    vachou = yes.

                    find first clispc where clispc.clicod  = TITULO.clifor and
                                            clispc.dtcanc  = ? no-error.
                    if not avail clispc
                    then do:
                        vv = vv + 1.

                        create clispc.
                        assign clispc.clicod    = titulo.clifor
                               clispc.contnum   = int(titulo.titnum)
                               clispc.datexp    = today
                               clispc.dtneg     = vdata
                               clispc.dtcanc    = ?
                               clispc.spcpro    = vproto.
                        if avail clien
                        then assign clien.dtspc[1]   = ?.
                        find contrato where contrato.contnum =
                                            int(titulo.titnum) no-lock no-error.
                        if avail contrato
                        then do:
                             create regcan.
                             assign regcan.etbcod   = estab.etbcod
                                    regcan.clicod   = titulo.clifor.
                             if avail clien
                             then regcan.clinom   = clien.clinom.
                             assign regcan.munic    = estab.munic
                                    regcan.contnum  = contrato.contnum
                                    regcan.vltotal  = contrato.vltotal
                                    regcan.titdtemi = titulo.titdtemi
                                    regcan.titdtven = titulo.titdtven.
                        end.

                    end.

            end.
 end.

 message "Lista Relatorio para S.P.C. ? " update sresp.
 if not sresp
 then return.
                                                   
 varquivo = "..\relat\teste_leote_SPC" + string(time). 
                                                   
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


 /*********************************/

 for each regcan break by regcan.etbcod
                       by regcan.clinom:
    find clien      where clien.clicod     = regcan.clicod  no-lock no-error.
    find estab      where estab.etbcod     = regcan.etbcod  no-lock.
    find contrato   where contrato.contnum = regcan.contnum no-lock.
 
    if avail contrato
    then do:
          
        if clien.dtcad       = ?  or
           clien.mae         = "" or 
           clien.ciccgc      = ?  or 
           clien.ciinsc      = "" or 
           clien.endereco[1] = ""  
        then do:
        
            display stream sarq estab.etbcod
                    clien.clicod   label "Codigo" when avail clien
                    contrato.contnum
                    clien.clinom        format "x(40)" when avail clien
                    clien.endereco[1] format "x(20)"
                        label "Endereco" when avail clien
                    regcan.titdtemi at 15
                    clien.dtnasc            when avail clien
                    clien.numero[1]  label "Numero" when avail clien
                    contrato.vltotal  at 15
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
                            with width 160 3 column with frame sff1.
        end.
        else do:
            display estab.etbcod
                    clien.clicod   label "Codigo" when avail clien
                    contrato.contnum
                    clien.clinom        format "x(40)" when avail clien
                    clien.endereco[1] format "x(20)"
                        label "Endereco" when avail clien
                    regcan.titdtemi at 15
                    clien.dtnasc            when avail clien
                    clien.numero[1]  label "Numero" when avail clien
                    contrato.vltotal  at 15
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
        find first titulo use-index titnum
                      where titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.modcod = "CRE" and
                            titulo.etbcod = contrato.etbcod and
                            titulo.clifor = regcan.clicod and
                            titulo.titnum = string(contrato.contnum) and
                            titulo.titdtven > regcan.titdtven and
                            titulo.titsit = "PAG" and 
                            titulo.titvlcob > 0 no-lock no-error.

        if avail titulo
        then do:
              
            if clien.dtcad       = ?  or
               clien.mae         = "" or 
               clien.ciccgc      = ?  or 
               clien.ciinsc      = "" or 
               clien.endereco[1] = ""  
            then disp stream sarq 
                    " ********** Verificar Pagamentos ********** " 
                    with frame sff2.
            else  disp 
                    " ********** Verificar Pagamentos ********** " 
                    with frame ff2.

    
        end.
        
        
        display skip
                fill("-",140)      format "x(140)" with width 160 3 column
                with frame ff4.
        
        display stream sarq skip
                fill("-",140)      format "x(140)" with width 160 3 column
                with frame sff4.
                 
                
    end.
    
end.
output close.


message "imprimir listagem de clientes com problema" update sresp.
if sresp
then do:
    /**       
    if opsys = "unix"
    then os-command silent lpr value(fila + " " + varquivo).
    else os-command silent type value(varquivo) > prn.
    **/
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.




