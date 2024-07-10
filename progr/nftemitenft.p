{admcab.i}

def var vetb-emite like estab.etbcod. 
def var vetb-deste like estab.etbcod.      
       
def temp-table tt-estoq like estoq.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

def var v-nota as int.
def var vnfs as int.

def buffer cplani for plani.
def buffer bplani for plani.
def buffer dplani for plani.

def buffer cplani1 for plani.
def buffer bplani1 for plani.
def buffer dplani1 for plani.


def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vserie like plani.serie.
def var vprotot like plani.protot.
def var vmovseq like movim.movseq.
def buffer bestab for estab.
def var vetb-desti like estab.etbcod.
def var vcatcod like produ.catcod.

def temp-table tt-arq
    field emite  as int
    field numero as int
    field serie  as char
    index i1 emite numero serie
    .
    
update vetb-emite label "Filial emitente" with frame f1.
find first estab where estab.etbcod = vetb-emite no-lock.
disp estab.etbnom no-label with frame f1.         
update vetb-desti at 2 label "Filial destino" with frame f1.
find first bestab where bestab.etbcod = vetb-desti no-lock.
if vetb-emite = vetb-desti then undo.
disp bestab.etbnom no-label with frame f1 1 down side-label width 80.
    
disp 
"Informe o caminho e nome do arquivo com Emitente, Serie e numero das NFs"
skip
"ou deixe em branco para informar manualmente.  Layout(Emite;Serie;Numero)"
with centered.

def var vlinha as char.
def var vok-arq as log.
assign
    vlinha = ""
    vok-arq = yes.
update varquivo as char format "x(65)" label "Arquivo"
        with frame f-1 side-label width 80.
        
if varquivo <> ""
then do:
    if search(varquivo) <> ?
    then do:
        vok-arq = yes.
        input from value(varquivo).
        repeat:
            import vlinha.
            if num-entries(vlinha,";") <> 3
            then do:
                vok-arq = no.
                leave.
            end. 
            create tt-arq.
            assign
                tt-arq.emite  = int(entry(1,vlinha,";"))
                tt-arq.numero = int(entry(3,vlinha,";"))
                tt-arq.serie  = entry(2,vlinha,";")
                .
        end.
        input close.
        if not vok-arq
        then do on endkey undo:
             bell.
             message "Problema no layout do arquivo." .
             pause.
             return.
        end.     
        for each tt-arq where tt-arq.numero = 0:
            delete tt-arq.
        end.    
    end.
    else do on endkey undo:
        bell.
        message "Arquivo nao encontrado.".
        pause.
        return.
    end.
end.
def var vemite-nfe as int.
def var vnumero-nfe as int.
def var vserie-nfe as char.
repeat:    
    assign
        vemite-nfe = ?
        vnumero-nfe = ?
        vserie-nfe = "".
    
    find first tt-arq where tt-arq.numero > 0 no-error.
    if not avail tt-arq and
       varquivo <> ""
    then leave.   
    else if avail tt-arq
        then assign
                vemite-nfe  = tt-arq.emite
                vnumero-nfe = tt-arq.numero
                vserie-nfe  = tt-arq.serie
                .
        else update vemite-nfe  label "Emitente"
                    vnumero-nfe label "  Numero" 
                    vserie-nfe  label "   Serie"
                    with frame f4 1 down width 80 side-label.

    disp vemite-nfe vnumero-nfe vserie-nfe with frame f4
        title " documento origem ".
    
    if vnumero-nfe = 0 or
       vnumero-nfe = ? or
       vserie-nfe = ""
    then do:
        bell.
        message "Numero e ou serie nao permitidos.".
        pause.
        next.
    end.    
    
    find tipmov where tipmov.movtdc = 6 no-lock.
    find first opcom where opcom.movtdc = tipmov.movtdc and
                           opcom.opccod = "5152" no-lock.
    
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
        
    vplacod = ?.
    vnumero = ?.
    vserie = "1".
        
    do on error undo:
        create tt-plani.  
        assign tt-plani.etbcod   = vetb-emite   
               tt-plani.placod   = vplacod   
               tt-plani.emite    = vetb-emite   
               tt-plani.serie    = vserie   
               tt-plani.numero   = vnumero   
               tt-plani.movtdc   = 6   
               tt-plani.desti    = vetb-desti    
               tt-plani.pladat   = today   
               tt-plani.datexp   = today   
               tt-plani.modcod   = tipmov.modcod   
               tt-plani.notfat   = vetb-desti    
               tt-plani.dtinclu  = today   
               tt-plani.horincl  = time   
               tt-plani.notsit   = no
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.hiccod   = int(opcom.opccod). 
                   
        vprotot = 0. vmovseq = 0. 
        
        find plani where plani.movtdc = tipmov.movtdc and
                         plani.etbcod = vemite-nfe    and
                         plani.emite  = vemite-nfe    and
                         plani.serie  = vserie-nfe    and
                         plani.numero = vnumero-nfe
                         no-lock no-error.
        if not avail plani
        then do:
            bell.
            message color red/with
            "Nota Fiscal nao encontrada na base."
            view-as alert-box.
            delete tt-arq.
            next.
        end.    
        vmovseq = 0.     
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock: 
            vmovseq = vmovseq + 1. 

            create tt-movim. 
            ASSIGN tt-movim.movtdc = tt-plani.movtdc 
                   tt-movim.PlaCod = tt-plani.placod 
                   tt-movim.etbcod = tt-plani.etbcod 
                   tt-movim.movseq = vmovseq 
                   tt-movim.procod = movim.procod 
                   tt-movim.movqtm = movim.movqtm
                   tt-movim.movpc  = movim.movpc 
                   tt-movim.movdat = tt-plani.pladat 
                   tt-movim.MovHr  = int(time) 
                   tt-movim.desti  = tt-plani.desti 
                   tt-movim.emite  = tt-plani.emite.
                    
                tt-plani.platot = tt-plani.platot + 
                        (tt-movim.movpc * tt-movim.movqtm).
                tt-plani.protot = tt-plani.protot + 
                        (tt-movim.movpc * tt-movim.movqtm).
        end.
        release tt-plani no-error.
        release tt-movim no-error.
    end.
    for each tt-movim where tt-movim.procod = 0.
        delete tt-movim.
    end.
    vmovseq = 0.
    for each tt-movim .
        vmovseq = vmovseq + 1.
        tt-movim.movseq = vmovseq.
    end.
    disp vmovseq label "Quantidade de itens" 
    with frame f5 1 down side-label.
    
    sresp = no.
    message "Confirma emitir?" update sresp.
    if sresp
    then do:
            run emissao-NFe.
    end.
    if avail tt-arq
    then delete tt-arq.
end.
    
procedure emissao-NFe:
    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    def var nfe-emite like plani.emite.
    
    nfe-emite = vetb-emite.
    
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then do:
        run manager_nfe.p (input "5152",
                           input ?,
                           output p-ok).
    end.
    else do:
        message color red/with
        "Faltou configurar parametros."
        view-as alert-box.
    end.
end procedure.

procedure acerta-numero-NFe:

    find last A01_infnfe where
              A01_infnfe.emite = vetb-emite and
              A01_infnfe.serie  = "1"
              no-lock no-error.
              
    if avail A01_infnfe and A01_infnfe.numero > vnumero-nfe
    then do:
        bell.
        message color red/with
               "Existe numero emitido igual ou maior ao informado"
               A01_infnfe.numero
                view-as alert-box
                 .
        vnumero-nfe = 0.

    end.
    else if not avail A01_infnfe or A01_infnfe.numero < vnumero-nfe             
    then do on error undo:

        create A01_infnfe.
        assign
                    A01_infnfe.chave = ""
                    A01_infnfe.emite = vetb-emite
                    A01_infnfe.serie = "1"
                    A01_infnfe.numero = vnumero-nfe
                    A01_infnfe.etbcod = vetb-emite
                    A01_infnfe.placod = 
                            dec("55" + string(vnumero-nfe,"9999999"))
                    A01_infnfe.versao = 1.10
                    A01_infnfe.id     = "NFe"
                    A01_infnfe.tdesti = "Filial"
                    .
        
        release A01_infnfe no-error.
        
    end.
end procedure.
