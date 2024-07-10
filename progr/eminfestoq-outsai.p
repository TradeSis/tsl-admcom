{admcab.i new}

if setbcod <> 999
then do on endkey undo.
    message "Voce não esta logado como 999."
            "Esta logado logado como" setbcod
            view-as alert-box. 
    return.
end.

def var vetb-emite like estab.etbcod. 
def var vetb-desti like estab.etbcod format ">>>>>>>>9".      
       
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

def var vcfop as char.

def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vserie like plani.serie.
def var vprotot like plani.protot.
def var vmovseq like movim.movseq.
def buffer bestab for estab.
def var vcatcod like produ.catcod.

def temp-table tt-arq
    field arquivo as char format "x(50)"
    .
    /*
    vetb-emite = 61.
    vetb-desti = 116426.
    */
    vcfop = "5949".
    find opcom where opcom.opccod = vcfop no-lock.
    disp opcom.opccod at 6  label "CFOP"
         opcom.opcnom no-label  format "x(12)"
         skip
         .

    update vetb-emite at 2 label "Emitente" .
    find first estab where estab.etbcod = vetb-emite no-lock.
    disp estab.etbnom no-label.         
    update vetb-desti at 3 label "Destino" .
    /*find first bestab where bestab.etbcod = vetb-desti no-lock.
      disp bestab.etbnom no-label with 1 down side-label width 80.
    */
    find forne where forne.forcod = vetb-desti no-lock.
    disp forne.fornom no-label with 1 down side-label width 80.
    
    if vetb-emite = vetb-desti then undo.
    update vcatcod at 1.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp catnom no-label.
    
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
             
    for each estoq where estoq.etbcod = vetb-emite and
                         estoq.estatual > 0 no-lock:
                                                     
        find produ where produ.procod = estoq.procod 
                                no-lock no-error.
        if not avail produ
        then next.
        
        if vcatcod > 0 and
           produ.catcod <> vcatcod
        then next.   

        disp "Processando estoque... "
        produ.procod with frame fe 1 down row 10.
        pause 0.                                
        create tt-estoq. 
        buffer-copy estoq to tt-estoq.
          
    end.
    
    hide frame fe no-pause.            
              
    def var varq-est as char.
    varq-est = "/admcom/work/estoque_" + 
                string(vcatcod,"99") + "_" + string(vetb-emite,"999") + ".d".
                
    output to value(varq-est).
    for each tt-estoq: 
        export tt-estoq.
    end.      
    output close.
    
    vmovseq = 0.            
    for each tt-estoq:  
        vmovseq = vmovseq + 1.  
    end.
                
    vnfs = int(substr(string(vmovseq / 200,">>9.999"),1,3)).
    if int(substr(string(vmovseq / 200,">>9.999"),5,3)) > 0
    then vnfs = vnfs + 1.

    bell.
    message color red/with
                    "Numero de itens no pedido: " vmovseq skip
                    "Numero maximo de itens NF: 200" skip
                    "Serão geradas" vnfs "NF(s)"
                     view-as alert-box.

    if vnfs = 0
    then do:
        message color red/with
        "Nao ha estoque para transferir."
                view-as alert-box.
        undo.        
    end.
    
    def var vqtd-item as int.
    def var vqtd-nota as int.
    def var varq-nota as char.
    vqtd-item = 0.
    vqtd-nota = 0.
    varq-nota = "".
    def var varq-n as char.
    varq-n = "/admcom/work/est_" + string(vcatcod,"99") + "_"
                        + string(vetb-emite,"999")
                        + "_" + string(vetb-desti,"999999") + "_" +
                        string(today,"99999999") + "." 
                     .
    unix silent value("rm " + varq-n + "*" + " -f").
                           
    for each tt-estoq where tt-estoq.procod > 0 and
                tt-estoq.estatual > 0 no-lock:
        
        if vqtd-item = 200 then vqtd-item = 0.
        
        if vqtd-item = 0
        then do:
            assign
                vqtd-nota = vqtd-nota + 1
                varq-nota = varq-n + string(vqtd-nota,"99999").
        end.
        output to value(varq-nota) append.
        export tt-estoq.
        output close.

        vqtd-item = vqtd-item + 1.
        
    end.
    
    find tipmov where tipmov.movtdc = 26 no-lock.
    find first opcom where opcom.movtdc = tipmov.movtdc no-lock.
 
    def temp-table tt-estnf like estoq.
    def var vi as int.

    do vi = 1 to vqtd-nota with frame f2:
        disp "Emiteindo NF " vi no-label.

        for each tt-estnf: delete tt-estnf. end.
        
        varq-nota = varq-n + string(vi,"99999").
        input from value(varq-nota).
        repeat:
            create tt-estnf.
            import tt-estnf.
        end.
        input close.
        
        find first tt-estnf where
                   tt-estnf.procod > 0 and
                   tt-estnf.estatual > 0
                   no-lock no-error.
        if not avail tt-estnf
        then do:
            bell.
            message color red/with
                   "Nao existe item para NF " vi 
                   view-as alert-box .
            next.
        end.     
              
        for each tt-plani: delete tt-plani. end.
        for each tt-movim: delete tt-movim. end.
        /*
        find tipmov where tipmov.movtdc = 26 no-lock.
        find last opcom where opcom.movtdc = tipmov.movtdc no-lock.
        */
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
               "Motivo: NF de troca de endereco no mesmo municipio"
               . 
                   
        vprotot = 0. vmovseq = 0. 
        
        for each tt-estnf where tt-estnf.procod > 0 no-lock:   
            vmovseq = vmovseq + 1. 

            create tt-movim. 
            ASSIGN tt-movim.movtdc = tt-plani.movtdc 
                   tt-movim.PlaCod = tt-plani.placod 
                   tt-movim.etbcod = tt-plani.etbcod 
                   tt-movim.movseq = vmovseq 
                   tt-movim.procod = tt-estnf.procod 
                   tt-movim.movqtm = tt-estnf.estatual 
                   tt-movim.movdat = tt-plani.pladat 
                   tt-movim.MovHr  = int(time) 
                   tt-movim.desti  = tt-plani.desti 
                   tt-movim.emite  = tt-plani.emite
                   tt-movim.movcsticms = "51"
                   tt-movim.movcstpiscof = 8.
                    
                tt-movim.movpc  = tt-estnf.estcusto.

                tt-plani.platot = tt-plani.platot + 
                        (tt-movim.movpc * tt-movim.movqtm).
                tt-plani.protot = tt-plani.protot + 
                        (tt-movim.movpc * tt-movim.movqtm).
                vprotot = vprotot + 
                    (tt-estnf.estcusto * tt-estnf.estatual).
        
            delete tt-estnf.
        end.
        release tt-plani no-error.
        release tt-estnf no-error.
        release tt-movim no-error.
        end.

        vmovseq = 0.
        for each tt-movim where tt-movim.procod = 0.
            delete tt-movim.
        end.
        for each tt-movim.
            vmovseq = vmovseq + 1.
        end.
        disp vmovseq column-label "Itens".    
        sresp = no.
        message "Confirma emitir?" update sresp.
        if sresp
        then do:
            run emissao-NFe.
        end.
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
        run manager_nfe.p (input "5949",
                           input ?,
                           output p-ok).
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
