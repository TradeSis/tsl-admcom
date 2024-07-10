{admcab.i}

find func where func.funcod = sfuncod and
                func.etbcod = setbcod
                no-lock no-error.
def var produ-lst as char init "405853,407721".
def var vqtdmaxped as int.
def var vestatus as int format ">9".
def var v-mva as dec.
def var vestatus-d as char extent 4  FORMAT "X(15)"
    init["NORMAL","BRINDE","FORA DE LINHA","FORA DO MIX"].
def var vetiqueta as log format "Sim/Nao".
def var vproipiper like produ.proipiper.
def var vindex as int.
def var mini_pedido as log format "Sim/Nao".
def var v-ativo as log format "Sim/Nao".
def buffer xclase for clase.
def var vicms       as int.
def var vsenha      like func.senha.
def var vopcao as char format "x(10)" extent 2 initial [" Moveis ","Confeccao"].
def var vestcusto  like estoq.estcusto.
def var vestmgoper like estoq.estmgoper.
def var vestmgluc  like estoq.estmgluc.
def var vtabcod    like estoq.tabcod.
def var vestvenda  like estoq.estvenda.
def var reccont         as int.
def var wetccod         like produ.etccod.
def var wprorefter      like produ.proindice.
def var wfabcod         like produ.fabcod.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura","E-Commerce"].
def var esqcom2         as char format "x(14)" extent 5
            initial ["Armazena","Exclui","Custos","Promocao","Qtd.Max.Pedido"].

def buffer bprodu       for produ.
def buffer cprodu       for produ.
def var vprocod         like produ.procod.
def var vitecod         like produ.itecod.
def var witecod         like item.itecod.
def var vmarc               as char.
def var nome-aux            as character.

def new shared var esqcom3  as character format "x(18)" extent 2
            initial ["Inf. Tecnicas","Desc.Comercial"].
            
def new shared var esqpos3             as integer.

def buffer bestoq for estoq.
def buffer witem for item.

def var vcarcod like caract.carcod.
def var vsubcod like subcaract.subcod.
def var vcardes like caract.cardes.
def var vsubdes like subcaract.subdes.




def var wrsp as l format "Sim/Nao".
    form esqcom1 with frame f-com1
                 row 4 no-box no-labels side-labels column 1.
    form esqcom2 with frame f-com2
                 row screen-lines - 2 title " Armazenagem "
                    no-labels side-labels column 1 width 80.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

def new shared temp-table tt-produ like produ.
/*
def new shared temp-table tt-e-commerce no-undo
    field nome      as character extent 2 format "x(55)" 
    field desccom   as character extent 7
    field exporta   as logical format "Sim/Nao"
    field peso      as decimal
    field altura    as integer
    field largura   as integer
    field profund   as integer
    field voltagem  as integer format ">>>>>9"
    field marca     as character format "x(35)"  
    field estmin    as integer format ">>>>9"
    field informtec as character extent 11.  
     
       
form tt-e-commerce.exporta       label "Exporta E-Commerce"
     tt-e-commerce.nome[1]       label "Descricao" at 10
     tt-e-commerce.nome[2]       no-label at 21
     tt-e-commerce.desccom[1]    label "Desc. Comercial" at 4 format "x(58)"
     tt-e-commerce.desccom[2]    no-label at 1 format "x(78)" 
     tt-e-commerce.desccom[3]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[4]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[5]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[6]    no-label at 1 format "x(78)"
     tt-e-commerce.desccom[7]    no-label at 1 format "x(78)"
     tt-e-commerce.peso          label "Peso"           
     tt-e-commerce.altura        label "Altura"         
     tt-e-commerce.largura       label "Largura"        
     tt-e-commerce.profund       label "Profund."   
     tt-e-commerce.voltagem      label "Voltagem"      
     tt-e-commerce.marca         label "Marca"          
     tt-e-commerce.estmin        label "Est. Minimo" 
                    with frame f-E-commerce width 80 centered
                                      OVERLAY side-labels color black/cyan.

form "                "
     tt-e-commerce.informtec[1]    label "Inf. Tecnicas" at 4 format "x(58)"
     tt-e-commerce.informtec[2]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[3]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[4]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[5]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[6]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[7]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[8]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[9]    no-label at 1 format "x(78)"
     tt-e-commerce.informtec[10]   no-label at 1 format "x(78)"
     tt-e-commerce.informtec[11]   no-label at 1 format "x(78)"
                      with frame f-Ecom-inftec width 80 centered
                      title " Informacoes Tecnicas "
                                OVERLAY side-labels color black/cyan.


form esqcom3 with frame f-E-commerce-aux
                    row screen-lines - 2 title " Inf. Adicionais E-Commerce "
                                   no-labels side-labels column 1 width 80.
     esqpos3   = 1.
            
*/
bl-princ:
repeat:
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2. 
    
    if recatu1 = ?
    then find first produ where true no-lock no-error.
    else find produ where recid(produ) = recatu1 no-lock no-error.
    
    vinicio = yes.
    if not available produ
    then do:
        leave. /* teste */
        /****
        clear frame f-altera all.
        message "Cadastro de Produtos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        form with frame f-altera color black/cyan.
        do with frame f-altera
            on error undo.
                create produ.
                prompt-for produ.itecod colon 15.
                find item where item.itecod = input produ.itecod no-error.
                if not avail item
                then do:
                    message "Deseja Incluir ITEM ?" update wrsp.
                    if not wrsp
                        then undo.
                    do with frame f-inclui1  overlay row 6 1 column centered.
                        create item.
                        update item.itenom
                               item.clacod with no-validate.
                        find last witem exclusive-lock no-error.
                        if available witem
                        then assign witecod = witem.itecod.
                        else assign witecod = 0.
                        {di.v 1 "witecod"}
                        assign item.itecod = witecod.
                    end.
                end.
                else assign
                        produ.itecod = item.itecod
                        produ.pronom = item.itenom.
                display produ.pronom colon 15 label "Descricao".
                /* update produ.protam colon 15 label "Tamanho". */
                update produ.corcod colon 50 label "Cor".
                find cor where cor.corcod = produ.corcod.
                display cor.cornom no-label format "x(20)".
                produ.pronom = produ.pronom + " " /* + produ.protam */
                                + " " + produ.corcod.
                update produ.proindice colon 53 label "Cod.Barras".
                update produ.pronom.
                
                produ.pronom = replace(produ.pronom,"("," ").
                produ.pronom = replace(produ.pronom,")"," ").
                                      
                produ.pronom = replace(produ.pronom,"/"," ").
                produ.pronom = replace(produ.pronom,"&"," ").
                produ.pronom = replace(produ.pronom,"~\"," ").
                                        
                produ.pronomc = substring(produ.pronom,1,30).
                update pronomc format "x(30)" label "Desc.Abreviada".
                
                update produ.fabcod colon 15.
                find fabri where fabri.fabcod = produ.fabcod no-error.
                display fabri.fabfant no-label format "x(20)" when avail fabri.
                
                update produ.proabc label "ABC" colon 15.
                
                DO ON ERROR UNDO:
                    update produ.clacod colon 15 with no-validate .

                    find first xclase where 
                               xclase.clasup = produ.clacod no-lock no-error.
                    if avail xclase
                    then do:
                        message "Classe Superior - Invalida para Cadastro".
                        undo.
                    end.

                    find clase where clase.clacod = produ.clacod no-error.
                    if avail clase
                    then display clase.clanom no-label format "x(20)".
                
                END.
                
                update produ.etccod colon 50.
                find estac where estac.etccod = produ.etccod no-lock no-error.
                if avail estac then display estac.etcnom no-label.
                update produ.fabcod colon 15.
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                disp fabri.fabnom no-label when avail fabri.

                update produ.proabc colon 50.
                
                produ.proipiper = 17.
                vproipiper = 17.
                run aliquota-99.
                produ.proipiper = vproipiper.
                update produ.prouncom colon 15
                       produ.prounven colon 50
                       produ.procvcom colon 15 label "Volumes" 
                     /*  produ.procvven colon 50 */.
                do on error undo:
                    update produ.proipiper
                    colon 15 label "Ali.Icms".
                    vproipiper = produ.proipiper.
                    sresp = no.
                    run valida-aliquota-icms.
                    if sresp = yes then undo ,retry.
                    if produ.proipiper <> 17 and
                       produ.proipiper <> 12 and
                       produ.proipiper <> 99
                    then do:
                        message "Alicota Invalida".
                        undo, retry.
                    end.
                end.
                update produ.protam colon 50 label "Para Montagem"
                            format "x(3)"
                       produ.prorefter colon 15 label "Referencia"
                            WITH OVERLAY SIDE-LABELS.
                if produ.protam = ""
                then produ.protam = "NAO".
                produ.prozort = fabri.fabfant + "-" + produ.pronom.
                do for cprodu:
                    find last cprodu exclusive-lock no-error.
                    if available cprodu
                    then assign vprocod = cprodu.procod.
                    else assign vprocod = 0.
                end.
                {di.v 2 "vprocod"}
                assign produ.procod = vprocod
                       vinicio      = no.
        end.
        ***/
    end.
    
    
    clear frame frame-a all no-pause.
    find fabri of produ no-lock no-error.
    find clase of produ no-lock no-error.
    
    
    display
        produ.procod column-label "Cod" format ">>>>>>>9"
        produ.pronom format "x(30)"
        produ.proindice column-label "Cod. Barras" format "x(14)"  
        fabri.fabfant when avail fabri  column-label "Fabric" format "x(9)"
        clase.clanom format "x(13)" when avail clase
            with frame frame-a 10 down row 5 centered color white/red.
    
    recatu1 = recid(produ).
    
    if esqregua
    then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next produ where true no-lock no-error.
        if not available produ
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        
        find fabri of produ no-lock no-error.
        find clase of produ no-lock no-error.

        display produ.procod
                produ.pronom
                produ.proindice
                fabri.fabfant   when avail fabri
                clase.clanom    when avail clase with frame frame-a.
    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.
    
    repeat with frame frame-a:
        find produ where recid(produ) = recatu1 no-lock no-error.
        choose field produ.pronom
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next produ where true no-lock no-error.
                if not avail produ
                then leave.
                recatu1 = recid(produ).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev produ where true no-lock no-error.
                if not avail produ
                then leave.
                recatu1 = recid(produ).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal
                     esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next produ where true no-lock no-error.
            if not avail produ
            then next.
            color display white/red
                produ.pronom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev produ where true no-lock no-error.
            if not avail produ
            then next.
            color display white/red
                produ.pronom.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
            hide frame frame-a no-pause.
          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.
            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inc1
                        row 5  centered OVERLAY SIDE-LABELS.
                clear frame f-inc1 all.
                disp vopcao no-label with frame f-escolha1
                      centered side-label overlay row 8.
                choose field vopcao with frame f-escolha1.
                do :
                    vindex = frame-index.
                    if frame-index = 1
                    then do:
                        find last bprodu where bprodu.procod >= 400000 and
                                               bprodu.procod <= 449999
                          exclusive-lock no-error.
                        if available bprodu
                        then assign vprocod = bprodu.procod + 1.
                        else assign vprocod = 400000.
                        find last bprodu no-lock.
                    end.
                    if frame-index = 2
                    then do:
                        find last bprodu where bprodu.procod >= 450000 and
                                               bprodu.procod <= 900000
                            exclusive-lock no-error.
                        if available bprodu
                        then assign vprocod = bprodu.procod + 1.
                        else assign vprocod = 450000.
                        find last bprodu no-lock.
                    end.
                end.
                
                for each tt-produ. delete tt-produ. end.
                
                create tt-produ.
                assign tt-produ.procod = vprocod
                       tt-produ.itecod = vprocod
                       tt-produ.datexp = today.
                disp tt-produ.procod colon 15.
                update tt-produ.proindice colon 45 label "Cod.Barras".
                update tt-produ.pronom colon 15 label "Descricao".

                tt-produ.pronomc = substring(produ.pronom,1,30).
                update tt-produ.pronomc format "x(30)" label "Desc.Abreviada".
                
                update tt-produ.corcod colon 50 label "Cor".
                find cor where cor.corcod = tt-produ.corcod no-lock no-error.
                
                display cor.cornom no-label format "x(20)".
                tt-produ.pronom = tt-produ.pronom + " " /* + produ.protam */
                                + " " + tt-produ.corcod.
                
                tt-produ.pronom = replace(tt-produ.pronom,"("," ").
                tt-produ.pronom = replace(tt-produ.pronom,")"," ").
                 
                update tt-produ.fabcod colon 15.
                find fabri where fabri.fabcod = tt-produ.fabcod no-error.
                display fabri.fabfant no-label format "x(20)" when avail fabri.
                update tt-produ.proabc label "ABC" colon 50.
                
                bl_classe:
                repeat on error undo, retry:
                    
                    update tt-produ.clacod colon 15 with no-validate .
                    
                    release xclase.
                    find first xclase where xclase.clasup = tt-produ.clacod
                                            no-lock no-error.
                    if avail xclase                        
                    then do:
                    
                        message "Classe inválida! Pressione F7 e escolha uma"
                                "SUBCLASSE." view-as alert-box.
                                
                        undo, retry bl_classe.        

                    end.
                    else do:
                    
                        if can-find (first xclase
                                     where xclase.clacod = tt-produ.clacod
                                       and xclase.clagrau = 4 )
                        then do:             
                    
                            leave bl_classe.

                        end.
                        else do:
                        
                          message "Classe inválida! Pressione F7 e escolha uma"
                                  "SUBCLASSE." view-as alert-box.
                                     
                          undo,retry bl_classe.
                        
                        end.
                        
                    end.

                end.
                
                find clase where clase.clacod = tt-produ.clacod 
                                 no-lock no-error.
                if avail clase
                then display clase.clanom no-label format "x(20)".
                update tt-produ.catcod colon 15 label "Departamento".
                
                find categoria where categoria.catcod = tt-produ.catcod no-lock.
                disp categoria.catnom no-label.
                /* update tt-produ.propag label "Distribuicao" colon 15. */
                
                do on error undo:
                    update tt-produ.etccod colon 50.
                
                    if tt-produ.etccod = 0
                    then do:
                        message "Estacao invalida.".
                        undo.
                    end.
                    
                    find estac where estac.etccod = tt-produ.etccod
                                     no-lock no-error.
                    if avail estac 
                    then display estac.etcnom no-label.
                    else do:
                        message "Estacao invalida.".
                        undo.
                    end.
                    
                
                end.
                /********************/
                sresp = no.
                if vindex = 1
                then do:
                    message "Deseja incluir/alterar caracteristica?" 
                    update sresp.
                end.
                if vindex = 2 or sresp = yes
                then do on error undo:
                update vcarcod label "Caractreistica" colon 15 .
                if vcarcod > 0 or vindex = 2
                then do:
                    find caract where 
                    caract.carcod = vcarcod no-lock no-error.
                    if not avail caract
                    then do:
                        bell.
                        message "Caracteristica nao cadastrada".
                        pause.
                        undo.
                    end.
                    disp caract.cardes no-label format "x(15)".
                    scopias = vcarcod.
                    update vsubcod colon 50 label "Sub-Caract".
                    find subcaract where subcaract.carcod = caract.carcod and
                                 subcaract.subcar = vsubcod
                                 no-lock no-error.
                    if not avail subcaract
                    then do:
                        bell.
                        message "sub-caracteristica nao cadastrada".
                        pause.
                        undo.
                    end.
                    disp subcaract.subdes no-label format "x(15)".
    
                end.
                /*
                else do:
                    run procar.p(vprocod).
                    find first procaract where procaract.procod = vprocod
                        no-lock no-error.
                    find subcaract where subcaract.subcod = procaract.subcod
                            no-lock no-error.
                    find caract where caract.carcod = subcaract.carcod
                             no-lock no-error.
                    vcarcod = caract.carcod.
                    vsubcod = subcaract.subcod.
                    disp vcarcod caract.cardes
                        vsubcod subcaract.subdes.     
                    pause 1.           
                end.
                */
                end.
                scopias = 0.
                /**********************/
                update tt-produ.fabcod colon 15.
                find fabri where fabri.fabcod = tt-produ.fabcod
                                 no-lock no-error.
                disp fabri.fabnom no-label when avail fabri.
                update tt-produ.proabc colon 50.
                tt-produ.proipiper = 17.
                vproipiper = 17.
                run aliquota-99.
                tt-produ.proipiper = vproipiper.
                update tt-produ.prouncom colon 15
                       tt-produ.prounven colon 50
                       tt-produ.procvcom colon 15 label "Volumes".
                    /* tt-produ.procvven colon 50 */
                    
                do on error undo:
                    update tt-produ.proipiper 
                    colon 15 label "Ali.Icms".
                    sresp = no.
                    vproipiper = tt-produ.proipiper.
                    run valida-aliquota-icms.
                    if sresp = yes then undo ,retry.
                    if tt-produ.proipiper <> 17 and
                       tt-produ.proipiper <> 12 and
                       tt-produ.proipiper <> 99
                    then do:
                        message "Alicota Invalida".
                        undo, retry.
                    end.
                end.
                mini_pedido = no.
                update tt-produ.protam colon 50 label "Para Montagem"
                                            format "x(3)"
                       tt-produ.prorefter colon 15 label "Referencia"  
                       mini_pedido        colon 50  label "Mini-Pedido"
                       WITH OVERLAY SIDE-LABELS.
                if mini_pedido
                then tt-produ.proipival = 1.
                else tt-produ.proipival = 0.
                vetiqueta = no.
                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "Etiqueta-Preco"
                     no-error.
                if avail produaux and
                   valor_campo = "Sim"
                then vetiqueta = yes.
                if tt-produ.catcod = 31
                then do:
                    update vetiqueta label "   Etiqueta Preco"
                    with overlay side-label.
                    if vetiqueta = yes
                    then do:
                        if not avail produaux
                        then do:
                            create produaux.
                            assign
                                produaux.procod = tt-produ.procod
                                produaux.nome_campo = "Etiqueta-Preco"
                                .
                        end.
                        produaux.valor_campo = "Sim". 
                    end.           
                end.
                /**** estatus ****/
                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "Estatus"
                     no-error.
                if avail produaux 
                then vestatus = int(valor_campo).
                else vestatus = 0.
                if tt-produ.catcod = 31
                then do on error undo, retry:
                    update vestatus label "   Estatus" colon 15
                        help " 0=Normal 1=Brinde 2=Fora de linha 3=Fora do MIX"
                            with overlay side-label.
                    if vestatus > 3
                    then undo.
                    disp vestatus-d[vestatus + 1] no-label.
                    if vestaTus > 0
                    then do:        
                        if not avail produaux
                        then do:
                            create produaux.
                            assign
                                produaux.procod = tt-produ.procod
                                produaux.nome_campo = "Estatus"
                                .
                        end.
                        produaux.valor_campo = string(vestatus). 
                    end.           
                end.
                /*** fim estatus ***/
                
                /**** MVA ****/
                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "MVA"
                     no-error.
                if avail produaux 
                then v-mva = dec(valor_campo).
                else v-mva = 0.
                if tt-produ.catcod = 31
                then do on error undo, retry:
                    update v-mva label "   MVA" 
                        help "Infome a Margem do Valor Agregado"
                            with overlay side-label.
                    if v-mva > 0
                    then do:        
                        if not avail produaux
                        then do:
                            create produaux.
                            assign
                                produaux.procod = tt-produ.procod
                                produaux.nome_campo = "MVA"
                                .
                        end.
                        produaux.valor_campo = string(v-mva). 
                    end.           
                end.
                /*** fim MVA ***/

                if tt-produ.protam = ""
                then tt-produ.protam = "NAO".
                tt-produ.prozort = fabri.fabfant + "-" + tt-produ.pronom.
                
                do with frame fpre2 centered overlay color white/red
                                   side-labels row 15 .
                    assign vestmgoper = wempre.empmgoper
                           vestmgluc  = wempre.empmgluc.
                           
                    if fabri.fabcod = 5027
                    then do.
                        vestcusto   = 0.
                        vestmgoper  = 0.
                        vestmgluc   = 0. 
                    end.
                    else do.
                        update vestcusto  colon 20
                               vestmgoper colon 20
                               vestmgluc  colon 20.
                    end.
                    vestvenda = (vestcusto *
                                (vestmgoper / 100 + 1)) *
                                (vestmgluc / 100 + 1).
                    
                    if fabri.fabcod <> 5027
                    then update vestvenda colon 20.

                    /** criando o produ **/
                    create produ.
                    
                    assign produ.procod    = tt-produ.procod
                           produ.itecod    = tt-produ.itecod
                           produ.datexp    = today
                           produ.proindice = tt-produ.proindice
                           produ.pronom    = tt-produ.pronom
                           produ.pronomc   = tt-produ.pronomc
                           produ.corcod    = tt-produ.corcod
                           produ.pronom    = tt-produ.pronom
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
                           produ.protam    = tt-produ.protam
                           produ.prorefter = tt-produ.prorefter
                           produ.prozort   = tt-produ.prozort.
                    run criarepexporta.p ("PRODU",
                                          "INCLUSAO",
                                          recid(produ)).                    
                    if vcarcod > 0 and vsubcod > 0
                    then do:
                        find first procaract where 
                                procaract.procod = produ.procod
                                         no-error.
                        if not avail procaract
                        then do:
                            create procaract.
                            procaract.procod = produ.procod.
                        end.                 
                        procaract.subcod = vsubcod.
                        
                        find first procaract where 
                                       procaract.procod = produ.procod
                                                no-lock no-error.
                    end.    
                    
                    /*********************/
                    
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
                               estoq.tabcod    = vtabcod
                               estoq.estideal = -1
                               estoq.datexp    = today.
                    end.
                
                end.
                do on error undo, return on endkey undo, retry:
                    find first func where func.funcod = sfuncod and
                                          func.etbcod = 999 no-lock no-error.
                    if not avail func
                    then do:
                        message "Funcionario Invalido.".
                        undo, retry.
                    end.
                end.
                create senha.
                assign senha.funcod = func.funcod
                       senha.sensen = func.senha
                       senha.sendat = today
                       senha.senhor = time
                       senha.senalt[1] = "Inclusao"
                       senha.senalt[2] = string(produ.procod).
                       
                /*** Luciane - 22/10/2008 - 19763 ***/
                message "Deseja salvar as caracteristicas do produto para o site ?" update sresp.
                if sresp
                then do:
                    pause 0.
                    
                    create prodsite.
                    
                    prodsite.procod = produ.procod.
                    disp prodsite.procod label "Produto......"
                        with frame f-prodsit.
                    
                    /*
                    find produ where 
                         produ.procod = prodsite.procod no-lock no-error.
                         
                    if not avail produ
                    then do:
                        message "Produto nao cadastrado.".
                        undo.
                    end.
                    else*/ disp produ.pronom no-label with frame f-prodsite.
                    
                    prodsite.cc1 = produ.pronom.
                    
                    update prodsite.cc1      label "Nome Site...."
                           format "x(50)"
                           prodsite.visivel  label "Visivel......" 
                           format "Sim/Nao"
                           help "O produto sera visivel no site Sim/Nao"
                           skip
                           prodsite.exportar label "Exportar....." 
                           format "Sim/Nao"
                           help "Exporar o produto para o site Sim/Nao"
                           skip
                           prodsite.ci1 label "Ordem no Site"
                           with frame f-prodsit overlay side-labels row 9.
                    
                    find current prodsite no-lock.
                    

                    os-command silent "l:\site\editor.exe " 
                                      value(string(prodsite.procod))
                                      " " value(produ.pronom).                
                end.
                       
                /**
                message "Incluir caracteristica para o produto?" update sresp.
                if sresp
                then run procar.p (input produ.procod).
                **/
                
                /*** BLOQUEIO PARA LIBERAÇÃO CTB ***
                produ.proseq = 99.
                create produaux.
                assign
                    produaux.procod = produ.procod
                    produaux.nome_campo = "LIBERA-CTB"
                    produaux.valor_campo = "NAO". 
 
                ***/

                leave.
            end.
            
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "*Alteracao*"
            then do with frame f-alterax centered OVERLAY SIDE-LABELS.
                for each tt-produ.
                    delete tt-produ.
                end.
                create tt-produ.
                assign tt-produ.procod    = produ.procod
                       tt-produ.itecod    = produ.itecod
                       tt-produ.proindice = produ.proindice
                       tt-produ.catcod    = produ.catcod
                       tt-produ.pronom    = produ.pronom
                       tt-produ.fabcod    = produ.fabcod
                       tt-produ.corcod    = produ.corcod
                       tt-produ.proabc    = produ.proabc
                       tt-produ.clacod    = produ.clacod
                       tt-produ.etccod    = produ.etccod
                       tt-produ.pronomc   = produ.pronomc
                       tt-produ.codfis    = produ.codfis
                       tt-produ.prouncom  = produ.prouncom 
                       tt-produ.prounven  = produ.prounven
                       tt-produ.procvcom  = produ.procvcom
                       tt-produ.proipival = produ.proipival
                       tt-produ.proipiper = produ.proipiper
                       tt-produ.protam    = produ.protam
                       tt-produ.proseq    = produ.proseq
                       tt-produ.prorefter = produ.prorefter.

                if produ.proseq = 99
                then v-ativo = no.
                else v-ativo = yes.
                
                display tt-produ.procod @ tt-produ.itecod
                        colon 15
                        tt-produ.proindice colon 50 label "Cod.Barras".
                        
               
                find bprodu where bprodu.procod = input tt-produ.itecod
                                                  no-lock no-error.
                /**display bprodu.pronom @ tt-produ.pronom.**/
                
                display tt-produ.pronom colon 15 label "Descricao"
                        tt-produ.pronomc format "x(30)" label "Desc.Abreviada"
                        tt-produ.corcod colon 50 label "Cor".
                
                find cor where cor.corcod = tt-produ.corcod no-lock no-error.

                display cor.cornom no-label format "x(20)" when avail cor.
                
                find fabri where fabri.fabcod = tt-produ.fabcod 
                                no-lock no-error.
                
                display tt-produ.fabcod colon 15
                        fabri.fabfant no-label format "x(20)" when avail fabri.
                
                display tt-produ.proabc label "ABC" colon 50.

                displa tt-produ.clacod format "->>>>>>>9" colon 15.
                
                find clase where clase.clacod = tt-produ.clacod no-error.
                display clase.clanom no-label format "x(20)" when avail clase.
                
                disp tt-produ.catcod colon 15 label "Departamento".
                
                find categoria where categoria.catcod = tt-produ.catcod no-lock.
                disp categoria.catnom no-label when avail categoria.

                display tt-produ.etccod colon 50.
                
                find estac where estac.etccod = tt-produ.etccod
                                 no-lock no-error.
                if avail estac 
                then display estac.etcnom no-label.
                
                if tt-produ.proipival = 1
                then mini_pedido = yes.
                else mini_pedido = no.
                
                vetiqueta = no.

                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "Etiqueta-Preco"
                     no-lock no-error.
                if avail produaux and
                   valor_campo = "Sim"
                then vetiqueta = yes.
                
                /*** Estatus ***
                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "Estatus"
                     no-lock no-error.
                if avail produaux 
                then vestatus = int(valor_campo).
                else vestatus = 0.
                *** Estatus ***/

                /*** MVA ***/
                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "MVA"
                     no-error.
                if avail produaux 
                then v-mva = dec(produaux.valor_campo).
                else v-mva = 0.
                /*** fim MVA ***/

                find first procaract where 
                        procaract.procod = tt-produ.procod
                        no-lock no-error.
                if avail procaract
                then do:
                    find subcaract where subcaract.subcar = procaract.subcod
                            no-lock no-error.
                    find caract where caract.carcod = subcaract.carcod
                             no-lock no-error.
                    vcarcod = caract.carcod.
                    vsubcod = subcaract.subcar.
                    disp vcarcod colon 15 label "Caracteristica"
                        caract.cardes no-label  format "x(15)"
                        vsubcod colon 50 label "Sub-caract" 
                        subcaract.subdes no-label format "x(15)".     
                end.
                /***************/
                disp 
                    tt-produ.prouncom  colon 15
                    tt-produ.prounven  colon 50
                    tt-produ.procvcom  label "Volumes" colon 15
                    tt-produ.proipiper colon 15 label "Ali.Icms"
                    tt-produ.protam    label "Para Montagem" format "x(3)"
                    colon 50
                    tt-produ.prorefter label "Referencia" colon 15
                    v-ativo colon 15 label "Ativo"
                    mini_pedido label "Mini Pedido" colon 15
                    vetiqueta label "   Etiqueta Preco"
                    vestatus  label "   Estatus"
                    vestatus-d[vestatus + 1] no-label
                    v-mva colon 15 label "MVA"
                      tt-produ.codfis  label "Class.Fiscal" format ">>>>>>>9"
                      WITH OVERLAY SIDE-LABELS.
                    
                if esqcom1[esqpos1] = "Consulta"
                then do:
                    for each estoq of produ:
                        find estab of estoq no-lock.
                        disp estoq.etbcod
                                estatual  (total) format "->>,>>9.99"
                                estpedcom (total)
                                estpedven (total)
                                estpedcom + estatual - estpedven
                                        column-label "Disponiv" (total)
                                estcusto  column-label "CUSTO"
                                estvenda  column-label "PV"
                                with centered overlay row 5 9 down
                                        title "Armazenagem " + produ.pronom
                                                color white/cyan.
                    end.
                end.
            end.
            
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera2 centered 
                    OVERLAY SIDE-LABELS color black/cyan.
                
                for each tt-produ.
                    delete tt-produ.
                end.

                if produ.proseq = 99
                then v-ativo = no.
                else v-ativo = yes.
                
                create tt-produ.
                {produ.i tt-produ produ}

                disp tt-produ.itecod colon 15 format ">>>>>>>9".
                update tt-produ.proindice colon 45 label "Cod.Barras"
                       tt-produ.pronom colon 15.
                /* if tt-produ.pronom <> produ.pronom and
                   substr(tt-produ.pronom,1,1) = "*" and
                   substr(tt-produ.pronom,1,3) <>
                   substr(produ.pronom,1,3) 
                then do:
                    find first tabmix where
                               tabmix.tipomix = "P" and
                               tabmix.codmix <> 99 and
                               tabmix.promix  = tt-produ.procod  and
                               tabmix.mostruario = yes
                                no-lock no-error.
                    if avail tabmix
                    then do:            
                        bell.
                        message  color red/with
                        "Antes de colocar * favor tirar o produto do MIX "
                        tabmix.codmix
                        view-as alert-box.
                        undo.
                    end.
                end. */
                tt-produ.pronomc = substring(produ.pronom,1,30).
                update tt-produ.pronomc 
                       colon 15 format "x(30)" label "Desc.Abreviada".
                update tt-produ.catcod colon 15.
                
                find categoria where categoria.catcod = tt-produ.catcod 
                                        no-lock no-error.
                if not avail categoria
                then do:
                    message "Departamento nao cadastrado".
                    undo, retry.
                end.

                display categoria.catnom no-label.
                
                /* update produ.propag label "Distribuicao" colon 15. 
                find tipdis where tipdis.tipcod = produ.propag 
                                    no-lock no-error.
                if not avail tipdis
                then do:
                    message "Distribuicao nao cadastrada". 
                    undo, retry.
                end.
                display tipdis.tipnom no-label.
                */    
                
                update tt-produ.corcod format "x(5)" colon 15.
                
                find cor where cor.corcod = tt-produ.corcod no-lock no-error.
                if not avail cor
                then do:
                    message "Cor " tt-produ.corcod " nao cadastrada". 
                    undo, retry.
                end.                
                display cor.cornom no-label.
                
                /*
                produ.pronom = produ.pronom + " " /* + produ.protam */
                                + " " + produ.corcod.
                update produ.pronom.
                */
                
                tt-produ.pronom = replace(tt-produ.pronom,"("," ").
                tt-produ.pronom = replace(tt-produ.pronom,")"," ").
        
 
                update tt-produ.fabcod.
                find fabri where
                     fabri.fabcod = tt-produ.fabcod no-lock no-error.
                     
                display fabri.fabfant no-label when avail fabri format "x(15)".
                update tt-produ.proabc label "ABC" colon 15.
                update tt-produ.clacod colon 15 with no-validate.

                find clase where
                     clase.clacod = tt-produ.clacod no-lock no-error.
                display clase.clanom no-label when avail clase.

                do on error undo:
                
                    update tt-produ.etccod.
                    
                    if tt-produ.etccod = 0
                    then do:
                        message "Estacao invalida.".
                        undo.
                    end.
                    find estac where 
                         estac.etccod = tt-produ.etccod no-lock no-error.
                    if avail estac 
                    then display estac.etcnom no-label.
                    else do:
                        message "Estacao invalida.".
                        undo.
                    end.
              
                end.
                if tt-produ.proipival = 1
                then mini_pedido = yes.
                else mini_pedido = no.
                
                /********************/
                
                sresp = no.
                if tt-produ.catcod <> 41
                then do:
                    message "Deseja incluir/alterar caracteristica?"
                    update sresp.
                end.
                if tt-produ.catcod = 41 or sresp
                then do on error undo:
                find first procaract where 
                        procaract.procod = tt-produ.procod
                        no-lock no-error.
                if avail procaract
                then do:
                    find subcaract where subcaract.subcar = procaract.subcod
                            no-lock no-error.
                    find caract where caract.carcod = subcaract.carcod
                             no-lock no-error.
                    if avail caract    then vcarcod = caract.carcod.
                    if avail subcaract then vsubcod = subcaract.subcar.
                    disp vcarcod colon 15 label "Caracteristica"
                        caract.cardes when avail caract no-label  format "x(15)"
                        vsubcod colon 50 label "Sub-caract" 
                        subcaract.subdes when avail subcaract no-label format "x(15)".      
                end.
                update vcarcod label "Caractreistica" colon 15 .
                if vcarcod > 0
                then do:
                    find caract where 
                    caract.carcod = vcarcod no-lock no-error.
                    if not avail caract
                    then do:
                        bell.
                        message "Caracteristica nao cadastrada".
                        pause.
                        undo.
                    end.
                    disp caract.cardes no-label format "x(15)".
                    scopias = vcarcod.
                    update vsubcod colon 50 label "Sub-Caract".
                    find subcaract where subcaract.carcod = caract.carcod and
                                 subcaract.subcar = vsubcod
                                 no-lock no-error.
                    if not avail subcaract
                    then do:
                        bell.
                        message "sub-caracteristica nao cadastrada".
                        pause.
                        undo.
                    end.
                    disp subcaract.subdes no-label format "x(15)".
    
                end.
                /*
                else do:
                    run procar.p(vprocod).
                    find first procaract where procaract.procod = vprocod
                        no-lock no-error.
                    find subcaract where subcaract.subcod = procaract.subcod
                            no-lock no-error.
                    find caract where caract.carcod = subcaract.carcod
                             no-lock no-error.
                    vcarcod = caract.carcod.
                    vsubcod = subcaract.subcod.
                    disp vcarcod caract.cardes
                        vsubcod subcaract.subdes.     
                    pause 1.           
                end.
                */
                end.
                scopias = 0.
                /**********************/
                 vicms = tt-produ.proipiper.
                update tt-produ.prouncom
                       tt-produ.prounven
                       tt-produ.procvcom label "Volumes"
                   /*    produ.procvven  */
                   with overlay side-label.
                do on error undo:   
                update   
                       tt-produ.proipiper 
                       label "Ali.Icms" colon 15 with overlay side-label.
                sresp = no.
                vproipiper = tt-produ.proipiper.
                run valida-aliquota-icms.
                if sresp = yes then undo ,retry.
                end.
                update tt-produ.protam    label "Para Montagem" format "x(3)"
                       tt-produ.prorefter label "Referencia" colon 15
                       WITH OVERLAY SIDE-LABELS.
                do on error undo, retry:
                    update v-ativo            label "Ativo"      colon 15
                        WITH OVERLAY SIDE-LABELS.

                    if ((v-ativo = no and produ.proseq = 0) or
                       (v-ativo = yes and produ.proseq = 99)) and
                       (not avail func or func.funfunc <> "CONTABILIDADE")
                    then do:
                        
                        bell.
                        message "Situacao do produto so pode ser alterada pelo setor FISCAL/CONTABIL." view-as alert-box. 
                        undo, retry.
                    end.   
                end.
                
                update mini_pedido        label "Mini Pedido" colon 15
                                WITH OVERLAY SIDE-LABELS.
                                
                if mini_pedido
                then tt-produ.proipival = 1.
                else tt-produ.proipival = 0.
                
                vetiqueta = no.
                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "Etiqueta-Preco"
                     no-error.
                if avail produaux and
                   produaux.valor_campo = "Sim"
                then vetiqueta = yes.
                if tt-produ.catcod = 31
                then do:   
                    update vetiqueta label "   Etiqueta Preco"
                        with overlay side-label.
                end.
                if not avail produaux and
                    vetiqueta = yes
                then do:    
                    create produaux.
                    assign
                            produaux.procod = tt-produ.procod
                            produaux.nome_campo = "Etiqueta-Preco"
                            produaux.valor_campo = "Sim". 
                end.
                else if avail produaux
                then do:
                    if vetiqueta 
                    then produaux.valor_campo = "Sim".
                    else produaux.valor_campo = "Nao". 
                end.

                /*** Estatus ***/
                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "Estatus"
                     no-error.
                if avail produaux 
                then vestatus = int(produaux.valor_campo).
                else vestatus = 0.
                disp vestatus vestatus-d[vestatus + 1] format "x(12)" no-label.
                if tt-produ.catcod = 31
                then do on error undo, retry:   
                    update vestatus label "   Estatus"
                        help " 0=Normal 1=Brinde 2=Fora de linha 3=Fora do MIX"
                        with overlay side-label.
                    if vestatus > 3
                    then undo, retry.
                end.
                if not avail produaux and
                    vestatus > 0
                then do:    
                    create produaux.
                    assign
                            produaux.procod = tt-produ.procod
                            produaux.nome_campo = "Estatus"
                            produaux.valor_campo = string(vestatus). 
                end.
                else if avail produaux and
                    (vestatus > 0       or
                   int(produaux.valor_campo) > 0)
                then do:
                    produaux.valor_campo = string(vestatus).
                end.
                /**** Fim Estatus ***/

                /*** MVA ***/
                find produaux where
                     produaux.procod = tt-produ.procod and
                     produaux.nome_campo = "MVA"
                     no-error.
                if avail produaux 
                then v-mva = dec(produaux.valor_campo).
                else v-mva = 0.
                disp v-mva.
                if tt-produ.catcod = 31
                then do on error undo, retry:   
                    update v-mva label "   MVA"   colon 15
                        help "Informe a Margem do Valor Agregado"
                        with overlay side-label.
                end.
                if not avail produaux and
                    v-mva > 0
                then do:    
                    create produaux.
                    assign
                            produaux.procod = tt-produ.procod
                            produaux.nome_campo = "MVA"
                            produaux.valor_campo = string(v-mva). 
                end.
                else if avail produaux and
                    (v-mva > 0       or
                   dec(produaux.valor_campo) > 0)
                then do:
                    produaux.valor_campo = string(v-mva).
                end.
                /**** Fim MVA ***/

                tt-produ.codfis = produ.codfis.
                if  avail func and
                    func.funfunc = "CONTABILIDADE"
                then do on error undo, retry:
                    update tt-produ.codfis label "Clas.Fiscal" 
                                           format ">>>>>>>9".
                    find clafis where clafis.codfis = tt-produ.codfis 
                                        no-lock no-error.
                    if not avail clafis
                    then do:
                        message "Classificacao Fiscal Invalida".
                        pause.
                        undo, retry.
                    end.
                end.
                
                                                            
                if tt-produ.proseq = 0 or
                   tt-produ.proseq = 99
                then do:
                    if v-ativo
                    then tt-produ.proseq = 0.
                    else tt-produ.proseq = 99.
                end.

                                
                if tt-produ.protam = ""
                then tt-produ.protam = "NAO".
                tt-produ.prozort = fabri.fabfant + "-" + tt-produ.pronom.
                tt-produ.datexp = today.
                
                find produ where produ.procod = tt-produ.procod no-error.
                if not avail produ then leave.
                {produ.i produ tt-produ}
                run criarepexporta.p ("PRODU",
                                      "ALTERACAO",
                                      recid(produ)).                    
                find produ where
                     produ.procod = tt-produ.procod no-lock no-error.
                
                if vcarcod > 0 and vsubcod > 0
                then do:
                        
                        find first procaract where 
                                procaract.procod = produ.procod no-error.
                        if not avail procaract
                        then do:
                            create procaract.
                            procaract.procod = produ.procod.
                        end.                 
                        procaract.subcod = vsubcod.
                        
                        find first procaract where 
                                       procaract.procod = produ.procod
                                                no-lock no-error.
                end. 
                do on error undo, return on endkey undo, retry:
                   find first func where func.funcod = sfuncod and
                                          func.etbcod = 999 no-lock no-error.
                    if not avail func
                    then do:
                        message "Funcionario Invalido.".
                        undo, retry.
                    end.
                end.
                create senha.
                assign senha.funcod = func.funcod
                       senha.sensen = func.senha
                       senha.sendat = today
                       senha.senhor = time
                       senha.senalt[1] = "Alteracao"
                       senha.senalt[2] = string(produ.procod).
                if vicms <> produ.proipiper
                then senha.senalt[1] = "Alt.Icms".
                /**
                message "Alterar caracteristica do produto?" update sresp.
                if sresp
                then run procar.p (input produ.procod).
                **/
            end.
            
            if esqcom1[esqpos1] = "*Exclusao*"
            then do with frame f-exclui row 4  centered OVERLAY SIDE-LABELS.
                message "Confirma Exclusao de" produ.pronom update sresp.
                if not sresp
                then leave.
                find next produ where true no-error.
                if not available produ
                then do:
                    find produ where recid(produ) = recatu1.
                    find prev produ where true no-error.
                end.
                recatu2 = if available produ
                          then recid(produ)
                          else ?.
                find produ where recid(produ) = recatu1.

                do on error undo, return on endkey undo, retry:
                    find first func where func.funcod = sfuncod and
                                          func.etbcod = 999 no-lock no-error.
                    if not avail func
                    then do:
                        message "Funcionario Invalido.".
                        undo, retry.
                    end.
                end.
                create senha.
                assign senha.funcod = func.funcod
                       senha.sensen = func.senha
                       senha.sendat = today
                       senha.senhor = time
                       senha.senalt[1] = "Exclusao"
                       senha.senalt[2] = string(produ.procod).
                find propg where propg.pednum = produ.procod and
                                 propg.prpdata = today no-error.
                if not avail propg
                then do:
                    create propg.
                    assign propg.pednum  = produ.procod
                           propg.prpdata = today.
                end.
                for each estoq where estoq.procod = produ.procod:
                    delete estoq.
                end.
                find estpro where estpro.procod = produ.procod no-error.
                if avail estpro
                then delete estpro.
                delete produ.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 6 1 column centered
                    on endkey undo, retry:
                prompt-for produ.procod format ">>>>>>>>>9" with no-validate.
                find produ using produ.procod.
                if not avail produ
                then do:
                    message "Produto Invalido".
                    undo.
                end.
                recatu1 = recid(produ).
                leave.
            end.
            if esqcom1[esqpos1] = "E-Commerce"
            then do with frame f-E-commerce centered
                   OVERLAY SIDE-LABELS color black/cyan.

                hide frame f-com2.
                
                clear frame f-E-commerce all no-pause.
                
                message "Conectando ao banco ECommerce...". 
                if connected ("ecommerce")
                then disconnect ecommerce.
        
                connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce -N tcp -ld                                                     ecommerce no-error.

                run prodecom.p (input rowid(produ)).
               
                hide frame f-E-commerce-aux.
                
                view frame f-com2.

                if connected ("ecommerce")
                then disconnect ecommerce.

            end.
          end.

          else do with frame f-estab:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            
            if esqcom2[esqpos2] = "Qtd.Max.Pedido"
            then do:
                view frame frame-a. pause 0.
                do on error undo:
                    find first estoq where 
                               estoq.procod = produ.procod no-lock no-error.
                    if avail estoq
                    then if estoq.estloc <> ""
                         then vqtdmaxped = int(estoq.estloc).
                                        
                    update vqtdmaxped label "Quantidade Maxima por Pedido"
                           with frame f-qtdmaxped centered row 10
                                side-labels overlay.
                end.
                
                for each estoq where estoq.procod = produ.procod.
                    assign estoq.estloc = string(vqtdmaxped).
                    
                    if vqtdmaxped = 0
                    then estoq.estloc = "".
                end.
                
                leave.
                
            end.
                                    
            {estabm.i 2}
            find first wfast no-error.
            if not available wfast
            then leave.
            find estab where recid(estab) = wfast.rec no-lock.
            display estab.etbcod colon 18 estab.etbnom no-label skip
                    produ.procod colon 18
                    produ.pronom with side-labels row 5 centered.
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-error.
            if not available estoq
            then create estoq.
            assign estoq.procod = produ.procod
                   estoq.etbcod = estab.etbcod
                   estoq.datexp = today.

            if esqcom2[esqpos2] = "Armazena"
            then do with frame f-estoq 1 column centered:
                display estoq.estmin estrep estideal estloc 
                        estoq.estatual estpedcom
                        estpedven.
                update estoq.estmin estrep estideal estloc.
            end.
            if esqcom2[esqpos2] = "Exclui"
            then do with frame f-estoqe 1 column centered:
                display estoq.estmin estrep estideal estloc 
                        estoq.estatual estpedcom
                        estpedven.
                message "Confirma Exclusao de Armazenagem"
                update sresp.
                for each wfast:
                    find estab where recid(estab) = wfast.rec no-lock.
                    find estoq where estoq.procod = produ.procod and
                                     estoq.etbcod = estab.etbcod no-error.
                    if available estoq
                    then delete estoq.
                end.
                leave.
            end.
            if esqcom2[esqpos2] = "Custos"
            then do with frame f-custos 1 column centered:
                do with frame fpre222 centered overlay color white/red
                                   side-labels row 15.
                    vestcusto = estoq.estcusto.
                    update estoq.estcusto  colon 20.
                    estoq.estdtcus  = (if vestcusto <> estoq.estcusto
                                       then today
                                       else estoq.estdtcus).
                    vestvenda = estoq.estvenda.
                    update estoq.estvenda colon 20.
                    estoq.estdtven  = (if vestvenda <> estoq.estvenda
                                       then today
                                       else estoq.estdtven).
                    assign estoq.datexp = today.
                end.
            end.
            if esqcom2[esqpos2] = "Promocao"
            then do with frame f-promo 1 column centered:
                prompt-for produ.procod with no-validate.
                find produ using produ.procod no-lock.
                if not avail produ
                then do:
                    message "Produto Invalido".
                    undo.
                end.
                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod.
                update estoq.estprodat 
                       estoq.estproper label "Valor Prom."
                                        format ">,>>9.99".
            end.
            vmarc = "".
            delete wfast.
            for each wfast:
                find estab where recid(estab) = wfast.rec no-lock.
                vmarc = vmarc + string(estab.etbcod) + ",".
            end.
            vmarc = substring(vmarc,1,length(vmarc) - 1).
            message "Duplicar Para Estabelecimentos Marcados" vmarc
                    update sresp.
                if sresp
                then do:
                    for each wfast:
                        find estab where recid(estab) = wfast.rec no-lock.
                        find bestoq where bestoq.procod = produ.procod and
                                          bestoq.etbcod = estab.etbcod no-error.
                        if not available bestoq
                        then create bestoq.
                        assign  bestoq.procod = produ.procod
                                bestoq.etbcod = estab.etbcod
                                bestoq.estmin    = estoq.estmin
                                bestoq.estrep    = estoq.estrep
                                bestoq.estideal  = estoq.estideal
                                bestoq.estloc    = estoq.estloc
                                bestoq.estcusto  = estoq.estcusto
                                bestoq.estdtcus  = estoq.estdtcus
                                bestoq.estvenda  = estoq.estvenda
                                bestoq.estdtven  = estoq.estdtven
                                bestoq.estprodat = estoq.estprodat
                                bestoq.estproper = estoq.estproper
                                bestoq.tabcod   = estoq.tabcod
                                bestoq.datexp   = today.

                    end.
                end.

        end.
        end.
       if keyfunction(lastkey) = "end-error"
       then view frame frame-a.
        find fabri of produ no-error.
        find clase of produ no-error.
        display produ.procod
                produ.pronom
                produ.proindice 
                fabri.fabfant when avail fabri
                clase.clanom when avail clase with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(produ).
   end.
end.

procedure aliquota-99:

        if lookup(string(produ.procod),produ-lst) > 0 then return "".

        if  produ.pronom matches "*celular*" or
            produ.pronom matches "*chip*" or
            produ.pronom matches "*auto radio*" or
            produ.pronom matches "*auto-radio*" or
            produ.pronom matches "*alto falante*" or
            produ.pronom matches "*alto-falante*" or
            produ.pronom matches "*auto falante*" or
            produ.pronom matches "*auto-falante*" or
            produ.pronom matches "*bateria*" or
            produ.pronom matches "*colchao*" or
            produ.pronom matches "*pneu*" or
            produ.pronom matches "*vivo*" or
            produ.pronom matches "*tim*" or
            produ.pronom matches "*claro*"
        then  vproipiper = 99.
end procedure.

procedure valida-aliquota-icms:
    sresp = no.
    
    if lookup(string(produ.procod),produ-lst) > 0 then return "".
    
    if     
        produ.pronom matches "*celular*" or
         produ.pronom matches "*chip*" or
         produ.pronom matches "*auto radio*" or
         produ.pronom matches "*auto-radio*" or
         produ.pronom matches "*alto falante*" or
         produ.pronom matches "*alto-falante*" or
         produ.pronom matches "*auto falante*" or
         produ.pronom matches "*auto-falante*" or
         produ.pronom matches "*bateria*" or
         produ.pronom matches "*colchao*" or
         produ.pronom matches "*pneu*" or
         produ.pronom matches "*vivo*" or
         produ.pronom matches "*tim*" or
         produ.pronom matches "*claro*"
 
    then do:
        if vproipiper = 99
        then.
        else sresp = yes.
    end.
    /*
    else if vproipiper = 99
        then sresp = yes. */
    if sresp = yes
    then do: 
            message "Aliquota invalida. Contate departamento CONTABIL/FISCAL.".
    end. 
end.
