/* cad_produ.p                                                              */
{admcab.i}

def input parameter par-categoria like produ.catcod.

def buffer bestoq for estoq.

def var par-fabcod  like produ.fabcod.
def var vqtdmaxped as int.
def var vestcusto  like estoq.estcusto.
def var vestvenda  like estoq.estvenda.
def var vmarc               as char.

def var vtitulo-infadic     as char.
def buffer dprodu for produ.
def var vatrib-cod         as integer.
def var vatrib-val         as dec.
def var vestad-prod         as integer.
def buffer bprodatrib for prodatrib.
def buffer batributo for atributo.
def var vprocod as int.

def var vbusca as char format "xxxxxxx". 
def var primeiro as log.
def buffer xprodu for produ.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.

def var esqcom1         as char format "x(12)" extent 6
    initial ["","","Consulta","",
             "", "Opcoes"].
def var esqcom2         as char format "x(14)" extent 5
    initial ["Armazena","","Custos","Promocao","Qtd.Max.Pedido"].

def buffer bcategoria for categoria.

def var wpronom like produ.pronom.
def var vpreco      as dec.
def var par-itecod like produ.itecod.
par-itecod = ?.

repeat:
hide frame frame-a no-pause.

def buffer sclase for clase.
def buffer bprodu       for produ.
def var vprodu         like produ.procod.
def var vclacod like produ.clacod.
def var par-rec as recid.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

form
    esqcom2
    with frame f-com2 row screen-lines - 2 no-labels column 1 centered
            title " Armazenagem ".
assign
    recatu1 = ?
    recatu2 = ?
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def buffer cfabri for fabri.
find cfabri where cfabri.fabcod  = par-fabcod no-lock no-error. 
find categoria where categoria.catcod = par-categoria no-lock.
bl-princ:
repeat: 
    display "Tipo: "   
            categoria.catcod  
            categoria.catnom  
        with frame fcategoria 1 down overlay  
                        no-label column 1 row 3 color message no-box.
    if avail cfabri
    then do :
        display "Fabri: "
                cfabri.fabcod 
                cfabri.fabnom format "x(23)"  
                with frame f-fabri 1 down no-box no-label
                    color message row 3 overlay column 43.
    end.


    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find produ where recid(produ) = recatu1 no-lock.
    if not available produ
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(produ).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available produ
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
        if not esqvazio
        then do:
            find produ where recid(produ) = recatu1 no-lock.

            status default "".
            
            run verifica-exclusao.
            display esqcom2
                    with frame f-com2.
            color display message 
                    produ.procod     
                    wpronom          
                    clase.clanom when avail clase
                    fabri.fabfan     with frame frame-a             .
            
            choose field produ.procod help "P Procura"
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0
                      P p
                      page-down   page-up
                      tab PF4 F4 ESC F7 PF7 return).

            color display normal
                    produ.procod     
                    wpronom          
                    clase.clanom when avail clase
                    fabri.fabfan     with frame frame-a.

            status default "".
            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or  
               keyfunction(lastkey) = "7" or  
               keyfunction(lastkey) = "8" or  
               keyfunction(lastkey) = "9" or  
               keyfunction(lastkey) = "0" or
               keyfunction(lastkey) = "P" or
               keyfunction(lastkey) = "p"
            then do with centered row 8 color message no-label
                                frame f-procura side-label overlay:
                if keyfunction(lastkey) <> "HELP" and
                   keyfunction(lastkey) <> "P" and
                   keyfunction(lastkey) <> "p"
                then assign
                        vbusca = keyfunction(lastkey)
                        primeiro = yes.
                pause 0.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                    end.
                find xprodu where xprodu.procod = int(vbusca) no-lock no-error.
                if avail xprodu
                then do:
                    if xprodu.catcod <> par-categoria
                    then do. 
                        find bcategoria of xprodu no-lock.
                        message "Produto e´ " bcategoria.catnom 
                                        view-as alert-box.
                    end.
                    else do.
                        par-fabcod = 0. 
                        vclacod = 0.
                        recatu1 = recid(xprodu).
                    end.
                end.
                leave.
            end.
        end.

/***
        if keyfunction(lastkey) = "P" or
           keyfunction(lastkey) = "p"
        then do on error undo
            with frame f-procura overlay row 6 centered side-label.
            pause 0.
            prompt-for produ.procod format ">>>>>>>>>9" with no-validate.
            find bprodu where bprodu.procod = input produ.procod
                        NO-LOCK no-error.
            if not avail bprodu
            then message "Produto Invalido".
            else recatu1 = recid(bprodu).
            leave.
        end.
***/
            
/***
            if keyfunction(lastkey) = "HELP" /* F7 */
            then do.
                sretorno = "".
                run zprodu.p.
                if sretorno <> ""
                then do.
                    find xprodu where xprodu.procod = int(sretorno) 
                               no-lock no-error.
                    if avail xprodu
                    then do.
                        if xprodu.catcod <> par-categoria then do.
                            find bcategoria of xprodu no-lock.
                            message "Produto e´ " bcategoria.catnom 
                                    view-as alert-box.
                            recatu1 = ?.
                        end.
                        else do.
                            assign
                                par-fabcod = 0
                                vclacod = 0.
                            recatu1 = recid(xprodu).
                        end.
                        leave.
                    end.
                end.
            end.        
***/
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail produ
                    then leave.
                    recatu1 = recid(produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail produ
                    then leave.
                    recatu1 = recid(produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                
                run leitura (input "down").
                if not avail produ
                then next.
                color display white/red produ.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail produ
                then next.
                color display white/red produ.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio  
        then do:
            form 
                 with frame fprodu color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                clear frame f-produ all.
                if esqcom1[esqpos1] = "Inclusao " or 
                        esqvazio
                then do with frame f-produ.
                    par-rec = ?.
                    hide frame f-com1 no-pause.    
                    hide frame f-com2 no-pause.
                    run cad_produman.p ("inc",
                                    par-categoria,
                                    0,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                    
                    find bprodu where bprodu.procod = vprocod no-lock no-error.
                    if avail bprodu
                    then recatu1 = recid(bprodu).
                    view frame f-com1.
                    view frame f-com2.
                    if avail categoria  
                    then do: 
                        pause 0. 
                        display "Tipo: "    
                                categoria.catcod   
                                categoria.catnom   
                                with frame fcategoria width 80. 
                        pause 0.
                    end.
                    leave.
                end.
                if esqcom1[esqpos1] = "Consulta "
                then do with frame f-produ. 
                    vprocod = produ.procod.
                    run cad_produman.p ("Con",
                                    par-categoria,
                                    0,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                    
                end.
                if esqcom1[esqpos1] = "Alteracao "
                then do with frame f-produ.                
                    hide frame f-com1 no-pause.    
                    hide frame f-com2 no-pause.
                    hide frame fsub   no-pause.
                    vprocod = produ.procod.
                    run cad_produman.p ("Alt",
                                    par-categoria,
                                    0,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                    view frame f-com1.
                    view frame f-com2.
                    
                    if avail categoria  
                    then do: 
                        pause 0. 
                        display "Tipo: "    
                                categoria.catcod   
                                categoria.catnom   
                                with frame fcategoria. 
                    end.
                end. 
                if esqcom1[esqpos1] = " Filtro "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run filtro.
                    recatu1 = ?.
                    leave.
                end.
 
            if esqcom1[esqpos1] = "E-Commerce"
            then do.
                hide frame f-com2.
                
                message "Conectando ao banco ECommerce...". 
                if connected ("ecommerce")
                then disconnect ecommerce.
                connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce 
                        -N tcp -ld ecommerce no-error.
                hide message no-pause.

                run prodecom.p (input rowid(produ)).
               
                view frame f-com2.

                if connected ("ecommerce")
                then disconnect ecommerce.
            end.
            assign vtitulo-infadic = "INFORMACOES ADICIONAIS -  "
                                        + produ.pronom.

            if esqcom1[esqpos1] = "Opcoes"
            then do.
                run opcoes.
            end.
            
            if esqcom1[esqpos1] = "Inf.Adic."
            then do on error undo with frame f-inf-adic centered
                   OVERLAY SIDE-LABELS color black/cyan title vtitulo-infadic.
                
                /***********************************************************
                 *******  Usar a tabela DPRODU para a tela Inf.Adic ********
                 ***********************************************************/

                find first dprodu where dprodu.procod = produ.procod
                                exclusive-lock no-error.
                find first produaux where 
                                    produaux.procod     = dprodu.procod and
                                    produaux.nome_campo = "Data_Descontinuado"
                                    no-lock no-error.
                def var vData_Descontinuado as date format "99/99/9999".
                vData_Descontinuado = if avail produaux
                                      then date(produaux.valor_campo)
                                      else ?.
                disp dprodu.descontinuado  at 2 
                     vData_Descontinuado   no-label    
                     dprodu.datfimvida     at 40
                                    format "99/99/9999" label "Data Fim Vida"
                            with width 80.

                find first prodatrib
                     where prodatrib.procod = dprodu.procod
                       and can-find (first atributo
                                   where atributo.atribcod = prodatrib.atribcod
                                     and atributo.tipo = "capacidade")
                                       no-lock no-error.
                if avail prodatrib
                then
                    assign vatrib-cod = prodatrib.atribcod
                           vatrib-val = prodatrib.valor.

                update dprodu.descontinuado  at 2 
                            with width 80.
                            
                if dprodu.descontinuado entered and
                   dprodu.descontinuado = yes
                then do on error undo.
                    find first produaux where 
                                    produaux.procod     = dprodu.procod and
                                    produaux.nome_campo = "Data_Descontinuado"
                                    no-error.
                    if not avail produaux
                    then create produaux.
                    assign produaux.procod      = dprodu.procod
                           produaux.nome_campo  = "Data_Descontinuado"
                           produaux.valor_campo = string(today).
                end.
                if dprodu.descontinuado entered and
                   dprodu.descontinuado = no
                then do on error undo.
                    find first produaux where 
                                    produaux.procod     = dprodu.procod and
                                    produaux.nome_campo = "Data_Descontinuado"
                                    no-error.
                    if not avail produaux
                    then create produaux.
                    assign produaux.procod      = dprodu.procod
                           produaux.nome_campo  = "Data_Descontinuado"
                           produaux.valor_campo = ?.
                end.
                
                vData_Descontinuado = if avail produaux
                                      then date(produaux.valor_campo)
                                      else ?.
                disp dprodu.descontinuado  at 2 
                     vData_Descontinuado   no-label    
                     dprodu.datfimvida     at 40.
                display vatrib-cod format ">>9" at 7 label "Atributo"
                                        with width 80.
                update
                       dprodu.datfimvida     at 40
                                    format "99/99/9999" label "Data Fim Vida"
                            with width 80.
                            
              message "Abrindo Cadastro de Capacidades do Produto... aguarde.".
                                pause 0.
                            
                run cad-atrib-prod2.p (input produ.procod,
                                       input "Capacidade").

                /* Estado do Produto */
                find first bprodatrib
                     where bprodatrib.procod = dprodu.procod
                       and can-find (first atributo
                                   where atributo.atribcod = bprodatrib.atribcod
                                     and atributo.tipo = "estado")
                                       no-lock no-error.
                if avail bprodatrib
                then do:
                
                    assign vestad-prod = bprodatrib.atribcod.
                
                end.

                update vestad-prod format ">>9" at 9 label "Estado".
                            
                if vestad-prod > 0
                then do:
                
                    find first batributo
                         where batributo.atribcod = vestad-prod
                           and batributo.tipo = "estado" no-lock no-error.
                    
                    if avail batributo
                    then display batributo.atribdes no-label.
                    
                    find first bprodatrib
                         where bprodatrib.procod = dprodu.procod
                           and can-find (first atributo
                                  where atributo.atribcod = bprodatrib.atribcod
                                    and atributo.tipo = "estado")
                                        exclusive-lock no-error.
                                            
                        if not avail bprodatrib
                        then do:
                        
                            create bprodatrib.
                            assign bprodatrib.atribcod = vestad-prod
                                   bprodatrib.procod = dprodu.procod.
                                   
                        end.
                    
                        assign bprodatrib.atribcod = vestad-prod.
                
                end.    
                
                do on error undo, retry:

                    update dprodu.temp-cod at 44 label "Temporada" format ">>9"
                            with width 80.

                    find first temporada
                         where temporada.temp-cod = dprodu.temp-cod    
                                    no-lock no-error.
                    
                    if dprodu.temp-cod = 0 or not avail temporada
                    then do:
                    
                        message "Campo Temporada Obrigatório! Pressione F7 e"  ~                               "escolha uma opção." view-as alert-box.
                                
                        undo, retry.

                    end.
                    else display temporada.tempnom no-label .

                    pause .
                end.
            end.

                if esqcom1[esqpos1] = " Cod.EAN "
                then do with frame frame-ean.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run ean.
                    recatu1 = ?.
                    leave.
                end.    
                if esqcom1[esqpos1] = " Precos "
                then do:
                    hide frame f-com1   no-pause.
                    hide frame f-com2   no-pause.
                    sretorno = string(produ.procod).
                    run precos.p (input produ.procod).
                    sretorno = "".
                    if avail categoria
                    then do:
                        pause   0.
                        display "Tipo: "
                                categoria.catcod
                                categoria.catnom
                                with frame fcategoria.
                    end.    
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom1[esqpos1] = " antes era assim Precos "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run precons.p (input string(recid(produ))).                                    if avail categoria  
                    then do: 
                        pause 0. 
                        display "Tipo: "    
                                categoria.catcod   
                                categoria.catnom   
                                with frame fcategoria. 
                    end.                    view frame f-com1.
                    view frame f-com2.
                end.
            end.
            else do with frame f-estab:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

            if esqcom2[esqpos2] = "Qtd.Max.Pedido"
            then do on error undo:
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

        do on error undo.
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
            then do on error undo with frame f-estoq 1 column centered:
                display estoq.estmin estrep estideal estloc 
                        estoq.estatual estpedcom
                        estpedven.
                update estoq.estmin estrep estideal estloc.
            end.
/***
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
***/
            if esqcom2[esqpos2] = "Custos"
            then do with frame f-custos 1 column centered:
                do on error undo
                    with frame fpre222 centered overlay color white/red
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
                    estoq.dtaltpreco = estoq.estdtven.
                    assign estoq.datexp = today.
                end.
            end.
            if esqcom2[esqpos2] = "Promocao"
            then do on error undo with frame f-promo 1 column centered:
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
                       estoq.estproper label "Valor Prom." format ">,>>9.99".
                estoq.dtaltpromoc = today.       
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
                        assign  bestoq.procod      = produ.procod
                                bestoq.etbcod      = estab.etbcod
                                bestoq.estmin      = estoq.estmin
                                bestoq.estrep      = estoq.estrep
                                bestoq.estideal    = estoq.estideal
                                bestoq.estloc      = estoq.estloc
                                bestoq.estcusto    = estoq.estcusto
                                bestoq.estdtcus    = estoq.estdtcus
                                bestoq.estvenda    = estoq.estvenda
                                bestoq.estdtven    = estoq.estdtven
                                bestoq.estprodat   = estoq.estprodat
                                bestoq.estproper   = estoq.estproper
                                bestoq.tabcod      = estoq.tabcod
                                bestoq.dtaltpromoc = estoq.dtaltpromoc
                                bestoq.dtaltpreco  = estoq.dtaltpreco
                                bestoq.datexp      = today.
                    end.
                end.
            end.
/***********************
                if esqcom2[esqpos2] = " Exclusao "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame fsub  no-pause.
                    run exclusao.
                    view frame fsub.
                    view frame f-com1.
                    view frame f-com2.
                    leave.
                end.
                if esqcom2[esqpos2] = " Irmao " 
                then do.
                    message "comentado".
                    /***
                    if produ.corcod <> "" or
                       produ.tamcod <> ""
                    then.
                    else do:
                        if produ.corcod = ""
                        then do.
                            sresp = no.
                            run message.p (input-output sresp,
                                       input "Produto nao tem COR. Confirma ?",
                                       input "" ,
                                       input "Sim",
                                       input "Nao").
                            if sresp = no
                            then leave.
                        end.
                        else do.
                            message "Produto tem que ter TAMANHO".
                            pause 3.
                            leave.
                        end.
                    end.

                    par-rec = recatu1.
                    hide frame f-com1 no-pause.    
                    hide frame f-com2 no-pause.    
                    run cad_produman.p (input "IRMAO",
                                    input par-categoria,
                                    input par-fabcod,
                                    input par-fornec,
                                    input-output par-rec). 
                    recatu1 = par-rec. 
                    par-fabcod = 0. 
                    vclacod = 0.
                    view frame f-com1.
                    view frame f-com2.
                    ***/
                    
                end.
                
                    if avail categoria  
                    then do: 
                        pause 0. 
                        display "Tipo: "    
                                categoria.catcod   
                                categoria.catnom   
                                with frame fcategoria. 
                    end. 

                if esqcom2[esqpos2] = " Garantia "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run progaran.p (input recid(produ)).  
                    if avail categoria  
                    then do: 
                        pause 0. 
                        display "Tipo: "    
                                categoria.catcod   
                                categoria.catnom   
                                with frame fcategoria. 
                    end. 
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = " Tributacao "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run cad_protribu.p ("", input recid(produ)).  
                    if avail categoria  
                    then do: 
                        pause 0. 
                        display "Tipo: "    
                                categoria.catcod   
                                categoria.catnom   
                                with frame fcategoria. 
                    end. 
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Sugestao PV"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run propreco.p (1,produ.procod).  
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Dado Adicional"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run produdad.p (input recid(produ)).  
                    view frame fcategoria.
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Caracteristicas"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run procar.p (input produ.procod).  
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Ativa/Desativa"
                then do on error undo with frame f-produ.
                    find produ where recid(produ) = recatu1 .                 
                    if produ.prosit = no
                    then do:
                        message "Confirma Ativacao de" produ.pronom
                            update sresp.
                        if not sresp
                        then undo, leave.
                        produ.prosit = yes.
                        message "Produto " produ.pronom " ativado ".
                        pause 3 no-message.
                    end.
                    else do:
                        message "Confirma Desativacao de" produ.pronom 
                            update sresp.
                        if not sresp
                        then undo, leave.
                        produ.prosit = no.
                        message "Produto " produ.pronom " desativado ".
                        pause 3 no-message.
                    end.
                    leave.
                end.
***********************/
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(produ).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
hide frame fcategoria no-pause.

if par-itecod = ?
then leave.
end.

procedure frame-a.

vpreco = 0.
vpreco  = 111. /*preco (produ.procod, 
                       setbcod, 
                       today).**/

wpronom = trim(produ.pronom).
          
find first sclase where sclase.clacod = produ.clacod NO-LOCK NO-ERROR. 
IF AVAIL sclase  THEN 
find first clase where clase.clacod = sclase.clacod NO-LOCK NO-ERROR. 
find fabri of produ no-lock no-error.
    display
        produ.procod column-label "Cod" format ">>>>>>>9"
        wpronom format "x(30)"
        produ.proindice column-label "Cod. Barras" format "x(14)"  
        fabri.fabfant when avail fabri  column-label "Fabric" format "x(9)"
        clase.clanom format "x(13)" when avail clase
         /*
display produ.procod    column-label "Codigo" format ">>>>>>>>9"
        wpronom         column-label "Descricao" format "x(20)" 
        produ.proindice
        clase.clanom    format "x(8)" column-label "Classe" when avail clase
        produ.prorefter     format "x(17)" 
        fabri.fabfan    format "x(09)"  column-label "Fabric" when avail fabri 

        vpreco          format ">>>>9.99" column-label "Preco"
        */
        with frame frame-a screen-lines - 11 down centered 
                           row 5 width 80.
end procedure.


procedure EAN.                                                         
vpreco = 0.                                                            
vpreco  = 111. /*preco (produ.procod,  
                      setbcod, 
                       today).  
                       **/
                       
wpronom = trim(produ.pronom).                           
                                                                             
find first sclase where sclase.clacod = produ.clacod no-lock no-error. 
if avail sclase then                                                      
find first clase where clase.clacod = sclase.clacod no-lock no-error.     
find fabri of produ no-lock no-error.                                  
display produ.procod    column-label  "Codigo"                             
        wpronom         column-label  "Descricao" format "x(20)"                
        clase.clanom    format "x(8)"  column-label "Classe" when avail clase   
        produ.prorefter     format "x(17)"                                         
        fabri.fabfan    format "x(09)"  column-label "Fabric" when avail fabri 
        /*produ.proean    column-label "EAN"
        */
        
        with frame frame-ean 11 down centered color white/red row 5.           
do on error undo.
find current produ exclusive.
/*update produ.proean with frame frame-ean.*/

end.
find current produ no-lock.
end procedure.                                                                 


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        if par-fabcod = 0 and
           vclacod = 0
        then
            if par-itecod = ?
            then
                find first produ where 
                                                produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                no-lock no-error.
            else
                find first produ where 
                                    produ.catcod = par-categoria
                                                and produ.itecod = par-itecod
                                                no-lock no-error.
        else
            if par-fabcod <> 0 and
               vclacod = 0
            then   
                if par-itecod = ?
                then
                    find first  produ  where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
                else
                    find first  produ  where produ.catcod       = par-categoria
                                                and produ.itecod = par-itecod
                                                and produ.fabcod = par-fabcod
                                                no-lock no-error.
        
            else
            if par-fabcod = 0 and
               vclacod <> 0
            then   
                if par-itecod = ?
                then 
                    find first  produ where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.clacod  = vclacod
                                                no-lock no-error.
                else
                    find first  produ where produ.catcod = par-categoria
                                                and produ.itecod  = par-itecod
                                                and produ.clacod  = vclacod
                                                no-lock no-error.
            else
                if par-itecod = ?
                then 
                    find first  produ where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.clacod  = vclacod
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
                else
                    find first  produ where produ.catcod = par-categoria
                                                and produ.itecod = par-itecod
                                                and produ.clacod  = vclacod
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
              
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        if par-fabcod = 0 and
           vclacod = 0
        then
            if par-itecod = ?
            then 
                find next produ  
                                        where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                no-lock no-error.
            else
                find next produ 
                                        where produ.catcod = par-categoria
                                                and produ.itecod = par-itecod
                                                no-lock no-error.
        else
            if par-fabcod <> 0 and
               vclacod = 0
            then   
                if par-itecod = ?
                then 
                    find next  produ   where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
                else
                    find next  produ   where produ.catcod = par-categoria
                                                and produ.itecod = par-itecod
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
            else
            if par-fabcod = 0 and
               vclacod <> 0
            then   
                if par-itecod = ?
                then 
                    find next  produ  where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.clacod  = vclacod
                                                no-lock no-error.
                else
                    find next  produ  where produ.catcod = par-categoria
                                                and produ.itecod  = par-itecod
                                                and produ.clacod  = vclacod
                                                no-lock no-error.
            else
                if par-itecod = ?
                then 
                    find next  produ where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.clacod  = vclacod
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
                else
                    find next  produ where produ.catcod = par-categoria
                                                and produ.itecod  = par-itecod
                                                and produ.clacod  = vclacod
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
if par-tipo = "up" 
then                  
        if par-fabcod = 0 and
           vclacod = 0
        then
            if par-itecod = ?
            then 
                find prev produ 
                            where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                no-lock no-error.
            else
                find prev produ  
                            where produ.catcod = par-categoria
                                                and produ.itecod = par-itecod
                                                no-lock no-error.
        else
            if par-fabcod <> 0 and
               vclacod = 0
            then   
                if par-itecod = ?
                then 
                    find prev  produ   where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
                else
                    find prev  produ   where produ.catcod = par-categoria
                                                and produ.itecod  = par-itecod
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
            else
            if par-fabcod = 0 and
               vclacod <> 0
            then   
                if par-itecod = ?
                then 
                    find prev  produ  where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.clacod  = vclacod
                                                no-lock no-error.
                else
                    find prev  produ  where produ.catcod = par-categoria
                                                and produ.itecod = par-itecod
                                                and produ.clacod  = vclacod
                                                no-lock no-error.
            else
                if par-itecod = ?
                then 
                    find prev  produ where produ.catcod = par-categoria
                                                and produ.itecod <> 0
                                                and produ.clacod  = vclacod
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.
                else
                    find prev  produ where produ.catcod = par-categoria
                                                and produ.itecod  = par-itecod
                                                and produ.clacod  = vclacod
                                                and produ.fabcod  = par-fabcod
                                                no-lock no-error.


end procedure.
         
procedure filtro.
        pause 0.
        view frame f-com1. 
        def var vtipobusca as char format "x(55)" extent  11
            init    [
                      "1-Por Fabricante  " ,
                      "2-Setor/Grupo/Classe/Sub-Classe" ,
                      "3-", 
                      "4-", 
                      "5-",  
                      "6-", 
                      "7-", 
                      "8-", 
                      "9-" , 
                      "a-", 
                      "g-GERAL"
                                         ].
        def var ctipobusca as char format "x(20)" extent 11
                             
             init    [  "fabri" , "clase" ,  "", "", "", "",
                        "", "", "", "",
                        "geral"
                                         ].
        
        def var vescolha as char.
        def var rectit as recid.
        def var recag as recid.
        pause 0.
        display " Filtros " at 16
                skip(14)
                with frame fmessage color message row 4
                    width 64 no-box overlay.
        pause 0.
        display vtipobusca at 4
                with frame ftipobusca  column 3
                row 5  no-label overlay  1 column.
        pause 0. 
        choose field vtipobusca auto-return
                     with frame ftipobusca.
        pause 0.
        vescolha = ctipobusca[frame-index].
        hide frame ftipobusca no-pause.
        hide frame fmessage no-pause.
        recag = ?.
        rectit = ?.
        
        /*
        if vescolha = "fonet"
        then do:
            vpalavra = "".
            update "Digite uma Palara para busca" skip
            vpalavra format "x(78)"
                   with frame fbusca
                            centered row 10 overlay color message
                                     no-label.
            i = 0.
            for each bclifor where bclifor.clfnom CONTAINS vpalavra no-lock.
                i = i + 1.
            end.
            if i = 0
            then do:
                message "Nenhum Agente Comercial contendo este Nome".
                pause 3 no-message.
                vgeral = yes.
            end.    
            else do:
                for each wfclifor.
                    delete wfclifor.
                end.    
                for each bclifor where bclifor.clfnom CONTAINS vpalavra no-lock.
                    create wfclifor.
                    assign wfclifor.recag = recid(bclifor)
                           wfclifor.clfnom  = bclifor.clfnom.
                end.
                vtitle = "Busca Fonetica - " + caps(vpalavra).
                hide frame frame-a no-pause.
                recatu1 = ?.
                vgeral = no.
                leave.
            end.
        end.
        */ 
        /*
        
        if vescolha = "nome"
        then do:
                run zclifor.p. 
                find first clifor where 
                                    clifor.cgccpf = (sretorno)
                            no-lock no-error.
                if avail clifor
                then do:
                    vgeral = yes.
                    recatu1 = recid(clifor).
                end.
                else .
                leave.
        end.
        if vescolha = "codigo"
        then do:
            def var vclfcod like clifor.clfcod.
            vclfcod = 0.
            update "Digite o Codigo" vclfcod 
                   with frame fbuscacodigo
                            centered row 10 overlay color message
                                        no-label.
            find first bclifor where bclifor.clfcod >= vclfcod no-lock no-error.
            vgeral = yes.
            if avail bclifor
            then do:
                    vgeral = yes.
                    recatu1 = recid(bclifor).
            end.
            else recatu1 = ?.
            leave.
        end.
        */
        if vescolha = "clase"
        then do:
            run busclase.p (output vclacod).
            clear frame frame-a all no-pause.
            recatu1 = ?.
            leave.
        end.
        if vescolha = "fabri"
        then do:
        {setbrw.i}

            assign a-seeid  = -1 a-recid  = -1  a-seerec = ?.
            {sklcls.i
                &file         = fabri
                &help         =  "ENTER=Produtos do Fabricante   F4=Retorna"
                &cfield       = fabri.fabnom
                &ofield       = " 
                             fabri.fabcod
                             fabri.fabfant
                             fabri.fabdtcad" 
                &where        = "true"
                &color        = withe
                &color1       = red
                &locktype     = " use-index ifabnom " 
                &aftselect1   = " par-fabcod = fabri.fabcod.
                                  leave keys-loop. " 
                &naoexiste1   = "
                                message color red/withe
                                ""Nenhum Fabricante Cadastrado""
                                view-as alert-box title """" .
                                leave. "
                &form         = " frame f-linha1 row 4 down centered
                                  title "" FABRICANTES "" overlay
                                  color with/cyan " } 
        end.        
        if vescolha = "geral"
        then do:
            par-fabcod = 0.
            vclacod = 0.
                     recatu1 = ?.
                     leave.
        end.

end procedure.


procedure verifica-exclusao.
def var vexc as log.

vexc = yes.

esqcom2[2] = "Exclui".

if produ.prodtcad <> today
then vexc = no.

if vexc
then do:
    find first movim where movim.procod = produ.procod no-lock no-error.
    if avail movim
    then vexc = no.
end.
if vexc
then do:
    for each tipped no-lock.
        find first liped where liped.pedtdc = tipped.pedtdc and
                               liped.procod = produ.procod  no-lock no-error.
        if avail liped
        then vexc = no.
    end.
end.


if vexc
then
    for each estoq where estoq.procod = produ.procod no-lock.
        if estoq.estatual <> 0
        then vexc = no.
    end.

if vexc = no
then
    esqcom2[2] = "".

end procedure.


procedure exclusao.
do on error undo.
    find produ where recid(produ) = recatu1 exclusive. 
    for each estoq where estoq.procod = produ.procod.   
        delete estoq.
    end.
    delete produ. 
    recatu1 = ?.
end.
end procedure.



procedure opcoes.

    def var mopcoes as char format "x(20)" extent 2 init ["Tributacao",""].
    def var vopcao  as int.

    if produ.catcod = 41
    then mopcoes[2] = "Mix de Moda".

    disp mopcoes with frame f-opcoes with 1 col no-label col 59.
    choose field mopcoes with frame f-opcoes.
    vopcao = frame-index.
    if vopcao = 1
    then run cad_protribu.p ("", recid(produ)).
    if produ.catcod = 41 and vopcao = 2
    then run cad_mixmprod.p (recid(produ)).

end procedure.


