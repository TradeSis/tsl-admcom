{admcab.i}

if setbcod <> 999
then do on endkey undo.
    message "Voce não esta logado como 999."
            "Esta logado logado como" setbcod
            view-as alert-box. 
    return.
end.

def var vetb-emite like estab.etbcod format ">>>>>>>>9". 
def var vetb-deste like estab.etbcod .      
       
def temp-table tt-estoq like estoq.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def temp-table tt-nota like plani.

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
def var vcfop as char.

def temp-table tt-arq
    field arquivo as char format "x(50)"
    .
    /*
    vetb-desti = 61.
    vetb-emite = 116426.
    */
    vcfop = "1949".
    find opcom where opcom.opccod = vcfop no-lock.
    disp opcom.opccod at 5  label "CFOP"
         "OUTRAS ENTRADAS DE MERC. OU PREST. DE SERV. NAO ESPECIFICADO"
         no-label  format "x(60)"
         skip
         .

    update vetb-emite label "Emitente" .
    /*find first estab where estab.etbcod = vetb-emite no-lock.
    disp estab.etbnom no-label.         
    */
    find forne where forne.forcod = vetb-emite no-lock.
    disp forne.fornom no-label with 1 down side-label width 80.

    update vetb-desti at 2 label "Destino" .
    find first bestab where bestab.etbcod = vetb-desti no-lock.
    disp bestab.etbnom no-label with 1 down side-label width 80.
    /*
    find forne where forne.forcod = vetb-desti no-lock.
    disp forne.fornom no-label with 1 down side-label width 80.
    */
    if vetb-emite = vetb-desti then undo.
    /*
    update vcatcod at 7.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp catnom no-label.
    */
    sresp = no.  
    message "Confirma os parametros informados?"   
    update sresp.  
    if not sresp then leave.

    def var vnumero-nfe like A01_infnfe.numero.
    
    update vnumero-nfe 
        label "Numero da ultima NFe emitida na Filial emitente"
        help "Olhar no NOTAMAX o ultimo numero emitido"
           with frame f1 side-label.
     
    if vnumero-nfe = 0
    then undo.

    run acerta-numero-NFe.
    
    if vnumero-nfe = 0
    then undo.
    
    hide frame f1 no-pause.
      
    for each plani where
             plani.etbcod = vetb-desti  and
             plani.emite = vetb-desti and
             plani.desti = vetb-emite and
             plani.movtdc = 26 and
             plani.pladat >= today - 30
             no-lock .
        find first a01_infnfe where
                   a01_infnfe.emite = vetb-desti and
                   a01_infnfe.numero = plani.numero
                   no-lock no-error.
        if not avail a01_infnfe or a01_infnfe.situacao <> "AUTORIZADA"
        then next.           

           create tt-nota.
           buffer-copy plani to tt-nota.
    
     end.         
    
    find tipmov where tipmov.movtdc = 11 no-lock.
    find first opcom where opcom.movtdc = tipmov.movtdc no-lock.
        
    for each tt-nota :
        disp tt-nota.numero tt-nota.pladat tt-nota.platot
        .
        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.

        vplacod = ?.
        vnumero = ?.
        vserie = "1".
        
        do on error undo:
            create tt-plani.  
            assign tt-plani.etbcod   = tt-nota.etbcod   
               tt-plani.placod   = vplacod   
               tt-plani.emite    = vetb-emite   
               tt-plani.serie    = vserie   
               tt-plani.numero   = vnumero   
               tt-plani.movtdc   = tipmov.movtdc   
               tt-plani.desti    = vetb-desti    
               tt-plani.pladat   = today   
               tt-plani.datexp   = today   
               tt-plani.modcod   = tipmov.modcod   
               tt-plani.notfat   = vetb-desti    
               tt-plani.dtinclu  = today   
               tt-plani.horincl  = time   
               tt-plani.notsit   = no
               tt-plani.opccod   = int(opcom.opccod)
               tt-plani.hiccod   = int(opcom.opccod)
               tt-plani.notobs[1]  = 
               "Motivo: troca de endereco no mesmo municipio ref. NF de saida "
               + string(tt-nota.numero)
               . 
                   
            vprotot = 0. vmovseq = 0. 
        
            for each movim where
                     movim.etbcod = tt-nota.etbcod and
                     movim.placod = tt-nota.placod and
                     movim.movtdc = tt-nota.movtdc
                     no-lock.
                     
                create tt-movim. 
                ASSIGN tt-movim.movtdc = tt-plani.movtdc 
                   tt-movim.PlaCod = tt-plani.placod 
                   tt-movim.etbcod = tt-plani.etbcod 
                   tt-movim.movseq = movim.movseq 
                   tt-movim.procod = movim.procod 
                   tt-movim.movqtm = movim.movqtm 
                   tt-movim.movdat = tt-plani.pladat 
                   tt-movim.MovHr  = int(time) 
                   tt-movim.desti  = tt-plani.desti 
                   tt-movim.emite  = tt-plani.emite
                   tt-movim.movpc  = movim.movpc
                   tt-movim.movcsticms = "51"
                   tt-movim.movcstpiscof = 98.

                tt-plani.platot = tt-plani.platot + 
                        (tt-movim.movpc * tt-movim.movqtm).
                tt-plani.protot = tt-plani.protot + 
                        (tt-movim.movpc * tt-movim.movqtm).
                vmovseq = vmovseq + 1.
            end.
        
            release tt-plani no-error.
            release movim    no-error.
            release tt-movim no-error.
        end.
        
        for each tt-movim where tt-movim.procod = 0.
            vmovseq = vmovseq - 1.
            delete tt-movim.
        end.

        disp vmovseq column-label "Itens".    
        sresp = no.
        message "Confirma emitir?" update sresp.
        if sresp
        then do:
            run emissao-NFe.
        end.
        delete tt-nota.
    end.
    
procedure emissao-NFe:
    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    def var nfe-emite like plani.emite.
    
    nfe-emite = vetb-desti.
    
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then do:
        find first tt-plani.
        tt-plani.notobs[2] = 
               "OUTRAS ENTRADAS DE MERC. OU PREST. DE SERV. NAO ESPECIFICADO".
                
        run manager_nfe.p (input "1949_f",
                           input ?,
                           output p-ok).
    end.
end procedure.

procedure acerta-numero-NFe:

    find last A01_infnfe where
              A01_infnfe.emite = vetb-desti and
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
                    A01_infnfe.emite = vetb-desti
                    A01_infnfe.serie = "1"
                    A01_infnfe.numero = vnumero-nfe
                    A01_infnfe.etbcod = vetb-desti
                    A01_infnfe.placod = 
                            dec("55" + string(vnumero-nfe,"9999999"))
                    A01_infnfe.versao = 1.10
                    A01_infnfe.id     = "NFe"
                    A01_infnfe.tdesti = "Filial"
                    .
        
        release A01_infnfe no-error.
        
    end.
end procedure.
