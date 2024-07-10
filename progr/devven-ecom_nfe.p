    /* 
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(19)" extent 4
    initial ["","Marca/Desmarca","Confirma devolver?",""].

def var esqcom2         as char format "x(19)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def temp-table tt-devolver
    field procod like produ.procod
    field movqtm like movim.movqtm
    .
    
def input parameter par-rec         as recid.

def buffer bmovim       for movim.
def var vmovim         like movim.movseq.
def var vtotal      like movim.movpc.
def var vprocod     like produ.procod.
def var vpronom     like produ.pronom format "x(19)".
def buffer xestab   for estab.
def var vpctserv as dec format ">>9.99%".
def var vpctpromoc as dec format ">>9.99%".
def var vdescpromoc as dec format ">,>>9.99".
def var vpctdesc   as dec format ">>9.99%".
def var vdesc      as dec format ">,>>9.99".
def var vperc as dec .


def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.

form
    esqcom1
    with frame f-com1
                 row screen-lines no-box no-labels side-labels column 1 centered
                            overlay.
form
    esqcom2
    with frame f-com2
                 row 22 no-box no-labels side-labels column 1
                 centered overlay.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
pause 0.
find plani  where recid(plani) = par-rec no-lock.
find tipmov of plani no-lock.
assign
    esqcom1 = ""
    esqcom2 = ""
    esqcom1[2] = "Marca/Desmarca"
    esqcom1[3] = "Confirma devolver?"
    .


def var vdisp as char.
vdisp =  "PRODUTOS DA NOTA FISCAL  " + STRING(PLANI.NUMERO) 
            + "  DE  " + string(plani.pladat,"99/99/9999").
display 
"         "   vdisp   format "x(60)"
        with frame fprod centered width 81 no-box color message
                row 5 overlay no-label.
        
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first movim where movim.etbcod = plani.etbcod and movim.placod = plani.placod use-index movim
                                        no-lock no-error.
        else
            find last movim where movim.etbcod = plani.etbcod and movim.placod = plani.placod use-index movim
                                        no-lock no-error.
    else
        find movim where recid(movim) = recatu1 no-lock.
    if not available movim
    then do:
        esqvazio = yes.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run mostra-dados.
    end.
    recatu1 = recid(movim).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next movim where movim.etbcod = plani.etbcod and movim.placod = plani.placod use-index movim
                                        no-lock.
        else
            find prev movim where movim.etbcod = plani.etbcod and movim.placod = plani.placod use-index movim
                                        no-lock.
        if not available movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run mostra-dados.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find movim where recid(movim) = recatu1 no-lock.

            disp esqcom1 with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(movim.movseq)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(movim.movseq)
                                        else "".

            choose field movim.movseq help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5  
                      PF4 F4 ESC return).

            status default "".

        end.
            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5"   
            then do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqregua = yes.
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = int(keyfunction(lastkey)).
                color display message esqcom1[esqpos1] with frame f-com1.
            end.    
        {esquema.i &tabela = "movim"
                   &campo  = "movim.movseq"
                   &where  = "movim.etbcod = plani.etbcod and 
                              movim.placod = plani.placod use-index movim"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio or
           keyfunction(lastkey) = "1" or 
           keyfunction(lastkey) = "2" or 
           keyfunction(lastkey) = "3" or 
           keyfunction(lastkey) = "4" or 
           keyfunction(lastkey) = "5" or 
           keyfunction(lastkey) = "6" or 
           keyfunction(lastkey) = "7" or 
           keyfunction(lastkey) = "8" or 
           keyfunction(lastkey) = "9"  
        then do on error undo, retry on endkey undo, leave:
            form 
                 with frame f-movim 
                      centered side-label row 5 .

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if  (esqcom1[esqpos1] = " 1.Inclusao " or
                    esqvazio) 
                then do:
                end.

                if esqcom1[esqpos1] = " 1.Consulta "
                then do.
                    hide frame frame-a no-pause.
                    hide frame f-com1 no-pause.
                    run not_movim.p ( input recid(plani) ,
                                  input recid(movim)).   
                    view frame frame-a.
                    view frame f-com1 .
                end.
                if esqcom1[esqpos1] = "Marca/Desmarca"
                then do:
                    find first tt-devolver where
                               tt-devolver.procod = movim.procod
                               no-error.
                    if avail tt-devolver
                    then delete tt-devolver.
                    else do:
                        create tt-devolver.
                        tt-devolver.procod = movim.procod.
                    end.           

                end.
                if esqcom1[esqpos1] = "confirma devolver?"
                then do:
                    find first tt-devolver no-error.
                    if not avail tt-devolver
                    then do:
                        message color red/with
                        "Favor marcar os produtos que serao devolvidos."
                        view-as alert-box.
                    end.
                    else do:
                        sresp = yes.
                        run blok-NFe.p (input setbcod,
                                    input "devven-ecom_nfe.p",
                                    output sresp).
                        if sresp
                        then run gera-devolucao.
                        sresp = no.
                    end.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run mostra-dados.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(movim).
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
hide frame fprod   no-pause.
pause 0.

Procedure Mostra-Dados.
    def var vpreco like movim.movpc.
    def var vmarca as char format "x" init "".
    
        vtotal = movim.movqtm  * movim.movpc + movim.movacf - movim.movdes.
        find produ of movim no-lock.
        assign vprocod = produ.procod
               vpronom =  produ.pronom.
        vpreco = (movim.movpc + (movim.movacf / movim.movqtm) -
                                (movim.movdes / movim.movqtm)).
        find first tt-devolver where
                   tt-devolver.procod = vprocod
                   no-error.
        if avail tt-devolver
        then vmarca = "*".
        else vmarca = "".            
        
        display
            vmarca no-label
            movim.movseq        column-label "Seq"      format ">>9"
            vprocod             column-label "Codigo"
            vpronom             column-label "Descricao" format "x(28)"
            movim.movqtm        column-label "Qtd"
            vpreco         column-label "Preco"
            vtotal              column-label "Total"
                with frame frame-a 8 down centered  row 6 no-box width 81
                                        overlay .
   
End Procedure.



procedure gera-devolucao:

    def var vmovseq like com.movim.movseq.
    def var recpla as recid.
    def buffer xestab for ger.estab.
    def buffer bplani for com.plani.
    def buffer cplani for plani.
    def buffer cmovim for movim.
    def var vplacod like com.plani.placod.
    def var vnumero like com.plani.numero.
    def var recmov as recid.    
    
    hide message no-pause.  
    message "Aguarde... Gerando NF.".

    /***
    find last bplani where bplani.etbcod = ger.estab.etbcod and
                           /*bplani.placod >= 2100015567 and */
                           bplani.placod <> ? no-error.
     if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.

    vnumero = 0.
    find last com.plani use-index numero 
                where plani.etbcod = setbcod and
                      plani.emite  = setbcod and
                      plani.serie  = "U"     and
                      plani.movtdc <> 4           
                      no-error. 
    if not avail plani 
    then vnumero = 1. 
    else vnumero = plani.numero + 1.
    
        
    if estab.etbcod = 998 or 
       estab.etbcod = 993 or
       estab.etbcod = 900
    then do: 
        vnumero = 0. 
        for each xestab where xestab.etbcod = 993 or
                              xestab.etbcod = 998 or
                              xestab.etbcod = 900
                                            no-lock,
                                 
            last plani use-index numero 
                    where plani.etbcod = xestab.etbcod and
                          plani.emite  = xestab.etbcod and
                          plani.serie  = "U"       and
                          plani.movtdc <> 4           and
                          plani.pladat >= 08/19/2009.
                      
            if not avail plani 
            then vnumero = 1. 
            else do:
                if vnumero < plani.numero 
                then assign vnumero = plani.numero.
            end.    
        end.
        if vnumero = 1 
        then. 
        else vnumero = vnumero + 1.
    end.   
    ****/
    
    find plani where recid(plani) = par-rec no-lock no-error.
    
    if avail plani
    then do:
    
    create tt-plani. 
    assign tt-plani.etbcod   = plani.etbcod
           tt-plani.placod   = vplacod 
           tt-plani.emite    = plani.emite
           tt-plani.serie    = "U"
           tt-plani.numero   = vnumero 
           tt-plani.movtdc   = 12 
           tt-plani.desti    = plani.emite
           tt-plani.pladat   = today 
           tt-plani.notfat   = plani.desti
           tt-plani.dtinclu  = today 
           tt-plani.horincl  = time 
           tt-plani.notsit   = no 
           tt-plani.hiccod   = 1202 
           tt-plani.opccod   = 1202 
           tt-plani.datexp   = today
           /*tt-plani.platot   = plani.platot
           tt-plani.protot   = plani.protot
           tt-plani.bicms    = plani.bicms
           tt-plani.icms     = plani.icms*/
           tt-plani.bsubst   = plani.bsubst
           tt-plani.icmssubst = plani.icmssubst
           tt-plani.notass = plani.placod
           tt-plani.frete = plani.frete
           .
    
    recpla = recid(tt-plani). 
    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock:

        find first tt-devolver where
                   tt-devolver.procod = movim.procod
                   no-error.
        if avail tt-devolver
        then do:                    
        vmovseq = vmovseq + 1.
        create tt-movim. 
        assign tt-movim.movtdc = tt-plani.movtdc 
               tt-movim.PlaCod = tt-plani.placod 
               tt-movim.etbcod = tt-plani.etbcod 
               tt-movim.movseq = vmovseq 
               tt-movim.procod = movim.procod 
               tt-movim.movqtm = movim.movqtm 
               tt-movim.movpc  = movim.movpc
               tt-movim.movdat = tt-plani.pladat 
               tt-movim.MovHr  = int(time) 
               tt-movim.emite  = tt-plani.emite 
               tt-movim.desti  = tt-plani.desti 
               tt-movim.datexp = tt-plani.datexp
               tt-movim.movalicms = movim.movalicms
               tt-movim.movicms   = movim.movicms    
               tt-plani.platot  = tt-plani.platot + 
                                    (tt-movim.movpc * tt-movim.movqtm)
               tt-plani.protot  = tt-plani.protot +
                                    (tt-movim.movpc * tt-movim.movqtm)
               .
               
               if tt-movim.movicms > 0
               then assign
                        tt-plani.bicms    = tt-plani.bicms +
                                    (tt-movim.movpc * tt-movim.movqtm)
                        tt-plani.icms     = tt-plani.icms + tt-movim.movicms
                        .
                                    
       
        end.                        
    end.
    
    run manager_nfe.p (input "1202",
                       input ?,
                       output sresp). 

    end.
    
    /***
    find tt-ptt-movimhere recid(tt-plani) = recpla no-lock no-error.
    
    /* imprimir nf e atualizar estoque*/

    for each cmovim where cmovim.etbcod = cplani.etbcod 
                     and cmovim.placod = cplani.placod 
                     and cmovim.movtdc = cplani.movtdc 
                     and cmovim.movdat = cplani.pladat no-lock:
                
        run atuest.p (input recid(cmovim), 
                      input "I",    ´
                      input 0).

    end.

    message "Prepare a Impressora. [Enter] Imprime...".
    pause no-message.
    
    run impdev-ecom.p (input recid(cplani)).
                    
    end.
    ***/
end procedure.

