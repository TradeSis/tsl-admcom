/*** 17/04/2013 ***/
{admcab.i}

def input parameter par-opc     as char.
def input parameter par-catcod  like produ.catcod.
def input parameter par-forcod  like forne.forcod.
def input parameter par-frete   like pedid.condes.
def input parameter par-nfdes   like pedid.nfdes.
def input parameter par-acrfin  like pedid.nfdes.
def input-output parameter par-procod like produ.procod.

def var produ-lst   as char init "405853,407721".
def var vproipiper  like produ.proipiper.
def var mini_pedido as log format "Sim/Nao".
def var vetiqueta   as log format "Sim/Nao".
def var vpack       as int format ">>>>9".
def var vestatus    as int format ">9".
def var vestatus-d  as char extent 4  FORMAT "X(15)"
        init["NORMAL","BRINDE","FORA DE LINHA","FORA DO MIX"].
def var v-mva       as dec.
def var vestcusto   like estoq.estcusto.
def var vestmgoper  like estoq.estmgoper.
def var vestmgluc   like estoq.estmgluc.
def var vestvenda   like estoq.estvenda.
def var v-ativo     as log format "Sim/Nao".
def var vtitulo     as char.
def var vprocod     like produ.procod.
def var vgracod     like produpai.gracod.
def var vtempogar   as int.

def temp-table tt-produ like produ.

def new shared temp-table ttcores
    field corcod   like cor.corcod
    field marc  as log init no
    field perm  as log
    index cor   is primary unique corcod.

def buffer bprodu for produ.
def buffer xprodu for produ.
def buffer bunida for unida.
def buffer xclase for clase.
def buffer bprodatrib for prodatrib.
def buffer batributo  for atributo.

find func where func.funcod = sfuncod and
                func.etbcod = setbcod
                no-lock no-error.
if not avail func
then do:
    message "Funcionario Invalido.".
    undo.
end.

for each tt-produ.
    delete tt-produ.
end.

pause 0.

if par-opc = "ALTPai" or
   par-opc = "CONPai"
then do.
    vtitulo = "Manutencao de produto PAI".
    find produpai where produpai.itecod = par-procod no-lock.
    find first produ of produpai no-lock no-error.
    if not avail produ
    then do.
        message "Sem filhos para o produto" view-as alert-box.
        return.
    end.
    
    create tt-produ.
    {produ.i tt-produ produ}
    ASSIGN
        tt-produ.procod        = produpai.itecod
        tt-produ.pronom        = produpai.pronom
        tt-produ.pronomc       = produpai.pronom
        tt-produ.fabcod        = produpai.fabcod
        tt-produ.clacod        = produpai.clacod
        tt-produ.prorefter     = produpai.prorefter
        tt-produ.temp-cod      = produpai.temp-cod
        tt-produ.catcod        = produpai.catcod.
end.

if par-opc = "ALT" or
   par-opc = "CON" or
   par-opc = "AltFilho" or
   par-opc = "ConFilho"
then do.
    if par-opc = "CON"
    then vtitulo = " Consulta de produto ".
    else vtitulo = "Manutencao de produto".
    if par-opc matches "*Filho*"
    then par-opc = par-opc + " FILHO".

    find produ where produ.procod = par-procod no-lock.
    create tt-produ.
    {produ.i tt-produ produ}
end.

if par-opc begins "Alt" or
   par-opc begins "Con"
then do.
    vproipiper = tt-produ.proipiper.

    /* usado para todos */
    if produ.proseq = 0
    then v-ativo = yes.
    else v-ativo = no.

    find cor    where cor.corcod = tt-produ.corcod no-lock no-error.
    find fabri  where fabri.fabcod = tt-produ.fabcod no-lock no-error.
    find clase  where clase.clacod = tt-produ.clacod NO-LOCK no-error.
    find categoria where categoria.catcod = tt-produ.catcod no-lock.
    find estac  where estac.etccod = tt-produ.etccod no-lock no-error.
    find unida  where unida.unicod = tt-produ.prouncom no-lock no-error.
    find bunida where bunida.unicod = tt-produ.prounven no-lock no-error.
    find temporada of tt-produ no-lock no-error.

    /* usado na cat 41 tambem */
    if tt-produ.proipival = 1
    then mini_pedido = yes.
    else mini_pedido = no.
                
    vetiqueta = no.
    /* nao usado na cat 41 */
    find produaux where
                     produaux.procod     = tt-produ.procod and
                     produaux.nome_campo = "Etiqueta-Preco"
                     no-lock no-error.
    if avail produaux and
       produaux.valor_campo = "Sim"
    then vetiqueta = yes.
    
    vpack = 0.
    /* nao usado na cat 41 */
    find produaux where
                     produaux.procod     = tt-produ.procod and
                     produaux.nome_campo = "Pack"
                     no-lock no-error.
    if avail produaux 
    then vpack = int(produaux.valor_campo).
        
    vestatus = 0.            
    /*** Estatus ***/ /* nao usado no 41 */
    find produaux where
                     produaux.procod     = tt-produ.procod and
                     produaux.nome_campo = "Estatus"
                     no-lock no-error.
    if avail produaux 
    then vestatus = int(produaux.valor_campo).

    /*** MVA ***/
    /* nao cadastrado na inclusao ou alteracao, so consulta */
    v-mva = 0.
    find produaux where
                     produaux.procod     = tt-produ.procod and
                     produaux.nome_campo = "MVA"
                     NO-LOCK no-error.
    if avail produaux 
    then v-mva = dec(produaux.valor_campo).

    vtempogar = 0.
    find first produaux where produaux.procod     = tt-produ.procod
                          and produaux.nome_campo = "TempoGar"
                    NO-LOCK no-error.
    if avail produaux 
    then vtempogar = int(produaux.valor_campo).

    if produ.ind_vex
    then vtitulo = vtitulo + "- VEX ".
     
    display
        tt-produ.itecod    colon 15 format ">>>>>>>9"
        tt-produ.procod    colon 50 format ">>>>>>9"
        tt-produ.proindice colon 15 label "Cod.Barras"
        tt-produ.prodtcad  colon 50
        v-ativo            colon 71 label "Ativo"
        tt-produ.pronom    colon 15 label "Descricao"
        tt-produ.pronomc   format "x(30)" label "Desc.Abreviada"
        tt-produ.corcod    colon 50 label "Cor"
        cor.cornom         no-label format "x(20)" when avail cor
        tt-produ.fabcod    colon 15
        fabri.fabfant      no-label format "x(20)" when avail fabri
        tt-produ.proabc    label "ABC" colon 50
        tt-produ.clacod    format ">>>>>>>>9" colon 15 label "Subclasse"
        clase.clanom       no-label format "x(20)" when avail clase
        vtempogar          colon 71 label "Tempo Garantia" format ">9"
        tt-produ.catcod    colon 15 label "Departamento"
        categoria.catnom   format "x(20)" no-label when avail categoria
        tt-produ.pvp       colon 50
        tt-produ.etccod    colon 15 
                           validate (tt-produ.etccod > 0,"Estacao invalida")
        estac.etcnom       no-label when avail estac
        tt-produ.temp-cod  colon 50 format ">>9" label "Temporada"
        temporada.tempnom  no-label format "x(15)" when avail temporada
        tt-produ.prouncom  colon 15
        unida.uninom       no-label format "x(15)" when avail unida
        tt-produ.prounven  colon 50
        bunida.uninom      no-label format "x(15)" when avail bunida
        tt-produ.procvcom  label "Volumes" colon 15
        tt-produ.protam    label "Para Montagem" format "x(3)" colon 50
        tt-produ.prorefter label "Referencia" colon 15
        tt-produ.opentobuy colon 50  
        mini_pedido        label "Mini Pedido" colon 71
        vetiqueta          label "Etiqueta Preco" colon 15
        vpack              label "Pack"    colon 28
        vestatus           label "Estatus" colon 50
        vestatus-d[vestatus + 1] no-label
        tt-produ.proipiper colon 15 label "Aliq.Icms"
        v-mva              label "MVA" format ">>9.99"
        tt-produ.codfis    label "Class.Fiscal" format ">>>>>>>9" colon 50
        tt-produ.descrevista format "x(55)" label "Desc. Revista" colon 15
        WITH frame f-produ side-label row 4 title vtitulo.


    if categoria.grade
    then tt-produ.protam:label = "Tamanho".
    if par-opc matches "*Pai*"
    then do.
        hide tt-produ.corcod in frame f-produ.
        hide cor.cornom      in frame f-produ.
        hide tt-produ.protam in frame f-produ.
    end.        
      
    find first prodatrib
                     where prodatrib.procod = produ.procod
                       and can-find (first atributo
                                   where atributo.atribcod = prodatrib.atribcod
                                     and atributo.tipo = "capacidade")
                                       no-lock no-error.

    find first bprodatrib
                     where bprodatrib.procod = produ.procod
                       and can-find (first atributo
                                   where atributo.atribcod = bprodatrib.atribcod
                                     and atributo.tipo = "estado")
                                       no-lock no-error.
    if avail bprodatrib
    then find first batributo
                     where batributo.atribcod = bprodatrib.atribcod
                       and batributo.tipo = "estado" no-lock no-error.

    pause 0.
    disp
        produ.descontinuado /*colon 15*/
        produ.datfimvida    /*colon 35*/ label "Data Fim Vida"
        prodatrib.atribcod  /*colon 15*/ format ">>9" label "Atributo"
                            when avail prodatrib
        bprodatrib.atribcod /*colon 35*/ format ">>9" /*at 9*/ label "Estado"
                            when avail bprodatrib
        batributo.atribdes no-label when avail batributo
        with frame f-produ2 side-label row screen-lines - 2 overlay centered
            title " Informacoes Adicionais ".

    if par-opc begins "CON"
    then pause.
end.

if par-opc = "INC" or
   par-opc = "IncPai" 
then do.
    vtitulo = "Inclusao de produto" + if par-opc = "INC" then "" else " PAI".
    assign
        vetiqueta   = no
        vpack       = 0
        vestatus    = 0
        mini_pedido = no
        vproipiper  = 17.
    if today >= 01/01/2016 and today <= 12/31/2018
    then vproipiper  = 18.

    create tt-produ.
    assign
        tt-produ.datexp   = today
        tt-produ.catcod   = par-catcod
        tt-produ.fabcod   = par-forcod
        tt-produ.prouncom = "UN"
        tt-produ.prounven = "UN"
        tt-produ.procvcom = 1
        tt-produ.procvven = 1
        tt-produ.proipiper = vproipiper
        tt-produ.opentobuy = yes
        tt-produ.proseq   = 98 /* Bloqueado */.
end.

if par-opc begins "ALT" or
   par-opc begins "INC"
then do with frame f-produ.
    update 
        tt-produ.proindice.

    find xprodu where xprodu.proindice = tt-produ.proindice and
                      xprodu.procod <> tt-produ.procod no-lock no-error.
    if avail xprodu
    then do:
        message color red/with
        "Codigo de barras ja cadastrado no produto " xprodu.procod
        view-as alert-box.
        return. 
    end.
    
    do on error undo.
        update    
            tt-produ.pronom.
        if par-opc = "INC"
        then find first xprodu where xprodu.pronom = tt-produ.pronom
                            use-index ipronom no-lock no-error. 
        if par-opc = "ALT"
        then find first xprodu where xprodu.pronom  = tt-produ.pronom and
                                     xprodu.procod <> produ.procod
                                    use-index ipronom no-lock no-error.
        if (avail xprodu and par-opc = "INC") or
           (avail xprodu and par-opc = "ALT" and tt-produ.pronom entered)
        then do.
            message "Produto ja existe com esta descricao ->" xprodu.procod .
            undo. 
        end.
    end.

    /* nao usado no cat 41 */ 
    /* if par-opc = "ALT" and
       tt-produ.pronom <> produ.pronom and
       substr(tt-produ.pronom,1,1) = "*" and
       substr(tt-produ.pronom,1,3) <> substr(produ.pronom,1,3) 
    then do:
        find first tabmix where tabmix.tipomix = "P" and
                                tabmix.codmix <> 99 and
                                tabmix.promix  = tt-produ.procod  and
                                tabmix.mostruario = yes
                          no-lock no-error.
        if avail tabmix
        then do:
            message "Antes de colocar * favor tirar o produto do MIX "
                        tabmix.codmix
                        view-as alert-box.
            undo.
        end.
    end. */ /*Retirada 30.09.2014 a pedido do comercial*/

    tt-produ.pronomc = substring(tt-produ.pronom,1,30). /* Inc e Alt */

/*    update tt-produ.pronomc.*/
    do on error undo.
        update tt-produ.pronomc.
        if par-opc = "INC"
        then
            find first xprodu where xprodu.pronomc = tt-produ.pronomc
                            use-index ipronom no-lock no-error.   
        if par-opc = "ALT"
        then
            find first xprodu where xprodu.pronomc  = tt-produ.pronomc and
                                    xprodu.procod <> produ.procod
                                    use-index ipronom no-lock no-error.
        if (avail xprodu and par-opc = "INC") or
           (avail xprodu and par-opc = "ALT" and tt-produ.pronomc entered)
        then do.
            message "Produto ja existe com esta Desc.Abreviada ->"
                                                xprodu.procod.
            undo. 
        end.
    end.
 
    if tt-produ.catcod = 31
    then do on error undo.
        update tt-produ.corcod.
        if tt-produ.corcod <> ""
        then do.
            find cor where cor.corcod = tt-produ.corcod no-lock no-error.
            if not avail cor or cor.situacao
            then do.
                message "Valor invalido" view-as alert-box.
                undo.
            end.
            if par-opc = "INC"
            then tt-produ.pronom = tt-produ.pronom + " " + tt-produ.corcod.
        end.
    end.

    tt-produ.pronom = replace(tt-produ.pronom,"("," ").
    tt-produ.pronom = replace(tt-produ.pronom,")"," ").

    do on error undo.
        if par-forcod = 0
        then update tt-produ.fabcod.

        find fabri where fabri.fabcod = tt-produ.fabcod no-lock no-error.
        if not avail fabri
        then do.
            message "Fabricante invalido" view-as alert-box.
            undo.
        end.
        display fabri.fabfant.
    end.

    update tt-produ.proabc.

    if par-opc <> "AltFilho"
    then do on error undo.
        update tt-produ.clacod validate(true, "").
        find first xclase where xclase.clasup = tt-produ.clacod
                          no-lock no-error.
        if avail xclase
        then do:
            message "Classe inválida! Pressione F7 e escolha uma SUBCLASSE."
                view-as alert-box.
            undo.
        end.
        if not can-find (first xclase where xclase.clacod  = tt-produ.clacod
                                        and xclase.clagrau = 4 )
        then do.
            message "Classe inválida! Pressione F7 e escolha uma SUBCLASSE"
                 view-as alert-box.
            undo.
        end.

        find clase where clase.clacod = tt-produ.clacod no-lock no-error.
        if not avail clase
        then do:
            message "Classe inválida! Pressione F7 e escolha uma SUBCLASSE."
                view-as alert-box.
            undo.
        end.
    end.

    display clase.clanom.

    update vtempogar when tt-produ.catcod = 31.

    if par-opc = "IncPai"
    then do.
        run cad_selgrade.p (tt-produ.fabcod,
                            tt-produ.clacod,
                            output vgracod).
        if vgracod = 0
        then undo.
    end.

    do on error undo.
        if par-catcod = 0
        then update tt-produ.catcod.
        find categoria of tt-produ no-lock no-error.
        if not avail categoria
        then do:
            message "Departamento nao cadastrado".
            undo, retry.
        end.
        disp tt-produ.catcod categoria.catnom.
    end.            

    update tt-produ.pvp.

    if par-opc <> "AltFilho"
    then do on error undo:
        update tt-produ.etccod.
        find estac where estac.etccod = tt-produ.etccod no-lock no-error.
        if not avail estac
        then do.
            message "Estacao invalida".
            undo.
        end.
        display estac.etcnom.
    end.

    if par-opc <> "AltFilho"
    then do on error undo.
        update tt-produ.temp-cod.
        find temporada of tt-produ no-lock no-error.
        if not avail temporada
        then do:
            message "Temporada invalida" view-as alert-box.
            undo, retry.
        end.
        display temporada.tempnom.
    end.

    if par-opc = "IncPai"
    then do.
        run cad_selcores.p (tt-produ.fabcod,
                            tt-produ.clacod,
                            tt-produ.temp-cod,
                            0).
        find first ttcores where ttcores.marc no-lock no-error.
        if not avail ttcores
        then undo.
    end.

    scopias = 0.
    /**********************/

    if par-opc begins "INC"
    then do.
        run aliquota-99.
        tt-produ.proipiper = vproipiper.
        disp tt-produ.proipiper.
    end.

    do on error undo.
        update tt-produ.prouncom.
        find unida where unida.unicod = tt-produ.prouncom no-lock no-error.
        if not avail unida
        then do:
            message "Unidade Invalida".
            undo, retry.
        end.
        disp unida.uninom no-label format "x(15)".
    end.

    do on error undo.
        update tt-produ.prounven.
        find bunida where bunida.unicod = tt-produ.prounven no-lock no-error.
        if not avail bunida
        then do:
            message "Unidade Invalida".
            undo, retry.
        end.
        disp bunida.uninom no-label format "x(15)".
    end.

    update tt-produ.procvcom.
                    /* tt-produ.procvven colon 50 */
            
    update tt-produ.protam when tt-produ.catcod <> 41
           tt-produ.prorefter
           mini_pedido.

    if mini_pedido
    then tt-produ.proipival = 1.
    else tt-produ.proipival = 0.

    if tt-produ.catcod = 31
    then
        update vetiqueta.

    if tt-produ.catcod = 41
    then
        disp vpack.

    if tt-produ.catcod = 31
    then do on error undo, retry:
        update vestatus
               help " 0=Normal 1=Brinde 2=Fora de linha 3=Fora do MIX".
        if vestatus > 3
        then undo.
        disp vestatus-d[vestatus + 1] no-label.
    end.
    /*** fim estatus ***/
                
    if categoria.grade = no /*tt-produ.catcod <> 41*/
    then if tt-produ.protam = ""
         then tt-produ.protam = "NAO".

    tt-produ.prozort = fabri.fabfant + "-" + tt-produ.pronom.

    pause 0.            
    update tt-produ.descrevista with frame f-produ.
    /*
    format "x(80)"
                                column-label "Descricao Revista" 
           with frame f-descrevista overlay width 82 row 17
            no-box.
    */
    
    if par-opc begins "Inc" 
    then do with frame fpre2 centered overlay color white/red side-labels
            row 15.
        assign vestmgoper = wempre.empmgoper
               vestmgluc  = wempre.empmgluc.
                           
        if fabri.fabcod = 5027
        then assign
                vestcusto   = 0
                vestmgoper  = 0
                vestmgluc   = 0. 
        else do.
            update 
                vestcusto  colon 20 validate(vestcusto > 0,"")
                vestmgoper colon 20 /*validate(vestmgoper > 0,"")*/
                vestmgluc  colon 20 /*validate(vestmgluc > 0,"")*/ .

            vestcusto = vestcusto - (vestcusto * (par-nfdes / 100)).
            vestcusto = vestcusto + (vestcusto * (par-acrfin / 100)).
            vestcusto = vestcusto + (vestcusto * (par-frete / 100)).

            vestvenda = (vestcusto * (vestmgoper / 100 + 1)) *
                                (vestmgluc / 100 + 1).
                    
            update vestvenda colon 20.
        end.
    end.

    if par-opc = "IncPai" or
       par-opc = "AltPai"
    then do on error undo.
        if par-opc = "IncPai"
        then do. 
            find last bprodu where bprodu.procod <= 900000
                                 exclusive-lock no-error.
            if available bprodu
            then assign par-procod = bprodu.procod + 1.
            else assign par-procod = 400000.
            find last bprodu no-lock.

            /** criando o produpai **/
            tt-produ.procod = par-procod.
            disp tt-produ.procod.
            create produpai.
            assign
                produpai.itecod    = par-procod
                produpai.catcod    = tt-produ.catcod 
                produpai.pronom    = tt-produ.pronom
/***
                produpai.fabcod    = tt-produ.fabcod 
                produpai.clacod    = tt-produ.clacod 
***/
                produpai.gracod    = vgracod
                produpai.temp-cod  = tt-produ.temp-cod.

            run cad_cr_produf.p (input recid(produpai)).        
        end.
        else find current produpai exclusive.

        assign
            produpai.pronom    = tt-produ.pronom 
            produpai.fabcod    = tt-produ.fabcod 
            produpai.clacod    = tt-produ.clacod 
            produpai.datexp    = tt-produ.datexp 
            produpai.prorefter = tt-produ.prorefter.

        for each produ of produpai exclusive.
            assign
                vprocod = produ.procod
                tt-produ.pronom    = produ.pronom
                tt-produ.proindice = produ.proindice.
            run grava-produ.
        end.    
    end.
    
    if par-opc = "Inc" or
       par-opc = "Alt"
    then do on error undo.
        if par-opc = "Inc"
        then do.
            find last bprodu where bprodu.procod <= 900000
                             exclusive-lock no-error.
            if available bprodu
            then assign par-procod = bprodu.procod + 1.
            else assign par-procod = 450000.
            find last bprodu no-lock.

            /** criando o produ **/
            tt-produ.procod = par-procod.
            disp tt-produ.procod.
            create produ.
            assign
                produ.procod    = par-procod
                produ.itecod    = par-procod
                produ.opentobuy = yes.
        end.
        else find current produ exclusive.

        vprocod = par-procod.
        run grava-produ.
    end.

    if par-opc <> "AltFilho"
    then run cad_procar2.p (vprocod).

    do on error undo.
        create senha.
        assign
            senha.funcod = func.funcod
            senha.sensen = func.senha
            senha.sendat = today
            senha.senhor = time
            senha.senalt[1] = if par-opc = "Inc" or 
                                 par-opc = "IncPai"
                              then "Inclusao"
                              else "Alteracao"
            senha.senalt[2] = string(par-procod).
    end.

    /*** Luciane - 22/10/2008 - 19763 ***/
    sresp = no.
    if tt-produ.catcod = 31
    then do:
        message "Deseja salvar as caracteristicas do produto para o site?"
        update sresp.
    end.    
    if sresp 
    then do on error undo:
        pause 0.
        create prodsite.
        prodsite.procod = produ.procod.
        disp prodsite.procod label "Produto......"
             produ.pronom no-label
             with frame f-prodsite.
                    
        prodsite.cc1 = produ.pronom.
        update
            prodsite.cc1      label "Nome Site...."  format "x(50)"
            prodsite.visivel  label "Visivel......"  format "Sim/Nao"
                     help "O produto sera visivel no site Sim/Nao" skip
            prodsite.exportar label "Exportar....."  format "Sim/Nao"
                     help "Exporar o produto para o site Sim/Nao" skip
            prodsite.ci1 label "Ordem no Site"
            with frame f-prodsite overlay side-labels row 9.
                    
        find current prodsite no-lock.

        os-command silent "l:\site\editor.exe " 
                                      value(string(prodsite.procod))
                                      " " value(produ.pronom).                
    end.
end.


procedure aliquota-99:

    if lookup(string(tt-produ.procod),produ-lst) > 0 then return "".

    if tt-produ.pronom matches "*celular*" or
       tt-produ.pronom matches "*chip*" or
       tt-produ.pronom matches "*auto radio*" or
       tt-produ.pronom matches "*auto-radio*" or
       tt-produ.pronom matches "*alto falante*" or
       tt-produ.pronom matches "*alto-falante*" or
       tt-produ.pronom matches "*auto falante*" or
       tt-produ.pronom matches "*auto-falante*" or
       tt-produ.pronom matches "*bateria*" or
       tt-produ.pronom matches "*colchao*" or
       tt-produ.pronom matches "*pneu*" or
       tt-produ.pronom matches "*vivo*" or
       tt-produ.pronom matches "*tim*" or
       tt-produ.pronom matches "*claro*"
    then vproipiper = 99.

end procedure.

procedure grava-produ.

    message "1.0 " produ.itecod " - " produ.corcod view-as alert-box.
    
        assign
            produ.datexp    = today
            produ.proindice = tt-produ.proindice
            produ.pronom    = tt-produ.pronom
            produ.pronomc   = tt-produ.pronomc
            produ.fabcod    = tt-produ.fabcod
            produ.proabc    = tt-produ.proabc
            produ.clacod    = tt-produ.clacod
            produ.catcod    = tt-produ.catcod
            produ.etccod    = tt-produ.etccod
            produ.proipiper = tt-produ.proipiper
            produ.proipival = tt-produ.proipival
            produ.prouncom  = tt-produ.prouncom
            produ.prounven  = tt-produ.prounven
            produ.procvcom  = tt-produ.procvcom
            produ.prorefter = tt-produ.prorefter
            produ.prozort   = tt-produ.prozort
            produ.pvp       = tt-produ.pvp
            produ.descRevista   = tt-produ.descRevista
            produ.descontinuado = tt-produ.descontinuado
            produ.datFimVida    = tt-produ.datFimVida
            produ.proseq    = tt-produ.proseq
            produ.temp-cod  = tt-produ.temp-cod
            produ.protam = tt-produ.protam.

        run criarepexporta.p ("PRODU",
                              if par-opc begins "Inc"
                              then "INCLUSAO" else "ALTERACAO",
                              recid(produ)).

    if tt-produ.catcod = 31
    then produ.corcod    = tt-produ.corcod.

    if tt-produ.catcod = 31 and
       vetiqueta
    then do on error undo:
        find produaux where produaux.procod     = produ.procod
                        and produaux.nome_campo = "Etiqueta-Preco"
                      no-error.
        if not avail produaux
        then do:
            create produaux.
            assign
                produaux.procod     = produ.procod
                produaux.nome_campo = "Etiqueta-Preco".
        end.
        produaux.valor_campo = "Sim". 
    end.

    if tt-produ.catcod = 41 
    then do on error undo:
        find produaux where produaux.procod     = produ.procod
                        and produaux.nome_campo = "Pack"
                        no-error.
        if not avail produaux
        then do:
            create produaux.
            assign
                produaux.procod     = produ.procod
                produaux.nome_campo = "Pack".
        end.
        produaux.valor_campo = string(vpack). 
    end.

    /**** estatus ****/
    if tt-produ.catcod = 31 and vestaTus > 0
    then do on error undo:
        find produaux where produaux.procod     = produ.procod
                        and produaux.nome_campo = "Estatus"
                      no-error.
        if not avail produaux
        then do:
            create produaux.
            assign
                produaux.procod     = produ.procod
                produaux.nome_campo = "Estatus".
        end.
        produaux.valor_campo = string(vestatus).
    end.
    /*** fim estatus ***/

    if produ.catcod = 31 and vtempogar > 0
    then do on error undo:
        find produaux where produaux.procod     = produ.procod
                        and produaux.nome_campo = "TempoGar"
                      no-error.
        if not avail produaux
        then do:
            create produaux.
            assign
                produaux.procod     = produ.procod
                produaux.nome_campo = "TempoGar"
                produaux.exportar   = yes
                produaux.datexp     = today.
        end.
        produaux.valor_campo = string(vtempogar).
    end.

    /*********************/
    if par-opc = "Inc" or
       par-opc = "IncPai"
    then
        for each estab no-lock:
            create estoq.
            assign
                estoq.etbcod    = estab.etbcod
                estoq.procod    = produ.procod
                estoq.estcusto  = vestcusto
                estoq.estdtcus  = (if vestcusto <> estoq.estcusto
                                   then today
                                   else estoq.estdtcus)
                estoq.estvenda  = vestvenda
                estoq.estdtven  = (if vestvenda <> estoq.estvenda
                                   then today
                                   else estoq.estdtven)
                estoq.dtaltpreco = estoq.estdtven
                estoq.estideal  = -1
                estoq.datexp    = today.
        end.
        
end procedure.
