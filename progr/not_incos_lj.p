/*  not_etiqestin.p
 NAO ENVIAR PARA AS LOJAS
*/

{admcab.i}

def input  parameter par-etopecod   like etiqope.etopecod.
def output parameter par-rec-asstec as recid.

def var v-imei-cel-aux  as character no-undo.
def var v-cel-doa-aux   as logical format "Sim/Nao" no-undo.
def var vconfinado      as log format "Sim/Nao".
def var vleconfinado    as log.
def var vproacessorio   as int.

def temp-table tt-asstec like asstec.

def var vclicod   like asstec.clicod.
def var vprocod   like asstec.procod.
def var vnroserie like asstec.apaser.
def var vdefeito  like asstec.defeito.
def var vprodesc  like produ.pronom.
def var vnomecli  like clien.clinom.
def var vmotivo   as char.
def var vobstroca as char.
def var vtabini as char.

def buffer basstec for asstec.
def buffer bprodu  for produ.
def buffer setor   for clase.
def buffer grupo   for clase.
def buffer classe  for clase.
def buffer sclasse for clase.

find estab where estab.etbcod = setbcod no-lock.

run le_tabini.p (0, 0, "SSC - ACESSORIO", OUTPUT vtabini).
vproacessorio = int(vtabini).

form
    tt-asstec.etbcod colon 11 label "Filial"
    tt-asstec.oscod  colon 40
    asstec.datexp

    tt-asstec.pladat colon 11 label "Data Venda"
                              validate (tt-asstec.pladat <> ?, "")
    tt-asstec.planum colon 40 label "Numero Venda"
                              validate (tt-asstec.planum > 0, "")
        tt-asstec.serie label "Serie Venda"
                              validate (tt-asstec.serie <> ?, "")
    tt-asstec.plaetb label "Filial Venda"
    plani.crecod label "PC"

    tt-asstec.clicod colon 11 label "Cliente" format ">>>>>>>>>9"
                     validate(true,"")
    clien.clinom     format "x(30)" no-label
    asstec_aux.valor_campo no-label format "x(20)"
    
    tt-asstec.procod colon 11
    produ.pronom     no-label format "x(30)"
    vconfinado       colon 67 label "Confinado?"

    tt-asstec.apaser format "x(15)" colon 11
    v-imei-cel-aux   colon 45 label "IMEI Cel." format "x(20)"
    v-cel-doa-aux    label "DOA" format "Sim/Nao"

    tt-asstec.proobs  colon 11 label "Obs.Prod."
    tt-asstec.defeito colon 11
    tt-asstec.reincid colon 12
    tt-asstec.osobs   colon 11 label "Obs.OS"

    tt-asstec.forcod colon 11 label "Cod.Assis"
    forne.fornom     no-label  format "x(20)"
    forne.forfone    label "Fone"

    asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
    asstec.dtenvass colon 60 label "Dt.Envio Assistencia" 
    asstec.dtretass colon 25 label "Dt.Retirada Assistencia"
    asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 

    with frame f-etiq overlay row 5 width 80 side-labels
         title "Ordem de Servico " + etiqope.etopenom.

    find etiqope where etiqope.etopecod = par-etopecod no-lock.
    
    /* copiado de asstec_lj.p */

    def var vcha-senha      as character.
    DEF VAR vgarbiz AS LOG INIT YES.

    create tt-asstec.    
    assign
        tt-asstec.etopecod = etiqope.etopecod
        tt-asstec.etbcod   = setbcod.                

do with frame f-etiq.

    display tt-asstec.etbcod.

    if etiqope.sigla = "CLI"
    then do on error undo /*, retry*/:
        update
            tt-asstec.pladat
            tt-asstec.planum
            tt-asstec.serie
            tt-asstec.plaetb label "Filial Venda".
        vgarbiz = no.
    
        find first plani where plani.etbcod = tt-asstec.plaetb and
                               plani.emite  = tt-asstec.plaetb and
                               plani.serie  = tt-asstec.serie  and
                               plani.numero = tt-asstec.planum and
                               plani.pladat = tt-asstec.pladat
                         no-lock no-error.
        if not avail plani
        then do:
            message "Venda nao encontrada" view-as alert-box.
            undo /*, retry*/.
        end.
        if plani.movtdc <> 5 and
           plani.movtdc <> 81
        then do.
            message "NF-e nao e de venda" view-as alert-box.
            undo.
        end.

        find clien where clien.clicod = plani.desti no-lock.
        tt-asstec.clicod = clien.clicod.
        disp tt-asstec.clicod.
        if tt-asstec.clicod = 1  /*500*/ /***10000***/ or
           tt-asstec.clicod = 10497765 /*** 40309 ***/
        then do.
            update tt-asstec.clicod.
            if tt-asstec.clicod = 1 /*500*/ /***10000***/ or
               tt-asstec.clicod = 10497765 /*** 40309 ***/
            then do:
                message "Cliente Bloqueado para abertura de OS"
                        view-as alert-box.
                undo /*, retry*/.
            end.
            find clien where clien.clicod = tt-asstec.clicod no-lock no-error.
            if not avail clien or
               trim(clien.clinom) = ""
            then do.
                message "Cliente invalido" view-as alert-box.
                undo.
            end.
        end.

        display clien.clinom.
    end.

    do on error undo.
        update tt-asstec.procod.               
        find produ where produ.procod = tt-asstec.procod no-lock no-error.
        if not avail produ
        then do.
            message "Produto invalido" view-as alert-box.
            undo /*,retry*/.
        end.
    end.
    display produ.pronom.

    if etiqope.sigla = "EST"
    then do ON ERROR UNDO /*, RETRY*/:
        if setbcod <> 65
        then do.
        /*repeat on error undo , retry:*/
            pause 0.
            message "Entre em contato com a Assistência Técnica"
                 "e solicite uma senha".

            update vcha-senha format "x(25)" no-label
                                     with frame f-inf-senha centered overlay
                                     row 12 title "Informe a senha" width 30.
            sresp = no.
            run p-verifica-senha (input vcha-senha,
                                  input tt-asstec.procod,
                                  output sresp).
/*
            if sresp
            then leave. /*, retry*/.
            if keyfunction(lastkey) = "END-ERROR"
            then leave.                           
*/
        end.
        if not sresp or keyfunction(lastkey) = "END-ERROR"
        THEN UNDO /*, RETRY*/.
    end.
    else do.
        if produ.catcod <> 41 and vproacessorio <> vprocod
        then do.
            find first tabaux where tabaux.tabela = "PLANOBIZ" and
                                    tabaux.valor_campo = string(plani.pedcod)
                              no-lock no-error.
            if avail tabaux
            then do:
                disp plani.crecod.
                vgarbiz = yes.
                for each titulo where    titulo.clifor = clien.clicod
                                     and titulo.titsit = "LIB"
                                     and titulo.modcod = "CRE"
                            no-lock by titulo.titpar:
                    if today - titulo.titdtven > 30 /*06/03/2012*/
                    then do:
                        vgarbiz = no.
                        leave.
                    end.
                    else vgarbiz = yes.
                end.
                if vgarbiz
                then message "GARANTIA PLANO BI$" view-as alert-box.
            end.
        end.

        vprocod = tt-asstec.procod.
        if vproacessorio = vprocod
        then do on error undo.
            vprocod = 0.
            update vprocod label "Produto constate no cupom"
                   with frame f-acessorio side-label centered.
            find bprodu where bprodu.procod = vprocod no-lock no-error.
            if not avail bprodu
            then do.
                message "Produto invalido (cupom)" view-as alert-box.
                undo.
            end.
            disp bprodu.pronom no-label with frame f-acessorio.
        end.

        /* Terceiros */
        find first movim where movim.etbcod = plani.etbcod
                           and movim.placod = plani.placod
                           and movim.movtdc = plani.movtdc
                           and movim.movdat = plani.pladat
                           and movim.procod = vprocod
                         no-lock no-error.
        if not avail movim
        then do.
            message "Produto nao esta na nota informada" view-as alert-box.
            undo.
        end.
    end.

    vleconfinado = yes.
    vconfinado   = yes.
    find sClasse where sClasse.clacod = produ.clacod no-lock no-error.
    if avail sClasse
    then do.
        find Classe where Classe.clacod = sClasse.clasup no-lock no-error.
        if avail classe
        then do.
            find grupo where grupo.clacod = Classe.clasup no-lock no-error.
            if avail grupo
            then do.
                find setor where setor.clacod = grupo.clasup no-lock no-error.
                if avail setor
                then do.
                    vleconfinado = no.
                    if setor.clacod = 128000000 /* Tecnologia  */ or
                       setor.clacod = 129000000 /* telefonia celular */ or
                       setor.clacod = 234080000 /* relogios */
                    then vconfinado = yes.
                    else vconfinado = no.
                end.
            end.
        end.
    end.

    do on error undo with frame f-etiq:
        update vconfinado when vleconfinado.
        if vconfinado
        then tt-asstec.serie = "S".
        else tt-asstec.serie = "N".

        update tt-asstec.apaser.
                
        assign v-imei-cel-aux = ""
            v-cel-doa-aux  = no.
        if can-find(first plaviv where
                                  plaviv.procod = tt-asstec.procod and
                                  plaviv.exportado)
        then do:
            find first tbprice where 
                                tbprice.etb_venda  = tt-asstec.etbcod
                            and tbprice.nota_venda = tt-asstec.planum
                            and tbprice.data_venda = tt-asstec.pladat
                                         no-lock no-error.
            if available tbprice
            then
                assign v-imei-cel-aux = tbprice.serial.

            bloco_inclui_imei:
            repeat with frame f-etiq:    
                update v-imei-cel-aux.
                if v-imei-cel-aux = ""
                then do:
                    message "O campo IMEI Cel.tem preenchimento obrigatorio".
                    undo,retry.
                end.
                else leave bloco_inclui_imei.
            end.
        end.

        if (today - 9) <= tt-asstec.pladat
        then update v-cel-doa-aux.
        else disp v-cel-doa-aux.
    end.

    update tt-asstec.proobs
        tt-asstec.defeito
        tt-asstec.reincid
        tt-asstec.osobs.

    do transaction:
        create asstec.  

        find last basstec no-lock no-error.
        if avail basstec 
        then asstec.oscod = basstec.oscod + 1.
        else asstec.oscod = 1. 

        display asstec.oscod @ tt-asstec.oscod.

        assign
            asstec.etbcod = tt-asstec.etbcod
            asstec.forcod = tt-asstec.forcod
            asstec.procod = tt-asstec.procod
            asstec.apaser = tt-asstec.apaser
            asstec.clicod = tt-asstec.clicod
            asstec.plaetb = tt-asstec.plaetb
            asstec.pladat = tt-asstec.pladat
            asstec.planum = tt-asstec.planum
            asstec.serie  = tt-asstec.serie
            asstec.defeito = tt-asstec.defeito
            asstec.reincid = tt-asstec.reincid
            asstec.osobs  = tt-asstec.osobs
            asstec.datexp = today
            asstec.etbcodatu = setbcod
            asstec.etopecod  = par-etopecod.

        if v-imei-cel-aux <> ""
        then asstec.proobs = tt-asstec.proobs
                                         + "|IMEI=" + v-imei-cel-aux
                                         + "|DOA=" + string(v-cel-doa-aux).
        else asstec.proobs = tt-asstec.proobs.
        if vgarbiz
        then do:
            find first asstec_aux where
                                   asstec_aux.oscod = asstec.oscod and
                                   asstec_aux.nome_campo = "REGISTRO-TROCA"
                        no-error.
            if not avail asstec_aux
            then do:
                create asstec_aux.
                assign
                    asstec_aux.oscod = asstec.oscod
                    asstec_aux.nome_campo = "REGISTRO-TROCA"
                    asstec_aux.data_campo = today.
            end.
            asstec_aux.valor_campo = "GARANTIA PLANO BI$".
 
            find current asstec_aux no-lock.
        end.

        if vprocod > 0 and vprocod <> tt-asstec.procod
        then do on error undo.
            create asstec_aux.
            assign
                asstec_aux.oscod       = asstec.oscod
                asstec_aux.nome_campo  = "PRODUTO"
                asstec_aux.data_campo  = today
                asstec_aux.valor_campo = string(vprocod).
        end.
        
        par-rec-asstec = recid(asstec).
        message "OS criada:" asstec.oscod view-as alert-box.
    end.    

end.

procedure p-verifica-senha:

    def input  parameter ipsenha  as character.
    def input  parameter ipprocod as integer.
    def output parameter opresp   as logical.
    
    assign opresp = no.
    hide message no-pause.    
    find first tabaux where tabaux.Tabela = string(setbcod) + string(ipprocod)
                            no-lock no-error.
    if not avail tabaux
    then do:
        message "Senha inválida" 
            "Entre em contato com a Assistência Técnica e solicite uma senha"
            view-as alert-box.
        return.
    end.
    
    if tabaux.Valor_Campo <> ipsenha
    then do:
        message "Senha incorreta, digite novamente." view-as alert-box.
        return.
    end.
    
    if tabaux.datexp < today - 1
    then do:
        message "Senha expirada, Solicite uma nova senha a Assistência Técnica".
        return.
    end.
    
    assign opresp = yes.

end procedure.

