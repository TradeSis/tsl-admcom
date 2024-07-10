    /*  not_etiqestin.p */
{admcab.i}

def input-output parameter par-rec-asstec as recid.

def var v-imei-cel-aux  as character no-undo.
def var v-cel-doa-aux   as logical format "Sim/Nao" no-undo.
def var fil-venda       like estab.etbcod.
def var vconfinado      as log format "Sim/Nao".
def temp-table tt-asstec like asstec.

def buffer o-asstec_aux for asstec_aux.
def buffer p-asstec_aux for asstec_aux.

/*D*
/* Luciane - 14557 - 21/03/2007 */
def var vprazoent as date format "99/99/9999" init ?.

def var vfuncod like func.funcod.
*D*/
def var par-etopecod  like etiqope.etopecod.
def var vclicod   like asstec.clicod.
def var vnroserie like asstec.apaser.
/*D*
def var vdtorcam  like etiqest.dtorcam.
def var vvlrorcam like etiqest.vlrorcam.
*D*/
def var vdefeito  like asstec.defeito.
def var vprodesc  like produ.pronom.
def var vnomecli  like clien.clinom.
def var vmotivo   as char.
def var vobstroca as char.

def buffer basstec    for asstec.
def buffer for-clifor for forne.
def buffer atu-estab  for estab.
/*D*
def buffer atu-clifor for clifor.
def buffer bplani     for plani.
*D*/

/*D*
def NEW shared temp-table ttmovim          
    field recmovim     as recid            
    field procod       like movim.procod   
    field movpc        like movim.movpc    
    field movseq       like movim.movseq   
    field movqtm       like movim.movqtm   
    field movacf       like movim.movacf   
    field movdesc      like movim.movdes   
    field movicms      like movim.movicms  
    field movipi       like movim.movipi   
    field movsubst     like movim.movsubst 
    field movalicms    like movim.movalicms
    field movalipi     like movim.movalipi 
    field funcod       like movim.funcod. 

def NEW shared temp-table ttmovimdad            
    field recmovim     as recid                 
    field campo        like movimdad.campo      
    field descricao    like movimdad.descricao. 
                                                           
def NEW shared temp-table ttplanidad            
    field etbcod       like planidad.etbcod     
    field placod       like planidad.placod     
    field campo        like planidad.campo      
    field descricao    like planidad.descricao. 
*D*/

def var esqpos2         as int.
def var esqcom2         as char format "x(12)" extent 6
            initial ["Sequencia",
                     "Altera",
                     "Dados Adic",
                     "Reg.Troca",
                     "Imprime OS",
                     "Operacoes"].

form
    esqcom2                        
    with frame f-com2 row screen-lines no-labels no-box column 2 overlay.

find estab where estab.etbcod = setbcod no-lock.
if estab.etbnom begins "DREBES-FIL"
then do.
    esqcom2[2] = "".
    find first etiqpla of asstec no-lock no-error.
    if avail etiqpla
    then esqcom2[6] = "".
end.

form
    tt-asstec.etbcod colon 11 label "Filial"
    tt-asstec.oscod  colon 40
    asstec.datexp

    tt-asstec.pladat colon 11 label "Data Venda"
                              validate (tt-asstec.pladat <> ?, "")
    tt-asstec.planum colon 40 label "Numero Venda"
                              validate (tt-asstec.planum > 0, "")
    fil-venda label "Filial Venda"

    tt-asstec.clicod colon 11 label "Cliente" format ">>>>>>>>>9"
                     validate(true,"")
    clien.clinom     format "x(30)" no-label
    asstec_aux.valor_campo no-label format "x(20)"
    
    tt-asstec.procod colon 11
    com.produ.pronom     no-label format "x(30)"
    vconfinado       colon 67 label "Confinado?"

    tt-asstec.apaser format "x(15)" colon 11
    v-imei-cel-aux   colon 45 label "IMEI Cel." format "x(20)"
    v-cel-doa-aux    label "DOA" format "Sim/Nao"

    tt-asstec.proobs  colon 11 label "Obs.Prod."
    tt-asstec.defeito colon 11
    tt-asstec.reincid /*colon 67*/

    p-asstec_aux.valor_campo label "Produto constate no cupom" format "x(10)"
    
    tt-asstec.osobs   colon 11 label "Obs.OS"
    o-asstec_aux.valor_campo colon 11 format "x(60)" label "Obs.SSC"

    tt-asstec.forcod colon 11 label "Cod.Assis"
    forne.fornom     no-label  format "x(20)"
    forne.forfone    label "Fone"

    asstec.dtentdep colon 25 label "Dt.Entrada Deposito"
    asstec.dtenvass colon 60 label "Dt.Envio Assistencia" 
    asstec.dtretass colon 25 label "Dt.Retirada Assistencia"
    asstec.dtenvfil colon 60 label "Dt.Envio para Filial" 

    atu-estab.etbcod            colon 11 label "Loj Atual"
    atu-estab.etbnom            no-label

    etiqmov.etmovnom            colon 11 label "Ultima Seq"
    asstec.nftnum

    with frame f-etiq overlay row 4 width 80 side-labels
         title "Ordem de Servico " + etiqope.etopenom.

if par-rec-asstec = ? /* Inclusao */
then do on error undo.
    find estab where estab.etbcod = setbcod no-lock.

    if estab.etbnom begins "DREBES-FIL"
    then do.
        message "Realizar a inclusao no acesso remoto" view-as alert-box.
        leave.
    end.

    if estab.etbnom begins "DREBES-FIL"
    then run selope (output par-etopecod).
    else par-etopecod = 1. /* EST */
    if par-etopecod = ?
    then leave.

    find etiqope where etiqope.etopecod = par-etopecod no-lock.

    if estab.etbnom begins "DREBES-FIL"
    then run inclui-os-loja.
    else run inclui-os-matriz.
end.

/***
run fetiq.
***/

if par-rec-asstec <> ?
then do with frame f-etiq on error undo.
/*D*
    run not_etqauttroca.p (recid(asstec)).
*D*/
    find asstec where recid(asstec) = par-rec-asstec no-lock.
    if asstec.dtsaida <> ?
    then assign
            esqcom2[2] = ""
            esqcom2[4] = ""
            esqcom2[6] = "".
/*D*
    if westab.etbcat = "LOJA"
    then do.
        assign
            esqcom2[6] = "".
        run agil/webletiqest.p (etiqest.etbcod, etiqest.oscod).
    end.    
    hide message no-pause. 
*D*/

    repeat:
        run fetiq.    
        disp esqcom2 with frame f-com2.
        choose field esqcom2 with frame f-com2.
        esqpos2 = frame-index.
        hide frame f-com2  no-pause.
        if esqcom2[esqpos2] = "Sequencia"
        then run not_cdetiqpla.p (par-rec-asstec). 
        else if esqcom2[esqpos2] = "Altera"
        then run altera.
        else if esqcom2[esqpos2] = "Dados Adic"
        then run not_etiqestdad.p (recid(asstec)).
        else if esqcom2[esqpos2] = "Imprime OS"
        then run not_etiqestrel.p (par-rec-asstec).
        else if esqcom2[esqpos2] = "Operacoes"
        then run operacoes.
        else if esqcom2[esqpos2]= "Reg.Troca"
        then run reg-troca.p (asstec.oscod).
    end.
    hide frame f-com2 no-pause.
end.

hide frame f-etiq no-pause.


procedure selope.
    {setbrw.i}

    def output parameter par-etiqope like etiqope.etopecod.

    par-etiqope = ?.
    form with frame f-linha overlay.

    clear frame f-linha all.
    assign a-seerec = ?.
    assign a-seeid  = -1  
           a-recid  = -1.

    {sklcls.i
        &color  = withe
        &color1 = brown
        &file   = etiqope 
        &noncharacter = /* 
        &ofield = etiqope.etopenom
        &cfield = etiqope.etopecod
        &where  = "etiqope.etopecod < 100"
        &LockType = "no-lock"
        &form   = "frame f-linha 10 down row 5 no-label 
                     title "" TIPOS DE OPERACAO """}. 
    if keyfunction(lastkey) = "end-error"
    then do.
        hide frame f-linha no-pause.
        leave.
    end.    
    find etiqope where recid(etiqope) = a-seerec[frame-line(f-linha)] 
                 no-lock no-error.
    
    par-etiqope = if avail etiqope
                 then etiqope.etopecod
                 else ?.
    hide frame f-linha no-pause.
end procedure.


procedure fetiq.

    def var v-proobs-aux as char.
    def var vetmovnom like etiqmov.etmovnom.

    find asstec where recid(asstec) = par-rec-asstec no-lock.

    find etiqope of asstec no-lock. 
    find produ of asstec no-lock. 
    find clien where clien.clicod = asstec.clicod no-lock no-error.

    find first asstec_aux where asstec_aux.oscod = asstec.oscod and
                              asstec_aux.nome_campo = "REGISTRO-TROCA"
                       no-lock no-error.
    if avail asstec_aux
    then disp asstec_aux.valor_campo with frame f-etiq.

    find o-asstec_aux of asstec
                      where o-asstec_aux.nome_campo = "ObsSSC1"
                      no-lock no-error.
    disp o-asstec_aux.valor_campo when avail o-asstec_aux with frame f-etiq.

    find p-asstec_aux of asstec
                      where p-asstec_aux.nome_campo = "Produto"
                      no-lock no-error.
    disp p-asstec_aux.valor_campo when avail p-asstec_aux with frame f-etiq.

    if acha("IMEI",asstec.proobs) <> ""
    then do.
        v-cel-doa-aux = (acha("DOA",asstec.proobs) = "yes").
        v-proobs-aux =  replace(asstec.proobs,"|DOA=" + 
                                trim(string(v-cel-doa-aux,"yes/no")),"").
        v-imei-cel-aux = acha("IMEI",asstec.proobs).
        v-proobs-aux = replace(v-proobs-aux,"|IMEI=" + v-imei-cel-aux,"").
    end.
    else v-proobs-aux = asstec.proobs.

        assign
            vnroserie  = asstec.apaser
            vdefeito   = asstec.defeito.

        disp asstec.etbcod @ tt-asstec.etbcod
             asstec.oscod  @ tt-asstec.oscod
             asstec.pladat @ tt-asstec.pladat
             asstec.planum @ tt-asstec.planum
             asstec.procod @ tt-asstec.procod
             produ.pronom
             asstec.clicod when avail clien @ tt-asstec.clicod
             clien.clinom when avail clien
             vnroserie @ tt-asstec.apaser
             if asstec.serie = "N" then no else yes @ vconfinado
             asstec.osobs    @ tt-asstec.osobs
             asstec.reincid  @ tt-asstec.reincid
             v-proobs-aux    @ tt-asstec.proobs
             vdefeito        @ tt-asstec.defeito
             v-imei-cel-aux
             v-cel-doa-aux
             asstec.nftnum
             with frame f-etiq.
    find atu-estab  where atu-estab.etbcod = asstec.etbcodatu no-lock no-error.

    find forne where forne.forcod = asstec.forcod no-lock no-error. 
   
    disp asstec.datexp
        asstec.forcod @ tt-asstec.forcod
        forne.fornom  when avail forne
        asstec.dtenvass
        asstec.dtretass
        asstec.dtenvfil
        atu-estab.etbcod   when avail atu-estab
        atu-estab.etbnom   when avail atu-estab
        asstec.dtentdep
        asstec.dtsaida 
        with frame f-etiq.
    color disp messages
                tt-asstec.oscod
                asstec.datexp
                atu-estab.etbcod                
                with frame f-etiq.

    if asstec.dtsaida <> ?
    then vetmovnom = "ENCERRADO".
    find last etiqpla of asstec no-lock no-error.
    if avail etiqpla
    then do.
        find etiqmov of etiqpla no-lock no-error.
        if avail etiqmov
        then vetmovnom = etiqmov.etmovnom.
    end.

    find first asstec_aux of asstec
                          where asstec_aux.nome_campo = "Encerra" or
                                asstec_aux.nome_campo = "Cancela"
                          no-lock no-error.
    if avail asstec_aux
    then vetmovnom =  asstec_aux.nome_campo + " " + asstec_aux.valor_campo.

    disp vetmovnom @ etiqmov.etmovnom with frame f-etiq.

end procedure.
 

procedure operacoes.

def var vmotivo   as char.
def var esqpos    as int init 1.
def var esqmenu   as char format "x(12)" extent 7
    init ["Encerra", "Cancela", ""].

form
    esqmenu
    with frame f-menu
         row screen-lines - 9 no-labels side-labels column 67 overlay 1 col.

hide message no-pause.

princ:
repeat:
    disp esqmenu with frame f-menu.
    choose field esqmenu with frame f-menu.
    esqpos = frame-index.

    if esqmenu[esqpos] = ""
    then next.
    
    run versenha.p ("ManutSSC", "", 
                    "Senha para " + caps(esqmenu[esqpos]) + "R OS no SSC",
                    output sresp). 
    if not sresp
    then next.
    do on error undo with frame f-cancela side-label.
        update vmotivo label "Motivo" format "x(20)"
               validate (vmotivo <> "", "").
    end.

    if esqmenu[esqpos] = "Encerra" or
       esqmenu[esqpos] = "Cancela"
    then do on error undo.
        find current asstec exclusive.
        assign
            asstec.etopeseq = -1
            asstec.dtsaida  = today.
/***
        vfuncod = int(acha("FUNCOD",return-value)).
***/
        create asstec_aux.
        assign
            asstec_aux.oscod = asstec.oscod
            asstec_aux.nome_campo  = esqmenu[esqpos]
            asstec_aux.valor_campo = "Motivo="  + vmotivo + 
                                   "|Funcod=" + string(sfuncod) +
                                   "|Data="   + string(today).
    end.
end.

end procedure.


procedure inclui-os-matriz.

    def var vcha-senha as character.
    def var vgarbiz    as log.

    run versenha.p ("ManutSSC", "", 
                    "Senha para INCLUIR OS no SSC",
                    output sresp).
    if not sresp
    then return.

    /* copiado de asstec.p */

do with frame f-etiq:
    
    create tt-asstec.    
    tt-asstec.etopecod = etiqope.etopecod.
    tt-asstec.etbcod   = setbcod.
                
    display tt-asstec.etbcod.

    update tt-asstec.procod.
    find produ where produ.procod = tt-asstec.procod no-lock no-error.
    if not avail produ or produ.catcod = 91
    then do.
        message "Produto invalido" view-as alert-box.
        undo,retry.
    end.
    display produ.pronom.

    message "Entre em contato com a Auditoria e solicite uma senha.".

    update vcha-senha format "x(25)" no-label
        with frame f-inf-senha centered overlay
             row 12 title "Informe a senha" width 30.

    sresp = no.
    run p-verifica-senha (input vcha-senha,
                          input tt-asstec.procod,
                          output sresp).
    if not sresp
    then undo, retry.

    update tt-asstec.apaser format "x(20)" colon 11
                                   with frame f-etiq no-validate.
    v-imei-cel-aux = "".
    if can-find(first adm.plaviv where
                              adm.plaviv.procod = tt-asstec.procod and
                              adm.plaviv.exportado)
    then do:
        find first adm.tbprice where adm.tbprice.etb_venda  = tt-asstec.etbcod
                                 and adm.tbprice.nota_venda = tt-asstec.planum
                                 and adm.tbprice.data_venda = tt-asstec.pladat
                               no-lock no-error.
    if available adm.tbprice
    then
        assign v-imei-cel-aux = adm.tbprice.serial.

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
                    
                    assign asstec.etbcod = tt-asstec.etbcod
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
                end.

        par-rec-asstec = recid(asstec).
        message "OS criada:" asstec.oscod view-as alert-box.
    end.

end procedure.


procedure inclui-os-loja:

    message 
        "A inclusão de OS agora deve ser feita na retaguarda de venda, menu "
        "ASSISTENCIA TECNICA. Neste menu do caixa deve ser feita apenas a "
        "movimentação da OS (dar sequência para emitir as NFe's)"
        view-as alert-box.

/***
    message "Conectando matriz...".
    if not connected ("commatriz") or
       not connected ("finmatriz")
    then do.
        connect com -H erp.lebes.com.br -S sdrebcom -N tcp -ld commatriz
             no-error.
        connect fin -H erp.lebes.com.br -S sdrebfin -N tcp -ld finmatriz
             no-error.
/*
    connect com -H sv-ca-linx-h.lebes.com.br -S sdrebcom -N tcp -ld commatriz
            no-error.
    connect fin -H sv-ca-linx-h.lebes.com.br -S sdrebfin -N tcp -ld finmatriz
            no-error.
*/
    end.

    if not connected ("finmatriz") or
       not connected ("commatriz")
    then message "Sem conexao com os bancos da matriz" view-as alert-box.
    else do.
        hide message no-pause.

        run not_incos_lj.p (par-etopecod, output par-rec-asstec).
        
        disconnect commatriz.
        disconnect finmatriz.
    end.
***/
    
end procedure.

procedure altera.

    do on error undo with frame f-etiq.
        vconfinado = if asstec.serie = "N" then no else yes.
        update vconfinado.
        find current asstec exclusive.
        if vconfinado
        then asstec.serie = "S".
        else asstec.serie = "N".
        find current asstec no-lock.
    end.

end procedure.


procedure p-verifica-senha:

    def input  parameter p-senha  as character.
    def input  parameter p-procod as integer.
    def output parameter p-resp   as logical.
    
    assign p-resp = no.
    
    find first tabaux where tabaux.Tabela = string(setbcod) + string(p-procod)
                            no-lock no-error.
    if not avail tabaux
    then do:
        message "Senha inválida."
                "Entre em contato com a Auditoria e solicite uma senha"
                view-as alert-box.
        return.
    end.
    
    if tabaux.Valor_Campo <> p-senha
    then do:
        message "Senha incorreta, digite novamente.".
        return.
    end.
    
    if tabaux.datexp < today - 1
    then do:
        message "Senha expirada, Solicite uma nova senha a Auditoria"
                view-as alert-box.
        return.
    end.
    
    assign p-resp = yes.

end procedure.

