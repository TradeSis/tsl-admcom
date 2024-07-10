{admcab.i}

def var vini as int.    
def var    vdtini  like plani.pladat. 
def var    vdtfin  like plani.pladat. 
def var    vativo  as   log.
         
def buffer zprodu  for  produ.
def buffer xclase  for  clase.

def temp-table tt-produ like produ.

def temp-table tt-icms
    field  procod  like produ.procod
    field  dtini   like plani.pladat
    field  dtfin   like plani.pladat
    field  ativo   as   log
        index ind-1 procod.

def input parameter vcatcod like produ.catcod.
def input parameter vforcod like forne.forcod.
def input parameter p-produto-pai like produ.procod.
def output parameter vprocod like produ.procod.

def var vpro    like produ.procod.
def var vpedpro like produ.procod.
def var vclacod like produ.clacod.
def buffer cprodu for produ.
def buffer bprodu for produ.
def temp-table wclase like clase.
def var vestmgoper like estoq.estmgoper.
def var vestmgluc  like estoq.estmgluc.
def var vestcusto  like estoq.estcusto.
def var vestvenda  like estoq.estvenda.

find forne where forne.forcod = vforcod no-lock.
def buffer b-produ-pai for produ.

do on error undo:
    find b-produ-pai where b-produ-pai.procod = p-produto-pai no-lock no-error.
        
    vcatcod = 50.
    /*display vcatcod colon 18 with frame f-choo.*/
    /*find categoria where categoria.catcod = vcatcod no-lock.*/

/*    display "ITENS" @ categoria.catnom no-label with frame f-choo.*/
    
    do on error undo:
        vclacod = b-produ-pai.clacod.
        /*update vclacod colon 18 help "[P] Procura de Classes" go-on(P p)*/
        /*        disp skip vclacod
               with frame f-choo centered width 80 side-label 
                                 row 14 overlay color white/red.*/
                                 
        if keyfunction(lastkey) = "P" or
           keyfunction(lastkey) = "p"
        then do:
            for each cprodu where cprodu.catcod = vcatcod and
                                  cprodu.fabcod = vforcod no-lock:

                find first wclase where wclase.clacod = cprodu.clacod no-error.
                if not avail wclase
                then do:
                    find clase where clase.clacod = cprodu.clacod 
                                     no-lock no-error.
                    if avail clase
                    then do:
                        create wclase.
                        assign wclase.clacod = cprodu.clacod
                               wclase.clanom = clase.clanom.
                    end.
                end.
            end.
            
            {zoomesq.i wclase wclase.clacod wclase.clanom 50 Classes true}
            vclacod = int(frame-value).
        
        end.

        find first xclase where xclase.clasup = vclacod no-lock no-error.
        if avail xclase
        then do:
            message "Classe Superior - Invalida para Cadastro".
            undo.
        end.

        find clase where clase.clacod = vclacod no-lock no-error.
/*        display vclacod
                clase.clanom no-label with frame f-choo.          */
    
    end.
    
    find fabri where fabri.fabcod = forne.forcod no-lock no-error.
  /*  display fabri.fabcod colon 18
            fabri.fabnom no-label with frame f-choo.*/
    /*
    update vpedpro colon 18
           help "[C] - Aciona Pesquisa por Nome"
           go-on(C c return) with frame f-choo.

    if keyfunction(lastkey) = "C" or
       keyfunction(lastkey) = "c"
    then do:
        {zoomesq.i1 produ produ.procod pronom 50 Produtos
                                               "produ.catcod = vcatcod and
                                                produ.clacod = vclacod and
                                                produ.fabcod = vforcod"}
         vpedpro = int(frame-value).
         vprocod = int(frame-value).
    end.
    */
    
    if keyfunction(lastkey) = "Return" and vpedpro = 0
    then do with frame fpro centered color white/red row 11 side-labels:
        
        for each tt-produ. delete tt-produ. end.
        
        create tt-produ.
        assign tt-produ.datexp   = today
               tt-produ.catcod   = vcatcod
               tt-produ.clacod   = vclacod
               tt-produ.fabcod   = fabri.fabcod
               tt-produ.prouncom = "UN"
               tt-produ.prounven = "UN"
               tt-produ.procvcom = 1
               tt-produ.procvven = 1.
        
        
        disp tt-produ.procod colon 15 skip(1).

        find categoria where 
             categoria.catcod = tt-produ.catcod no-lock no-error.
        if avail categoria
        then disp tt-produ.catcod colon 15 label "Departamento"
                  categoria.catnom no-label.
                  
        find clase where clase.clacod = tt-produ.clacod no-lock no-error.
        if avail clase
        then disp tt-produ.clacod colon 15 clase.clanom no-label.

        find fabri where fabri.fabcod = tt-produ.fabcod no-lock no-error.
        if avail fabri
        then disp tt-produ.fabcod colon 15 fabri.fabfant no-label.
                  
        find forne where forne.forcod = fabri.fabcod no-lock no-error.
        if avail forne
        then tt-produ.pronom = b-produ-pai.pronom.
        else tt-produ.pronom = b-produ-pai.pronom.

        update tt-produ.pronom colon 15 label "Descricao" format "x(44)".
        tt-produ.pronom = CAPS(tt-produ.pronom).
        disp tt-produ.pronom.
        
        tt-produ.pronomc = substring(tt-produ.pronom,1,30).
        update tt-produ.pronomc colon 15 label "Desc.Abreviada" format "x(30)".
        
        tt-produ.etccod = b-produ-pai.etccod.
        
        /*update tt-produ.etccod colon 15.
        find estac where estac.etccod = tt-produ.etccod no-lock no-error.
        if avail estac
        then disp estac.etcnom no-label.*/
    
        tt-produ.proabc = b-produ-pai.proabc.
        /*update tt-produ.proabc label "ABC" colon 15.*/
        tt-produ.procvcom = 1.
        
        /*update tt-produ.procvcom label "Volumes" colon 15.*/

        tt-produ.proindice = b-produ-pai.proindice.
        /*update tt-produ.proindice label "Cod.Barras" colon 15.*/
        
        tt-produ.proipiper = /*17*/ b-produ-pai.proipiper.

        /*
        do on error undo:
            update tt-produ.proipiper colon 15 label "Ali.Icms".
            if tt-produ.proipiper <> 17 and
               tt-produ.proipiper <> 12 and
               tt-produ.proipiper <> 99
            then do:
                message "Alicota Invalida".
                undo, retry.
            end.
        end.*/
        
        tt-produ.prorefter = b-produ-pai.prorefter.
        tt-produ.protam    = b-produ-pai.protam.
        
        /*update /* tt-produ.protam label "Para Montagem" format "x(3)"*/
               tt-produ.prorefter label "Referencia" colon 15.*/
               
        if tt-produ.protam = ""
        then tt-produ.protam  = "NAO".
        
        /*do on error undo, retry:
            update tt-produ.prouncom label "Unid.Compra" colon 15. 
            find unida where unida.unicod = tt-produ.prouncom no-lock no-error.
            if not avail unida
            then do:
                message "Unidade Invalida".
                undo, retry.
            end.
        end.
        display unida.uninom no-label.
        */
        tt-produ.prouncom = b-produ-pai.prouncom.
        tt-produ.prozort = fabri.fabfant + "-" + tt-produ.pronom.
        
        /****
        do with frame fpre2 centered overlay 
                            color white/cyan side-labels row 15.
            
            assign vestmgoper = 0 /* wempre.empmgoper */
                   vestmgluc  = 0. /* wempre.empmgluc. */


            update vestcusto  colon 20
                   /*vestmgluc  colon 20*/.

            /*vestcusto = vestcusto - (vestcusto * (vnfdes / 100)) .
              vestcusto = vestcusto + (vestcusto * (vacrfin / 100)).
              vestcusto = vestcusto + (vestcusto * (vfrete / 100)) .
              vestvenda = vestcusto + (vestcusto * (vestmgluc / 100)).*/
            
            if tt-produ.catcod = 41 or
               tt-produ.catcod = 45
            then do: 
              find first tabpreco where tabpreco.tabpre >= vestvenda
                                                no-lock no-error.
              if avail tabpreco
              then vestvenda = tabpreco.tabpre.
            end. 
            
            update vestvenda colon 20.
            /*vestmgluc = ((vestvenda - vestcusto) / vestcusto) * 100.*/
            display vestcusto colon 20
                    /*vestmgluc colon 20*/ .

        end.****/
        
    end.
end.

do transaction:
    
    /***/
    find last kit where kit.procod = p-produto-pai no-lock no-error.

    if not avail kit
    then vini = 01.
    else vini = int(substring(string(kit.itecod,"999999999"),1,2)) + 1.

    vprocod = int( string(vini,"99") + string(p-produto-pai,"9999999")).
    /***/
    
    find produ where produ.procod    = vprocod no-error.
    if avail produ then return.
    
    create produ. 
    assign produ.procod    = vprocod 
           produ.itecod    = vprocod 
           produ.pronom    = tt-produ.pronom 
           produ.datexp    = tt-produ.datexp 
           produ.catcod    = tt-produ.catcod 
           produ.clacod    = tt-produ.clacod 
           produ.fabcod    = tt-produ.fabcod 
           produ.proindice = tt-produ.proindice
           produ.prouncom  = tt-produ.prouncom 
           produ.prounven  = tt-produ.prounven 
           produ.procvcom  = tt-produ.procvcom 
           produ.procvven  = tt-produ.procvven 
           produ.prorefter = tt-produ.prorefter 
           produ.pronomc   = tt-produ.pronomc 
           produ.etccod    = tt-produ.etccod 
           produ.proabc    = tt-produ.proabc 
           produ.proipiper = tt-produ.proipiper 
           produ.protam    = tt-produ.protam 
           produ.prozort   = tt-produ.prozort. 
           
    if produ.pronom begins "TELEFONE"
    then assign produ.proseq = 1.
    
           
    if produ.pronom begins "CARTAO CELULAR"
    then assign produ.proclafis = "01".
    
    
    find produ where produ.procod = vprocod no-lock.
             
end.
    
    
    
    for each estab no-lock: 
    
        create estoq. 
        assign estoq.etbcod    = estab.etbcod 
               estoq.procod    = produ.procod 
               estoq.estcusto  = vestcusto 
               estoq.estdtcus  = (if vestcusto <> estoq.estcusto 
                                  then today 
                                  else estoq.estdtcus) 
               estoq.estvenda  = vestvenda 
               estoq.estdtven  = (if vestvenda <> estoq.estvenda 
                                  then today 
                                  else estoq.estdtven) 
               /*estoq.tabcod    = vtabcod */
               estoq.estideal = -1
               estoq.datexp    = today.

    end.
    
    /*
    message "Incluir caracteristica para o PRODUTO?" update sresp.
    if sresp
    then run procar.p (input produ.procod).
    */
    
/*end.    */

run p-enderecamento(input produ.procod).


procedure p-enderecamento:
    def input parameter p-procod-e like produ.procod.
    
    def var vprocod-e like produ.procod.  
    def var vpavilhao-e like ender.pavilhao. 
    def var vrua-e      like ender.rua. 
    def var vnumero-e   like ender.numero. 
    def var vandar-e    like ender.andar.

    sresp = yes.
    message "Deseja cadastrar o endereco para este Item?" update sresp.
    if sresp
    then do:
        vprocod-e = p-procod-e.
    
        form   
            vprocod-e    label "Produto" at 2
            produ.pronom     no-label skip 
            vpavilhao-e  label "Pavilhao" skip 
            vrua-e       label "Rua"         at 6 
            vnumero-e    label "Numero" 
            vandar-e     label "Andar"  
            with frame f-enderi /*color black/cyan*/  title " Enderecamento "
                          centered side-label row 5 .

                    
        do with frame f-enderi on error undo:
                        
            /*update vprocod-e.*/  
            find produ where produ.procod = vprocod-e no-lock no-error.  
            if not avail produ 
            then do: 
                message "Produto nao Cadastrao". 
                undo. 
            end. 
            else disp produ.pronom with frame f-enderi.  
    
        end.

        update vpavilhao-e 
               vrua-e 
               vnumero-e 
               vandar-e with frame f-enderi.  
    
        create ender.     
        assign ender.procod   = vprocod-e 
               ender.pavilhao = vpavilhao-e 
               ender.rua      = vrua-e  
               ender.numero   = vnumero-e  
               ender.andar    = vandar-e.
    end.
end procedure.
