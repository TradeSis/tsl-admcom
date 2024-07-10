/*                  sfmonta-tt                       
*
*    produ.p    -    Esqueleto de Programacao    com esqvazio


            substituir    produ
                          <tab>
*
*/

{cabec.i}  

{setbrw.i}.

def var par-etbcod  like estab.etbcod.
par-etbcod = setbcod.
                        def var prec as recid.

def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.

def var vabtqtd     like abastransf.abtqtd.
def var vconta as int.
def var par-abtsit as char init "TODAS".

def var par-procod  like produ.procod.
def var par-pedexterno  like abastransf.pedexterno init "" label "Pedido Externo".

def var par-cla2-cod  like produ.clacod.

def var vreservas as int.
def var vreserv_ecom like prodistr.lipqtd.

def var cfiltros   as char format "x(25)" extent 8
    init ["Nota Venda","Situacao","Produto","Classe","Tipos","Atendimento","Ped.Externo",""].
def var ifiltros    as int.
def var par-filtro  as char.
par-filtro = "Situacao".

def var cfilclasse  as char format "x(20)" extent 5
    init ["DEPTO","Setor","Grupo","Classe","SubClasse"].
def var ifilclasse  as int.
def var par-filclasse    as char.     

run selabatipo (YES /*todos*/).

def var cnomesit as char.
def var isit as int.   

def var csit         as char format "x(20)" extent 6
    initial [" Todas",
             " Ag.Corte",
             " INtegrada",
             " SEparada",
             " Nf.Emitida",
             " CAncelada"].

def var cabtsit         as char format "x(02)" extent 6
    initial ["TODAS",
             "AC",
             "IN",
             "SE",
             "NE",        
             "CA"].


def var cselatendimento  as char format "x(40)" extent 3
    initial [" Todos",
             " Somente Com Disponibilidade",
             " Somente nao Atendidos"].
 
def var par-filtroatendimento as char.

def var vabatipo-distr like abastipo.abatipo extent 10.
def var vdescr-distr   like abastipo.abatnom extent 10.
def var vabatipo-prior as int extent 10.

def var par-abatipo as char.

def var ventrega as log.
def var recatu1      as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial ["< Filtros  >", ""].
  
def var esqcom2         as char format "x(12)" extent 5
            initial ["" ," "," "," ",
                     "  "].
def var esqhel1         as char format "x(80)" extent 5
     initial [" Prioridades Produto - ",
             "< Filtros  > / ",
             "<  Marca   >/Desmarca o Produto ",
             " Gera Romaneio para os itens marcados",
             " Impressao"].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].

                                                                               
def buffer mestoq for estoq.



def new shared temp-table tt-pedtransf no-undo
    field prioridade    like abastipo.abatpri  
    field etbcod        like abastransf.etbcod
    field abtcod        like abastransf.abtcod
    field abtqtd        like abastransf.abtqtd    
    field atende        as int
    field reserv        as int
    field reservOPER    as char
    field dispo         as int
    field indispo       as int
    index sequencia is unique primary prioridade asc
    index abt is unique etbcod asc abtcod asc.

def temp-table tt-abastransf no-undo
    field dttransf      like abastransf.dttransf
    field abatpri       like abastipo.abatpri
    field dtinclu       like abastransf.dtinclu
    field hrinclu       like abastransf.hrinclu
    field etbcod        like abastransf.etbcod    
    field abtcod        like abastransf.abtcod
    field rec    as recid
    index chave is unique primary 
            dttransf asc 
            abatpri asc 
            dtinclu asc
            hrinclu asc
            abtcod asc
            etbcod asc.

def stream v-disp.

def buffer pestab for estab. 

def temp-table ttselabatipo no-undo
    field abatipo  like abastransf.abatipo 
    field abatpri  like abastipo.abatpri
    field abatnom  like abastipo.abatnom
    field sel   as log  init yes format "*/"
    index x is unique primary abatpri asc abatipo asc.

def var vi as int.
def var vmarca as log format "*/".

def var vprimeiro as log.
def var vbusca    as char label "Produto".
def buffer buprodu for produ.
def buffer buabastransf for abastransf .

def var vabatipo as char.

def var vestoq_depos like estoq.estatual.
def var vatende    like estoq.estatual.
def var vdisponivel as dec.
def var vetbcod    like estab.etbcod column-label "Estabelecimento".
def var vreservado like estoq.estatual  format ">>>9.99".

def buffer bestab for estab.
def buffer babastransf for abastransf.

def new shared temp-table tt-marca no-undo
    field rec as recid
    field etbcod    like abastransf.etbcod
    field qtdcorta  as dec
    index idx is unique primary rec asc
    index idx2                  etbcod asc.

def buffer btt-marca for tt-marca.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1
    recatu1 = ?.

form with frame frame-a no-validate.

/*** {abas/transffun.i} **/


/*
   FRAME-A
*/


procedure frame-a.
def var vi as i.
def var vpri as int.

   if recid(abastransf) <> tt-abastransf.rec
   then find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.

   find first tt-marca where
        tt-marca.rec = recid(abastransf)
        no-error.
   vmarca = avail tt-marca.

   find produ of abastransf no-lock.

    vdisponivel = ?. 
    cnomesit = "...". 
    do isit = 1 to 6 . 
        if cabtsit[isit] = abastransf.abtsit 
        then cnomesit = trim(csit[isit]).  
    end. 

   if abastransf.abtsit = "AC" or
      abastransf.abtsit = "IN" or
      abastransf.abtsit = "SE"
    then   run abas/atendcalc.p    (input abastransf.procod,
                             input recid(abastransf),
                             output vestoq_depos, 
                             output vreserv_ecom,
                             output vreservas,
                             output vatende,
                             output vdisponivel).
   else vatende = abastransf.qtdatend.
   
   find abastipo of abastransf no-lock.


                /**if abastransf.abtsit = "EL" or 
                   abastransf.abtsit = "CA" or
                   abastransf.abtsit = "NE"
                then**/ vabtqtd = abastransf.abtqtd.
                /**else vabtqtd = abastransf.abtqtd - (abastransf.qtdemWMS + abastransf.qtdatend).
                   **/
   
   display 

        vmarca column-label "*" 
        abastransf.abtcod column-label "Pedido"
        abastransf.dttransf  format "999999" column-label "Data"
/*        abastipo.abatpri*/
        abastipo.abatnom format "x(09)" 
        if abastransf.orietbcod = 0    
        then abastransf.etbcod
        else abastransf.orietbcod 
                @ abastransf.orietbcod column-label "Fil!Ori"
        abastransf.procod
        produ.pronom format "x(09)" column-label ""
        vabtqtd @ abastransf.abtqtd format ">>9"

        vdisponivel column-label "Disp!CD" format "->>9"
            when vdisponivel <> ?
         vatende @ abastransf.qtdatend format ">>9" column-label "Ate"
        /*abastransf.abtsit*/
        cnomesit format "x(18)" column-label "Situacao"
        with frame  frame-a 09 down centered  row 5 no-box
         .
end procedure.



l1:
do with frame f-linha:
   
        

        def var vtitle as char.
        vtitle = "".
        if par-etbcod > 500
        then do:
            update par-etbcod label "Filial"
                with frame f1.
        end.
        else disp par-etbcod
                with frame f1.

        disp 
             
             vtitle format "x(50)" no-label
             
             with frame f1 side-label 1 down width 80
                 overlay  row 3 no-box color message.
                
     hide frame f-tot no-pause.
     hide frame f-linha no-pause.
     clear frame f-linha all no-pause.
     
def var vauxtitle as char.

run monta-tt.
        
recatu1 = ?.
hide frame frame-a no-pause.

bl-princ:
repeat:
        vtitle = "".
        do isit = 1 to 6 .
            if cabtsit[isit] = par-abtsit
            then vtitle = vtitle + " SIT:" + trim(csit[isit]). 
        end. 
        /**
        **vtitle = vtitle + " Fil: " + string(par-etbcod).
        **/
            
        if par-filtroatendimento <> ""
        then do:
            vtitle = vtitle + if par-filtroatendimento = "AT"
                              then " Com Disponivel"
                              else " Nao Disponivel".
        end.    

        if par-procod <> 0
        then do:
            find produ where produ.procod = par-procod no-lock no-error.
            vtitle = vtitle + " Produto:" + string(par-procod) + " " + if avail produ
                                then produ.pronom
                                else " ??? ".
        end. 
        if par-pedexterno <> ""
        then do:
            vtitle = vtitle + " Ped. Externo:" + string(par-pedexterno).
        end. 

        if par-cla2-cod <> 0
        then do:
            find sclase where sclase.clacod = par-cla2-cod no-lock no-error.
            vtitle = vtitle + " " + par-filclasse + ": " + string(par-cla2-cod) + " " + if avail sclase
                            then sclase.clanom
                            else " ???".
                            
        end.
        
        

        disp 
             
             vtitle
             
             with frame f1 side-label 1 down width 80
                 overlay  row 3 no-box color message.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-abastransf where recid(tt-abastransf) = recatu1 no-lock.
    if not available tt-abastransf
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        hide message no-pause.
        message "Nenhum registro Encontrado na Filial " par-etbcod.
        run selabatipo (YES /*todos*/).
        run selsituacao.
        if keyfunction(lastkey) = "END-ERROR"
        then leave.
        else do:
            recatu1 = ?.
            next.
        end.    
    end.

    recatu1 = recid(tt-abastransf).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-abastransf
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
            find tt-abastransf where recid(tt-abastransf) = recatu1 no-lock.
            find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.
            find produ of abastransf no-lock.
            find fabri of produ no-lock no-error.
            find mestoq where
                mestoq.etbcod = abastransf.etbcod and
                mestoq.procod = abastransf.procod
                no-lock no-error.

            release plani.
            
            if abastransf.oriplacod <> ?
            then do:
                find first plani where plani.etbcod = abastransf.orietbcod and
                                 plani.placod = abastransf.oriplacod
                        no-lock no-error.
            end.     
            disp
               produ.procod label "Produ" colon 6
               produ.pronom no-label format "x(30)"
               produ.fabcod label "Fabri." format ">>>>>99"
               fabri.fabnom no-label format "x(10)" when avail fabri 
               plani.etbcod when avail plani label "Fil.Ori"
               plani.numero when avail plani label "NF" format ">>>>>>9"
               plani.pladat when avail plani label "De" format "999999"
            
             (if abastransf.pedexterno <> ? 
             then if num-entries(abastransf.pedexterno,"_") > 1
                  then entry(1,abastransf.pedexterno,"_")
                  else abastransf.pedexterno
             else "") @                abastransf.pedexterno
                colon 65
               with frame fsub
               row screen-lines - 3 overlay
               side-labels
               no-box.
            if abastransf.pedexterno <> ?
            then
            color display message abastransf.pedexterno
                                    with frame fsub.


            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and esqpos1 < 4  and
                                           esqhel1[esqpos1] <> ""
                                        then  string(produ.pronom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(produ.pronom)
                                        else "".
            color display message
                abastransf.abtcod
                abastransf.dttransf 
                /*abastipo.abatpri*/
                abastipo.abatnom
                abastransf.orietbcod
                abastransf.procod
                produ.pronom 
                abastransf.abtqtd
                vdisponivel
                abastransf.qtdatend
                /*abastransf.abtsit*/
                cnomesit

               
               with frame frame-a.
           
            find first btt-marca no-error.
            
            esqcom1[3] = if abastransf.abtsit = "AC" or
                            abastransf.abtsit = "IN" or
                            abastransf.abtsit = "SE"
                         then "<Prioridade>"
                         else "".
                    
            esqcom2[1] = if (abastransf.abtsit = "IN" or 
                             abastransf.abtsit = "SE" or 
                             abastransf.abtsit = "AC")
                         then "<  Marca   >"
                         else "".
            
            esqcom2[2] = if avail btt-marca and (abastransf.abtsit = "IN" or
                                                 abastransf.abtsit = "SE" or
                                                 abastransf.abtsit = "AC")
                         then "< Cancela  >"
                         else "".
                         
            
            find first abascorteprod of abastransf no-lock no-error.
            esqcom1[4] = if avail abascorteprod
                         then "< VerCortes>"
                         else "".
            esqcom1[2] = "".
            if abastransf.oriplacod <> ?
            then do:
                find first plani where plani.etbcod = abastransf.orietbcod and
                                 plani.placod = abastransf.oriplacod
                        no-lock no-error.
                if avail plani
                then do:
                    esqcom1[2] = "<NF.Venda>".
                end.
                                        
            end.        
            
            find first tt-marca no-error.
            
            find first btt-marca where btt-marca.qtdcorta > 0 no-error.                  
            esqcom2 = "".        
            disp esqcom1 with frame f-com1.        
            disp esqcom2 with frame f-com2.
                    
            choose field abastransf.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0
                      page-down   page-up
                      tab PF4 F4 ESC return).
            
            color display normal
                abastransf.abtcod
                abastransf.dttransf 
                /*abastipo.abatpri*/
                abastipo.abatnom
                abastransf.orietbcod
                abastransf.procod
                produ.pronom 
                abastransf.abtqtd
                vdisponivel
                abastransf.qtdatend
                /*abastransf.abtsit*/
                cnomesit

               with frame frame-a.
            /**
            if keyfunction(lastkey) >= "0" and 
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                vprimeiro = yes.
                update vbusca
                    editing:
                        if vprimeiro
                        then do:
                            apply keycode("cursor-right").
                            vprimeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                recatu2 = recatu1.
                find buprodu where buprodu.procod = int(vbusca) 
                                    no-lock no-error.
                if avail buprodu
                then do:
                    find first buabastransf where 
                               buabastransf.etbcod = estab.etbcod and
                               buabastransf.abtsit   = par-abtsit      and
                               buabastransf.procod   = buprodu.procod
                               no-lock no-error.
                    if avail buabastransf
                    then recatu1 = recid(buabastransf).
                    else do:
                        recatu1 = recatu2.
                        message "Produto nao se encontra na Distribuicao" .
                        pause 1 no-message.
                    end.    
                    leave.
                end.
                else do:
                    message "Produto nao cadastrado".
                end.    
                recatu1 = recatu2.
                leave.
            end.
            **/
            status default "".

        end.
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
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
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
                    if not avail tt-abastransf
                    then leave.
                    recatu1 = recid(tt-abastransf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-abastransf
                    then leave.
                    recatu1 = recid(tt-abastransf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-abastransf
                then next.
                color display white/red abastransf.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-abastransf
                then next.
                color display white/red abastransf.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            run limpa.
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form produ
                 with frame fprodu color black/cyan
                      centered side-label row 5 .

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                clear frame f-produ all no-pause. 
                hide frame fsub no-pause.
                /*
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do on error undo with frame frame-a.
                    run inclusao.
                    recatu1 = recid(tt-abastransf).
                    leave.        
                end.
                */

                if esqcom1[esqpos1] = "< VerCortes>"
                then do on error undo:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.

                    run abas/cortes.p (input "TELA|" + 
                                    string(abastransf.procod) + "|" +
                                    string(recid(abastransf))).
                                          
                    view frame f-com1.
                    view frame f-com2.
                    
                    run frame-a.
                    
                end.
                
                if esqcom1[esqpos1] = "<NF.Venda>"
                then do:
                    find first plani where 
                            plani.etbcod = abastransf.orietbcod and 
                            plani.placod = abastransf.oriplacod
                            no-lock no-error.
                    if avail plani
                    then  run not_consnota.p (recid(plani)).
                end.

                
                if esqcom1[esqpos1] = "<Prioridade>"
                then do on error undo:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                   run abas/atende.p (input "TELA|" + 
                                string(abastransf.procod) + "|" +
                                string(recid(abastransf))).
                                          
                    /*old run prodistpro.p (string(abastransf.procod)).*/
                    view frame f-com1.
                    view frame f-com2.
                    
                    run frame-a.
                    
                end.

                if esqcom1[esqpos1] = "< Filtros  >"
                then do:
                    pause 0.
                    display 
        "                   P E D I D O S  D E  T R A N S F E R E N C I A "
                    with frame fpor1 centered width 81 no-box color message
                    row 5 overlay.

                    disp cfiltros with frame fpor centered no-labels row 6
                        width 40 
                        title "Filtro Por". 
                    choose field cfiltros with frame fpor.
                    ifiltros = frame-index.
                    par-filtro = cfiltros[ifiltros].        
                    if par-filtro = "Tipos"
                    then do:
                        run selabatipo (no).
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "Situacao"
                    then do:
                        run selsituacao.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "produto"
                    then do:
                        run selproduto.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "Classe"
                    then do:
                        
                        run selclasse.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    
                    if par-filtro = "Atendimento"
                    then do:
                        run selatendimento.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        leave.
                    end.
                    if par-filtro = "Nota venda"
                    then do:
                        prec = ?.
                        run selplani.p (5,output prec).
                        recatu1 = ?.
                        run monta-tt.
                        prec = ?.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        leave.
                    end.
                    if par-filtro = "Ped.Externo"
                    then do:
                        run selpedexterno.
                        recatu1 = ?.
                        run monta-tt.
                        par-pedexterno = "".
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        leave.
                    end.
                    
                    
                    
                    
                    
                     
                end.
                    
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

                if esqcom2[esqpos2] = "<  Marca   >"
                then do on error undo:  
                    recatu2 = recatu1.                
                    find first tt-marca where
                            tt-marca.rec = recid(abastransf)
                            no-error.
                    if avail tt-marca
                    then delete tt-marca.
                    else do:
                        hide message no-pause.
                        sresp = No.
                        find first btt-marca no-error.
                        if not avail btt-marca
                        then do:
                            sresp = yes.
                            run message.p (input-output sresp, 
                                  input " .                                      " +
                                  "..  MARCAR TODOS ????  ..",
                                  input " !! O QUE MARCAR !! ") /*,
                                  input " Sim ",
                                  input " Nao ") */ . 
                            if sresp = yes
                            then do: 
                                for each tt-abastransf. 
                                    create tt-marca.
                                    tt-marca.rec = tt-abastransf.rec.
                                    tt-marca.qtdcorta = 0.
                                end.
                            end.
                            else do: 
                                create tt-marca. 
                                tt-marca.rec = tt-abastransf.rec. 
                                tt-marca.qtdcorta = 0.
                            
                            end.
                        end.
                        else do: 
                            create tt-marca. 
                            tt-marca.rec = tt-abastransf.rec. 
                            tt-marca.qtdcorta = 0.
                        end.
                    end.
                    leave.
                end.
                                     
                if esqcom2[esqpos2] = "< Cancela  >"
                then do on error undo:
                    
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    sresp = yes. 
                            run message.p (input-output sresp, 
                                  input " .                                      " +
                                  "..  CONFIRMA O CANCELAMENTO ????  ..",
                                  input " !! O QUE CANCELAR !! ") /*,
                                  input " Sim ",
                                  input " Nao ") */ . 

                    if not sresp then leave. 
                    for each tt-marca,
                        abastransf where recid(abastransf) = tt-marca.rec 
                                exclusive-lock.
                        do:
                            abastransf.abtsit = "CA".
                            abastransf.canfuncod = sfuncod.
                            abastransf.candt     = today.
                            abastransf.canhr     = time.
                        end.
                    end.
                                 
                    esqpos1 = 1.
                    esqregua  = not esqregua.
                    recatu1 = ?.
                    run  monta-tt.
                    leave.
                end.
                
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-abastransf).
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
hide frame fsub no-pause.
hide frame f1 no-pause.


end. /* l1 */

procedure leitura . 
    def input parameter par-abatipo as char.
    if par-abatipo = "pri" 
    then find first tt-abastransf no-lock no-error.

    if par-abatipo = "seg" or par-abatipo = "down" 
    then find next tt-abastransf no-lock no-error.

    if par-abatipo = "up" 
    then find prev tt-abastransf no-lock no-error.
end procedure.


procedure monta-tt.
def var vsel as log.

    hide message no-pause.
    message "Aguarde" if par-filtroatendimento <> ""
                      then ", Calculando Disponibilidades..."
                      else "...".
    
    
    for each tt-marca.
        delete tt-marca.
    end.    
    for each tt-abastransf.
        delete tt-abastransf.
    end.

    for each ttselabatipo where ttselabatipo.sel = yes.
        
        find abastipo where abastipo.abatipo = ttselabatipo.abatipo no-lock.
        
        vsel = no.
        do isit = 1 to 6 .
            if cabtsit[isit] = "TODAS" then next.
            
            
            if par-abtsit = "TODAS"
            then do:
                if cabtsit[isit] = "CA"
                then next.
            end.    
            else if cabtsit[isit] = par-abtsit 
                 then.
                 else next.
        
        for each abastransf where abastransf.etbcod  = par-etbcod
                            and   abastransf.abtsit  = cabtsit[isit] 
                            and   abastransf.abatipo = ttselabatipo.abatipo
                           no-lock:
    
                                        
            /*
            if par-etbcod <> 0 
            then if par-etbcod <> abastransf.etbcod
                 then next.
            */     
            if par-procod <> 0 
            then if par-procod <> abastransf.procod
                 then next.
            if par-pedexterno <> "" 
            then if not abastransf.pedexterno begins par-pedexterno
                 then next.
                 
           
            if par-cla2-cod <> 0 
            then do:
            
                find produ of abastransf no-lock.
                find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
                if avail sclase
                then do:
                    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
                    if avail clase
                    then do:
                        find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
                        if avail grupo
                        then do:
                            find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
                            if avail setClase
                            then do:
                                find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
                            end.
                        end.
                    end.
                end.                    
                if par-filclasse = "SETOR"
                then do:
                    if par-cla2-cod <> setclase.clacod
                    then next.
                end.
                if par-filclasse = "GRUPO"
                then do:
                    if par-cla2-cod <> grupo.clacod
                    then next.
                end.
                if par-filclasse = "CLASSE"
                then do:
                    if par-cla2-cod <> clase.clacod
                    then next.
                end.
                if par-filclasse = "SUBCLASSE"
                then do:
                    if par-cla2-cod <> sclase.clacod
                    then next.
                end.
            end.

            /*find first tab_box  where tab_box.etbcod   = abastransf.etbcod                     no-lock no-error. 
              */
              
            if par-filtroatendimento = "AT" or
               par-filtroatendimento = "NA"
            then do:
                run abas/atendcalc.p    
                        (input abastransf.procod, 
                         input recid(abastransf), 
                         output vestoq_depos,  
                         output vreserv_ecom,
                         output vreservas, 
                         output vatende, 
                         output vdisponivel).
                if par-filtroatendimento = "AT"
                then do:
                    if vatende > 0
                    then.
                    else next.
                end.  
                if par-filtroatendimento = "NA"
                then do:
                    if vatende > 0
                    then next.
                end. 
            end.
            
            if prec <> ?
            then do:
                find plani where recid(plani) = prec no-lock.
                if abastransf.orietbcod = plani.etbcod and
                   abastransf.oriplacod = plani.placod
                then.
                else next.   
            end.
            vsel= yes.
            create tt-abastransf. 
            tt-abastransf.dtinclu   = abastransf.dtinclu.
            tt-abastransf.hrinclu   = abastransf.hrinclu.
            tt-abastransf.dttransf = abastransf.dttransf. 
            tt-abastransf.abatpri = abastipo.abatpri. 
            /*tt-abastransf.box     = if avail tab_box 
                                    then tab_box.box
                                     else 0.*/
                                     
            tt-abastransf.etbcod = abastransf.etbcod.
            tt-abastransf.abtcod  = abastransf.abtcod.
            tt-abastransf.rec = recid(abastransf).

            
        end.
        end.
        ttselabatipo.sel = vsel.

    end.
      
    hide message no-pause.
    
end procedure.


PROCEDURE p-imp.

message "p-imp".
pause.
/*
run selabatipo.
find first ttselabatipo where sel = yes no-error.
if not avail ttselabatipo
then do:
    message "Nenhum abatipo selecionado".
    leave.
end.
            
  def var cTitRel as char.
  def var vmarca  a s log  format " * / ".
  def var vabatipo   as log  format "Sim/Nao".
  def var vescabatipo as char.
  pause 0.
   /*
   display 
        vdescr-distr with frame fchoose1 overlay title " abatipo de Distribuicao " 
                     row 6 col 5 no-label 1 col. 
                     pause 0.
   choose field vdescr-distr with frame fchoose1.
   vescabatipo = "".
   if frame-index > 1
   then vescabatipo = vabatipo-distr[frame-index - 1].
    hide frame fchoose1 no-pause.
   */ 
    vabatipo = no.
    

  message "Imprimir somente produtos disponiveis?" update vabatipo.
      
      
  varqsai = westab.dirrel + "abastransf" + string(time).
  cTitRel = "PROGRAMACAO DE ABASTECIMENTO -_-_-_ " +
             (if vabtsit = "A"
              then " ABERTOS " 
              else (if vabtsit = "P"
                    then " APROVADOS "
                    else " ATENDIDOS/CANCELADOS") ).

  {mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "96"
    &Page-Line = "66"
    &Nom-Rel   = ""abastransf""
    &Nom-Sis   = """BS"""
    &Tit-Rel   = "cTitRel"
    &Width     = "96"
    &Form      = "frame f-cabcab"}

  disp "Estabelecimento: " Estab.EtbCod "-" Estab.EtbNom 
       "Itens:"  tt-Estab.QtdProdu
       "Qtd:"    tt-Estab.Qtd     skip(1)
       with frame f-Cab down no-labels width 92.

for each ttselabatipo where ttselabatipo.sel = yes,
    each tt-abastransf where tt-abastransf.abatipo = ttselabatipo.abatipo
    break by tt-abastransf.chave
          by tt-abastransf.pronom.

   find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.
   find produ of abastransf no-lock.
   find fabri of produ no-lock.

   find first tt-marca where tt-marca.rec = recid(abastransf) no-error.
   vmarca = avail tt-marca.

   if first-of(tt-abastransf.chave)
   then do:
      if par-ordem = "GRUPO"
      then do.
         put unformatted
             fill("-", 96) skip
             "GRUPO: " tt-abastransf.chave skip.
      end.
      if par-ordem = "LOCAL"
      then do.
         find localizacao where localizacao.loccod = tt-abastransf.chave
                             no-lock no-error.
         find pestab where pestab.etbcod = abastransf.etbcod no-lock.
         put unformatted
            
             fill("-", 96) skip(1)
             string("LOCALIZACAO: " + tt-abastransf.chave + " - " +
              (if avail localizacao 
               then localizacao.locnom 
               else "Sem localizacao"),"x(40)")
              " - "
              string(abastransf.etbcod,"99") +
              string(day(today),"99")    + 
              string(month(today),"99")  + " - Filial : " +
              string(abastransf.etbcod,"99") + " " +
              pestab.etbnom
               skip(1).
      end.
   end.

      vdisponivel = disponivel(abastransf.procod).
       
      if not atende(abastransf.procod, abastransf.abatipo, abastransf.abtqtd, 
                    output vatende)  and
         vabatipo
      then next.
      
      find estoq where estoq.etbcod = setbcod and
                       estoq.procod = produ.procod no-lock no-error.
/***
      if not Atende(abastransf.procod, abastransf.abatipo,
                    abastransf.abtqtd,  output vatende)
      then next.
***/
      if vabatipo  and  
         vatende <= 0
      then next.   
      def var vlinha as char format "xxxx" init "....".
      display 
/**         vmarca          column-label "*"    **/
         abastransf.abtqtd column-label "Qtd" format ">>9"
         vlinha column-label ""
         abastransf.abatipo   column-label "Tip" format "xxx"
         abastransf.procod
         fabri.fabnom    format "x(7)" column-label "Fabric"
         produ.pronom    format "x(14)"
         estoq.estatual  column-label "Estoq" 
                    format "->>>9" when avail estoq
         vdisponivel column-label "Disp" format "->>>9"
/*        (if abastransf.qtdatend = 0
        then vatende
        else abastransf.qtdatend) @ abastransf.qtdatend */
         vatende        column-label "Atd"   format ">>9"
         abastransf.dttransf format "999999"
/*         abastransf.qtdatend*/
         (vatende <= 0) label "" format " * * / " 
         with frame f-rel down width 110 no-box .   
    
    down with frame f-rel.
end.
put unformatted skip fill("-", 96).
   
{mdadmrod.i
    &Saida     = "value(varqsai)"
    &NomRel    = """abastransf"""
    &Page-Size = "64"
    &Width     = "96"
    &Traco     = "96"
    &Form      = "frame f-rod3"}.
*/
    
end procedure.


procedure limpa.

for each tt-marca.
   find abastransf where recid(abastransf) = tt-marca.rec exclusive.
   /*
   if abastransf.abtsit = "A" and
      abastransf.abrcod = 0
   then    abastransf.qtdatend = 0.
   */
   
   delete tt-marca.
end.

end procedure.


procedure selabatipo.
def input parameter par-todos as log.

    for each abastipo no-lock.
        find first ttselabatipo where
            ttselabatipo.abatipo = abastipo.abatipo
            no-error.  
        if not avail ttselabatipo
        then do:    
            create ttselabatipo.
            assign 
                ttselabatipo.abatpri = abastipo.abatpri. 
                ttselabatipo.abatipo = abastipo.abatipo.
                ttselabatipo.abatnom = abastipo.abatnom.
        end.
        if par-todos
        then ttselabatipo.sel = yes.    
        vi = vi + 1.
    end.    
if vi = 1
then return.
if par-todos
then return.

    form
            ttselabatipo.sel  no-label
            ttselabatipo.abatpri
            ttselabatipo.abatipo
            ttselabatipo.abatnom
            with frame f-sel 10 down overlay
                    row 7 column 40 width 40 title " Selecione os Tipos ".
    pause 0.
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    status default " ENTER = Marca/Desmarca   F4 Continua".
    {sklclstb.i
        &color = withe
        &color1 = red
        &file       = ttselabatipo
        &Cfield     = ttselabatipo.abatipo
        &OField     = " ttselabatipo.sel ttselabatipo.abatnom ttselabatipo.abatpri" 
        &Where      = " true " 
        &AftSelect1 = " pause 0.
                        ttselabatipo.sel = not ttselabatipo.sel.
                        disp ttselabatipo.sel with frame f-sel.
                        pause 0.
                       next keys-loop. "
        &LockType  = "  "
        &form       = " frame f-sel " 
    }.                
    hide frame f-sel no-pause.
    if keyfunction(lastkey) = "END-ERROR" 
    then do:
    
        leave.
    end.
    
end procedure.



procedure selsituacao.
do on error undo. 
    display  
        csit
            with frame f-selsit 1 down overlay
                    row 8 column 40 width 40 title " Selecione a Situacao "
                    no-labels.

    choose field csit
        with frame f-selsit. 
    if cabtsit[frame-index] <> "" 
    then do:
        par-abtsit = cabtsit[frame-index].
        recatu1 = ?.
        run monta-tt.
        
    end.
    
end.
hide frame f-selsit no-pause.

end procedure.





hide frame f-selsit no-pause. 




procedure selproduto.


        update par-procod 
                with frame fcab overlay row 3 color message side-label width 80
                no-box.

end.

procedure selpedexterno.


        update par-pedexterno
                with frame fcab overlay row 3 color message side-label width 80
                no-box.

end.



procedure selclasse.

def var vx as int.
def var p-clasup as int.

        update par-cla2-cod 
                with frame fcab2 overlay row 3 color message side-label width 80
                no-box.

    find clase where clase.clacod = par-cla2-cod no-lock no-error.
    if avail clase
    then do:
        p-clasup = clase.clasup.
        do vx = 1 to 5.
            find clase where clase.clacod = p-clasup no-lock no-error.
            if not avail clase
            then leave.
            p-clasup = clase.clasup.
        end.
        par-filclasse = cfilclasse[vx].
        hide message no-pause.
        message par-filclasse.
    end.
    else par-cla2-cod = 0.    
    

hide frame fcab2 no-pause.
end procedure.



procedure selatendimento.
    par-filtroatendimento = "".
    disp 
        cselatendimento
                with frame fatend overlay row 10 side-label width 60
                no-labels centered.
    choose field cselatendimento
                        with frame fatend.
    if trim(cselatendimento[frame-index]) = "Todos"
    then par-filtroatendimento = "".
    if trim(cselatendimento[frame-index]) = "Somente Com Disponibilidade"
    then par-filtroatendimento = "AT".
    if trim(cselatendimento[frame-index]) = "Somente Nao Atendidos"
    then par-filtroatendimento = "NA".

    hide frame fatend no-pause.
end.



