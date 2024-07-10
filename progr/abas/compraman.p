/*                                   
*
*/

{cabec.i}  

{setbrw.i}.

def input param par-parametros as char. 

def var vclien as char.
def var vendedor as char.
def var vnumero as char.
def var vpladat like plani.pladat.
def var vconta as int.
def var par-abatipo like abascompra.abatipo.
def var par-abcsit  like abascompra.abcsit.
def var par-etbcod  like abascompra.etbcod init 0.
def var par-forcod  like abascompra.forcod. 
def var par-procod  like produ.procod.

par-abatipo = entry(1,par-parametros).
par-abcsit  = entry(2,par-parametros).



def var cfiltros   as char format "x(25)" extent 7
    init ["Filial","Fornecedor","Produto","Tipos","Situacao",""].
def var ifiltros    as int.
def var par-filtro  as char.
par-filtro = "Situacao".

def var csit         as char format "x(20)" extent 4
    initial [
             " AB - ABertas",
             " PE - Pedidas",
             " EN - ENtregues",
             " CA - CAnceladas"].
             
def var cabcsit         as char format "x(02)" extent 4
    initial [
             "AB",
             "PE",
             "EN",
             "CA"].


def var cselatendimento  as char format "x(40)" extent 3
    initial [" Todos",
             " Somente Com Disponibilidade",
             " Somente nao Atendidos"].
 
def var par-filtroatendimento as char.

def var vabatipo-distr like abastipo.abatipo extent 10.
def var vdescr-distr   like abastipo.abatnom extent 10.
def var vabatipo-prior as int extent 10.

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
    initial [" Filtros"," "," ", " "," Imprime"].
  
def var esqcom2         as char format "x(12)" extent 5
            initial ["" ," "," "," ",
                     "  "].
def var esqhel1         as char format "x(80)" extent 5
     initial [""].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].

                                                                               
def buffer mestoq for estoq.

def temp-table tt-abascompra no-undo
    field dtpreventrega      like abascompra.dtpreventrega
    field etbcod        like abascompra.etbcod
    field abccod        like abascompra.abccod
    field rec    as recid
    index chave is unique primary 
            dtpreventrega asc 
            etbcod asc 
            abccod asc.

def stream v-disp.

def buffer pestab for estab. 

def var vi as int.
def var vmarca as log format "*/".

run p1.
procedure p1.

vi = 1.
for each abastipo where abastipo.permiteincmanual = yes
    no-lock.
    vabatipo-distr[vi] = abastipo.abatipo.
    vdescr-distr[vi] = string(vi, "9") + "." + abastipo.abatnom .    
    vabatipo-prior[vi] = abastipo.abatpri.
    vi = vi + 1.
end.
end procedure.
              
def var vabcqtd   as dec.

def var vprimeiro as log.
def var vbusca    as char label "Produto".
def buffer buprodu for produ.
def buffer buabascompra for abascompra .

def var vabatipo as char.
def buffer xestab for estab.

def var vetbcod    like estab.etbcod column-label "Estabelecimento".

def buffer bestab for estab.
def buffer babascompra for abascompra.

def temp-table tt-estab no-undo 
    field etbcod    like estab.etbcod
    field nro    as   int  column-label "Nro"  format ">>>>>"
    
    index etb is primary unique etbcod.

def temp-table tt-forne no-undo 
    field forcod    like forne.forcod
    field nro    as   int  column-label "Nro"  format ">>>>>"
    
    index etb is primary unique forcod.
 
def new shared temp-table tt-marca  no-undo
    field marca as log format "*/ "
    field rec as recid
    field procod like abascompra.procod
    field etbcod like abascompra.etbcod
        index x is unique primary procod asc etbcod asc rec asc.

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

/*** {abas/comprafun.i} **/


/*
   FRAME-A
*/


procedure frame-a.
def var vi as i.
def var vpri as int.

   if recid(abascompra) <> tt-abascompra.rec
   then find abascompra where recid(abascompra) = tt-abascompra.rec no-lock.

   find first tt-marca where
        tt-marca.rec = recid(abascompra)
        no-error.
   vmarca = avail tt-marca.

   find produ of abascompra no-lock.
   find abastipo of abascompra no-lock.

    find abastransf where
            abastransf.etbcod = abascompra.etbcod and
            abastransf.abtcod = abascompra.abtcod 
            no-lock no-error.
   
   display 

        vmarca column-label "*" 
        abascompra.abccod
        abascompra.dtpreventrega  format "999999" column-label "Data"
        abastipo.abatnom format "x(10)" 
        abascompra.etbcod
        abastransf.orietbcod when avail abastransf
        abastransf.abtsit    when avail abastransf
        abascompra.procod
        produ.pronom format "x(12)" column-label ""
        abascompra.abcqtd 

        abascompra.qtdEntregue
        abascompra.abcsit
        abascompra.pednum when abascompra.pednum <> ?

        with frame  frame-a 09 down centered  row 5 no-box
         .
end procedure.



l1:
repeat on endkey undo, leave with frame f-linha:
   
        
        def var vtitle as char.
                
     hide frame f-tot no-pause.
     hide frame f-linha no-pause.
     clear frame f-linha all no-pause.
     par-etbcod = if par-abatipo = "NEO"
                  then 900
                  else 0.
     update
         par-etbcod label "Fil"
         with frame f1.
     
     par-forcod = 0.
     update
        par-forcod
            with frame f1.
            
     find forne where forne.forcod = par-forcod no-lock no-error.
     if not avail forne and par-forcod <> 0
     then do:
        message "Fornecedor nao cadastrado".
        undo.
     end.    
     disp forne.fornom  format "x(12)" no-label
            when avail forne
            with frame f1.
    run monta-tt.
def var isit as int.   
        
recatu1 = ?.
hide frame frame-a no-pause.

bl-princ:
repeat:
        
        
        do isit = 1 to 4.
            if cabcsit[isit] = par-abcsit
            then vtitle = " SIT: " + csit[isit]. 
        end.
        
        if par-etbcod <> 0
        then vtitle = vtitle + " Filial: " + string(par-etbcod).

        if par-filtroatendimento <> ""
        then do:
            vtitle = vtitle + if par-filtroatendimento = "AT"
                              then " Com Disponivel"
                              else " Nao Disponivel".
        end.    
        
        

        find forne where forne.forcod = par-forcod no-lock no-error.
        disp 
            par-etbcod
            par-forcod
                par-abatipo
            forne.fornom   when avail forne

             vtitle format "x(30)" no-label
             
             with frame f1 side-label 1 down width 80
                 overlay  row 3 no-box color message.


    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-abascompra where recid(tt-abascompra) = recatu1 no-lock.
    if not available tt-abascompra
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        hide message no-pause.
        message "Nenhum registro Encontrado na Situacao " par-abcsit.
        run selsituacao.
        if keyfunction(lastkey) = "END-ERROR"
        then leave.
        else do:
            recatu1 = ?.
            next.
        end.    
    end.

    recatu1 = recid(tt-abascompra).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-abascompra
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
            find tt-abascompra where recid(tt-abascompra) = recatu1 no-lock.
            find abascompra where recid(abascompra) = tt-abascompra.rec no-lock.
            find produ of abascompra no-lock.
            find fabri of produ no-lock no-error.
                    find pedid where 
                            pedid.etbcod = abascompra.etbped and
                            pedid.pednum = abascompra.pednum and
                            pedid.pedtdc = abascompra.pedtdc
                            no-lock no-error.
            
            
            find mestoq where
                mestoq.etbcod = abascompra.etbcod and
                mestoq.procod = abascompra.procod
                no-lock no-error.

            release plani.
            
            esqcom2[1] = "".
            if abascompra.abtcod <> ?
            then do:
                find abastransf where abastransf.etbcod = abascompra.etbcod and
                                      abastransf.abtcod = abascompra.abtcod 
                                      no-lock no-error.
                if avail abastransf
                then do:
                    find first plani where plani.etbcod = abastransf.orietbcod and
                                           plani.placod = abastransf.oriplacod
                            no-lock no-error.
                    if avail plani
                    then do:
                        esqcom2[1] = "NF.Origem". 
                    end.
                end.                                
            end.        
             
            find forne where forne.forcod = abascompra.forcod no-lock no-error.
            disp
               abascompra.forcod label "Forne"
                    forne.fornom no-label when avail forne
               produ.procod label "Produ" colon 6
               produ.pronom no-label format "x(30)"
               produ.fabcod label "Fabri." format ">>>>>99"
               fabri.fabnom no-label format "x(10)" when avail fabri 
               plani.etbcod when avail plani label "Fil.Ori"
               plani.numero when avail plani label "NF" format ">>>>>>9"
               plani.pladat when avail plani label "De" format "999999"
               mestoq.estatual format "->>>9" label "Disp Lj"   colon 70
                              when avail mestoq           
               abascompra.etbped abascompra.pednum 
               pedid.clfcod when avail pedid label "Forne"
               pedid.comcod when avail pedid label "Comprador"
                             with frame fsub
               row screen-lines - 5 overlay
               side-labels
               no-box.
            color display message mestoq.estatual
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
                abascompra.abccod
                abascompra.dtpreventrega 
                abastipo.abatnom
                abascompra.etbcod
                abascompra.procod
                produ.pronom 
                abascompra.abcqtd
                abascompra.qtdentregue                abascompra.abcsit

               
               with frame frame-a.
           
            find first btt-marca no-error.
            
            esqcom1[1] = " Filtros".                
            esqcom1[2] = " Consulta".                
            
            esqcom1[3] = if par-abcsit = "AB" and 
                            par-forcod <> 0 and 
                            abascompra.forcod = par-forcod   
                         then " Marca"
                         else if avail pedid
                              then " Pedido"
                              else "".
            esqcom1[4] = if par-abcsit = "AB"
                         then " Gera OC"
                              else "".
            esqcom2[1] = if par-abcsit = "AB" and
                            abascompra.abatipo <> "ESP"
                         then " Quantidade"
                         else "".
            disp esqcom1 with frame f-com1.        
            disp esqcom2 with frame f-com2.
                    
            choose field abascompra.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0
                      page-down   page-up
                      tab PF4 F4 ESC return).
            
            color display normal
                abascompra.abccod
                abascompra.dtpreventrega 
                abastipo.abatnom
                abascompra.etbcod
                abascompra.procod
                produ.pronom 
                abascompra.abcqtd
                abascompra.qtdentregue
                abascompra.abcsit

               with frame frame-a.
            
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
                    find first buabascompra where 
                               buabascompra.etbcod = estab.etbcod and
                               buabascompra.abcsit   = par-abcsit      and
                               buabascompra.procod   = buprodu.procod
                               no-lock no-error.
                    if avail buabascompra
                    then recatu1 = recid(buabascompra).
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
                    if not avail tt-abascompra
                    then leave.
                    recatu1 = recid(tt-abascompra).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-abascompra
                    then leave.
                    recatu1 = recid(tt-abascompra).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-abascompra
                then next.
                color display white/red abascompra.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-abascompra
                then next.
                color display white/red abascompra.procod with frame frame-a.
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
                /*
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do on error undo with frame frame-a.
                    run inclusao.
                    recatu1 = recid(tt-abascompra).
                    leave.        
                end.
                */
                
                if esqcom1[esqpos1] = "Prioridade"
                then do on error undo:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                   run abas/atende.p (input "TELA|" + 
                                string(abascompra.procod) + "|" +
                                string(recid(abascompra))).
                                          
                    /*old run prodistpro.p (string(abascompra.procod)).*/
                    view frame f-com1.
                    view frame f-com2.
                    
                    run frame-a.
                    
                end.

                if esqcom1[esqpos1] = " Filtros"
                then do:
                    pause 0.
                    display 
        "                   S U G E S T A O  D E  C O M P R A S"
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
                        run selabatipo .
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
                    if par-filtro = "Filial"
                    then do:
                        run selestab.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "Fornecedor"
                    then do:
                        run selforne.
                        recatu1 = ?.
                        run monta-tt.
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
                    if par-filtro = "Atendimento"
                    then do:
                        run selatendimento.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        leave.
                    end.
                    
                    
                    
                     
                end.
                    
                
                
                
                if esqcom1[esqpos1] = " Marca "
                then do:
                    find first tt-marca where
                            tt-marca.rec = recid(abascompra)
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
                           message "Marcar TODOS???" 
                                view-as alert-box
                                    question
                                    buttons yes-no
                                update sresp.
                            if sresp = yes
                            then do: 
                                for each tt-abascompra.
                                    find abascompra where recid(abascompra) =
                                        tt-abascompra.rec no-lock.
                                    if abascompra.forcod <> par-forcod
                                    then next.           
                                    create tt-marca.
                                    tt-marca.marca = yes.
                                    tt-marca.rec = tt-abascompra.rec.
                                end.
                                hide message no-pause.
                                recatu1 = ?.
                                leave. 
                            end.
                            else do:
                                create tt-marca.
                                tt-marca.marca = yes.
                                tt-marca.rec = tt-abascompra.rec.
                            end.
                        end.
                        else do: 
                            create tt-marca. 
                            tt-marca.marca = yes.
                            tt-marca.rec = tt-abascompra.rec.
                        end.
                    end.       
                end.
                if esqcom1[esqpos1] = " Gera OC "
                then do with frame f-preLista: 
                    find first btt-marca no-error. 
                    if not avail btt-marca
                    then do. 
                        create tt-marca.  
                        tt-marca.marca = yes.
                        tt-marca.rec = tt-abascompra.rec.
                    end.
                     
                    hide frame fsub no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    
                    run geraoc.
                    recatu1 = ?.
                    run monta-tt.
                    
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta"
                then do:
                    vclien = "".
                    vendedor = "".
                    vnumero  = "".
                    vpladat = ?.
                    if abascompra.abtcod <> ?
                    then do:
                        find abastransf where 
                            abastransf.etbcod = abascompra.etbcod and
                            abastransf.abtcod = abascompra.abtcod 
                                      no-lock no-error.
                        if avail abastransf
                        then do:
                            find first plani where 
                                    plani.etbcod = abastransf.orietbcod and
                                    plani.placod = abastransf.oriplacod
                                no-lock no-error.
                            if avail plani
                            then do:
                                vpladat = plani.pladat.
                                vnumero = string(plani.numero) + "/" +
                                          plani.serie  .
                                vclien = string(plani.desti,">>>>>>>>9").
                                find clien where 
                                    clien.clicod = plani.desti 
                                no-lock no-error.
                                if avail clien
                                then vclien = vclien + " " + clien.clinom.
                                
                                vendedor = string(plani.vencod,">>>>>>9"). 
                                find func where 
                                        func.funcod = plani.vencod 
                                    no-lock no-error.
                                if avail func
                                then vendedor = vendedor + " " + func.funnom.
                            end.         
                        end.
                    end.                   
                    pause 0.
                    disp abascompra.abccod at 1 label "  Pedido  "
                                    format ">>>>>>>>9"
                         vendedor at 1 label "  Vendedor"  format "x(40)"
                         vclien   at 1 label "  Cliente "  format "x(40)"
                         vnumero  at 1 label "  Numero Venda"
                            format "xxxxxxxxx"
                         vpladat              label "Data Venda"
                         abascompra.etbcod label "Filial Entrega" format ">>9"
                     abascompra.abcobs[1]      label "Observacao" format "x(60)"
                     abascompra.abcobs[2]      at 13  no-label    format "x(60)"
                     abascompra.abcobs[3]      at 13  no-label    format "x(60)"
                     abascompra.abcobs[4]      at 13  no-label    format                                 "x(60)" 
                     with frame f-add 1 down  color message
                        row 5 side-label no-box width 80 overlay.
                    
                    
                        find produ of abascompra no-lock.
                        disp abascompra.procod
                             produ.pronom format "x(30)"
                             abascompra.lipcor
                             abascompra.abcqtd column-label "Qtd.Ped" format ">>>9"
                             abascompra.qtdentregue column-label "Qtd.Ent" format ">>>9"
                                    with frame f-con centered
                                            color black/cyan width 80
                                            row 15 1 down.
                    pause message "Consultando...".
                end.
                
                if esqcom1[esqpos1] = " pedido"
                then do:
                    find pedid where 
                            pedid.etbcod = abascompra.etbped and
                            pedid.pednum = abascompra.pednum and
                            pedid.pedtdc = abascompra.pedtdc
                            no-lock no-error.
                    
                    if avail pedid
                    then do:
                        hide frame f-com1 no-pause.
                        hide frame f-com2 no-pause.
                        hide frame frame-a no-pause.
                        run abas/co_occons.p (recid(pedid)).
                    end.    
                
                end.
                               
               
                if esqcom1[esqpos1] = " xImprime "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run p-imp.
                    recatu1 = ?.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

                if esqcom2[esqpos2] = " Quantidade"
                then do on error undo:
                    find current abascompra exclusive.
                    message "Quantidade Original" abascompra.qtdori.
                    update abascompra.abcqtd.
                end.
 
                if esqcom2[esqpos2] = "NF.Origem"
                then do:
                    find abastransf where abastransf.etbcod = abascompra.etbcod and
                                          abastransf.abtcod = abascompra.abtcod no-lock.
                    find first plani where plani.etbcod = abastransf.orietbcod and
                                           plani.placod = abastransf.oriplacod
                            no-lock no-error.
                    if avail plani
                    then  run not_consnota.p (recid(plani)).
                end.
 
                         
                if esqcom2[esqpos2] = " Elimina "
                then do on error undo:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    sresp = no. 
                    run message.p (input-output sresp,
                        input " .                                      " +
                              " . C O N F I R M A                      " +
                              " . ELIMINAR DISTRIBUICAO ? ",
                        input "" ,
                        input " Sim ",
                        input " Nao ").
                    if not sresp then leave. 

                    find abascompra where recid(abascompra) = tt-abascompra.rec
                        exclusive.
                    abascompra.abcsit = "C".
                    recatu2 = recid(tt-abascompra).
                    
                    /* Facilitar a exclusao de varios registros */
                    recatu1 = recid(tt-abascompra).
                    run leitura("down").
                    if not avail tt-abascompra then do.
                        find tt-abascompra where recid(tt-abascompra) = recatu1
                                         no-lock.
                        run leitura("up").
                        if not avail tt-abascompra
                        then recatu1 = ?.
                        else recatu1 = recid(tt-abascompra).
                    end.
                    else recatu1 = recid(tt-abascompra).

                    find tt-abascompra where recid(tt-abascompra) = recatu2.
                    delete tt-abascompra.
                    view frame f-com1.
                    view frame f-com2.
                    if recatu1 = ?
                    then leave bl-princ.
                end.
                
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
        recatu1 = recid(tt-abascompra).
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
    def input parameter par-tipo as char.
    if par-tipo = "pri" 
    then find first tt-abascompra no-lock no-error.

    if par-tipo = "seg" or par-tipo = "down" 
    then find next tt-abascompra no-lock no-error.

    if par-tipo = "up" 
    then find prev tt-abascompra no-lock no-error.
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
    for each tt-abascompra.
        delete tt-abascompra.
    end.
    for each tt-estab.
        delete tt-estab.
    end.    
    for each tt-forne.
        delete tt-forne.
    end.        

        
        find abastipo where abastipo.abatipo = par-abatipo no-lock.
        
        vsel = no.
    for each estab where
        if par-etbcod = 0
        then true
        else estab.etbcod = par-etbcod
        no-lock.
                        
        for each abascompra where 
                            abascompra.abcsit = par-abcsit  
                            and   abascompra.abatipo = abastipo.abatipo
                            and abascompra.etbcod = estab.etbcod
                            and (if par-forcod = 0
                                 then true
                                 else abascompra.forcod = par-forcod)
                           no-lock:
                                        
            if par-procod <> 0 
            then if par-procod <> abascompra.procod
                 then next.
                 

            /*
            if par-filtroatendimento = "AT" or
               par-filtroatendimento = "NA"
            then do:
                run abas/atendcalc.p    
                        (input abascompra.procod, 
                         input recid(abascompra), 
                         output vestoq_depos,  
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
            */
             
            vsel= yes.
            create tt-abascompra. 
            tt-abascompra.dtpreventrega = abascompra.dtpreventrega. 
            tt-abascompra.etbcod  = abascompra.etbcod. 
            tt-abascompra.abccod  = abascompra.abccod.
            tt-abascompra.rec = recid(abascompra).

            find first tt-estab where
                tt-estab.etbcod = abascompra.etbcod
                                                no-error.
            if not avail tt-estab
            then create tt-estab.
            tt-estab.etbcod = abascompra.etbcod.
            tt-estab.nro    = tt-estab.nro     + 1.

            find first tt-forne where
                tt-forne.forcod = abascompra.forcod
                                                no-error.
            if not avail tt-forne
            then create tt-forne.
            tt-forne.forcod = abascompra.forcod.
            tt-forne.nro    = tt-forne.nro     + 1.
 
            
        end.
        
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
      
      
  varqsai = westab.dirrel + "abascompra" + string(time).
  cTitRel = "PROGRAMACAO DE ABASTECIMENTO -_-_-_ " +
             (if vabcsit = "A"
              then " ABERTOS " 
              else (if vabcsit = "P"
                    then " APROVADOS "
                    else " ATENDIDOS/CANCELADOS") ).

  {mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "96"
    &Page-Line = "66"
    &Nom-Rel   = ""abascompra""
    &Nom-Sis   = """BS"""
    &Tit-Rel   = "cTitRel"
    &Width     = "96"
    &Form      = "frame f-cabcab"}

  disp "Estabelecimento: " Estab.EtbCod "-" Estab.EtbNom 
       "Itens:"  tt-Estab.QtdProdu
       "Qtd:"    tt-Estab.Qtd     skip(1)
       with frame f-Cab down no-labels width 92.

for each ttselabatipo where ttselabatipo.sel = yes,
    each tt-abascompra where tt-abascompra.abatipo = ttselabatipo.abatipo
    break by tt-abascompra.chave
          by tt-abascompra.pronom.

   find abascompra where recid(abascompra) = tt-abascompra.rec no-lock.
   find produ of abascompra no-lock.
   find fabri of produ no-lock.

   find first tt-marca where tt-marca.rec = recid(abascompra) no-error.
   vmarca = avail tt-marca.

   if first-of(tt-abascompra.chave)
   then do:
      if par-ordem = "GRUPO"
      then do.
         put unformatted
             fill("-", 96) skip
             "GRUPO: " tt-abascompra.chave skip.
      end.
      if par-ordem = "LOCAL"
      then do.
         find localizacao where localizacao.loccod = tt-abascompra.chave
                             no-lock no-error.
         find pestab where pestab.etbcod = abascompra.etbcod no-lock.
         put unformatted
            
             fill("-", 96) skip(1)
             string("LOCALIZACAO: " + tt-abascompra.chave + " - " +
              (if avail localizacao 
               then localizacao.locnom 
               else "Sem localizacao"),"x(40)")
              " - "
              string(abascompra.etbcod,"99") +
              string(day(today),"99")    + 
              string(month(today),"99")  + " - Filial : " +
              string(abascompra.etbcod,"99") + " " +
              pestab.etbnom
               skip(1).
      end.
   end.

      vdisponivel = disponivel(abascompra.procod).
       
      if not atende(abascompra.procod, abascompra.abatipo, abascompra.abcqtd, 
                    output vatende)  and
         vabatipo
      then next.
      
      find estoq where estoq.etbcod = setbcod and
                       estoq.procod = produ.procod no-lock no-error.
/***
      if not Atende(abascompra.procod, abascompra.abatipo,
                    abascompra.abcqtd,  output vatende)
      then next.
***/
      if vabatipo  and  
         vatende <= 0
      then next.   
      def var vlinha as char format "xxxx" init "....".
      display 
/**         vmarca          column-label "*"    **/
         abascompra.abcqtd column-label "Qtd" format ">>9"
         vlinha column-label ""
         abascompra.abatipo   column-label "Tip" format "xxx"
         abascompra.procod
         fabri.fabnom    format "x(7)" column-label "Fabric"
         produ.pronom    format "x(14)"
         estoq.estatual  column-label "Estoq" 
                    format "->>>9" when avail estoq
         vdisponivel column-label "Disp" format "->>>9"
/*        (if abascompra.qtdoc = 0
        then vatende
        else abascompra.qtdoc) @ abascompra.qtdoc */
         vatende        column-label "Atd"   format ">>9"
         abascompra.dtpreventrega format "999999"
/*         abascompra.qtdoc*/
         (vatende <= 0) label "" format " * * / " 
         with frame f-rel down width 110 no-box .   
    
    down with frame f-rel.
end.
put unformatted skip fill("-", 96).
   
{mdadmrod.i
    &Saida     = "value(varqsai)"
    &NomRel    = """abascompra"""
    &Page-Size = "64"
    &Width     = "96"
    &Traco     = "96"
    &Form      = "frame f-rod3"}.
*/
    
end procedure.

procedure criattestab.

   def var vetbcod like estab.etbcod label "Estabelecimento".
    repeat on error undo.
        update vetbcod 
                            
                with frame f-inclui 
                row 10 centered overlay side-label.
        
        par-etbcod = vetbcod.

        if vetbcod > 0
        then do:
            find tt-estab where tt-estab.etbcod = vetbcod no-error.
            if avail tt-estab then do:
                message "Estabelecimento ja cadastrado" view-as alert-box.
                next.
            end.               
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab then do:
                message "Estabelecimento nao encontrado" view-as alert-box.
                next.
            end.
            create tt-estab.
            tt-estab.etbcod = vetbcod.
            leave.
        end.
    end.
    hide frame f-inclui no-pause.

end procedure.


procedure limpa.

for each tt-marca.
   find abascompra where recid(abascompra) = tt-marca.rec exclusive.
   /*
   if abascompra.abcsit = "A" and
      abascompra.abrcod = 0
   then    abascompra.qtdoc = 0.
   */
   
   delete tt-marca.
end.

end procedure.


procedure selabatipo.


    form
            abastipo.abatipo
            abastipo.abatnom
            with frame f-sel 10 down overlay
                    row 7 column 40 width 40 title " Selecione o Tipo ".
    pause 0.
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    status default " ENTER = Seleciona ".
    {sklclstb.i
        &color = withe
        &color1 = red
        &file       = abastipo
        &Cfield     = abastipo.abatipo
        &OField     = " abastipo.abatnom " 
        &Where      = " abastipo.tiposugcompra  " 
        &AftSelect1 = " pause 0.
                        par-abatipo = abastipo.abatipo.
                        
                        pause 0.
                       leave keys-loop. "
        &LockType  = " no-lock "
        &form       = " frame f-sel " 
    }.                
    hide frame f-sel no-pause.
    if keyfunction(lastkey) = "END-ERROR" 
    then do:
    
        leave.
    end.

end procedure.

procedure mostradados. 
    find fabri of produ no-lock no-error.
    find mestoq where  mestoq.etbcod = par-etbcod and
                       mestoq.procod = produ.procod 
                       no-lock no-error.
    clear frame fsub all no-pause.
    display produ.procod 
            produ.pronom 
            produ.fabcod 
            fabri.fabnom when avail fabri
            mestoq.estatual when avail mestoq
            with frame fsub.                
            color display message  mestoq.estatual
                                    with frame fsub.


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
    if cabcsit[frame-index] <> "" 
    then do:
        par-abcsit = cabcsit[frame-index].
        recatu1 = ?.
        run monta-tt.
    end.
    
end.
hide frame f-selsit no-pause.

end procedure.



procedure selestab.

              
    if par-etbcod <> 0
    then do:          
        par-etbcod = 0.
        run monta-tt.
    end.

        form    
            tt-estab.etbcod column-label "Etb"
            estab.etbnom column-label "Estabelecimento"
            tt-estab.nro
        with frame f-linha down centered row 04 
          title " Estabelecimentos Distribuicao " 
                    
          color withe/brown.

        status default "F4 Todas".
        assign 
            a-seeid = -1.
        
        par-etbcod = 0.
        
        {sklclstb.i
            &file         = tt-estab
            &cfield       = tt-estab.etbcod
            &noncharacter = /* 
            &ofield       = " estab.etbnom tt-estab.nro" 
            &where        = " true "
            &color        = with
            &color1       = brown
            &locktype     = " no-lock " 
            &naoexiste1   = "run criattestab.  
                             leave keys-loop."
            &aftfnd1      = " find estab where estab.etbcod = 
                                tt-estab.etbcod no-lock. "
            &aftselect1   = "
                    if keyfunction(lastkey) = ""insert-mode"" 
                    then do:
                       run criattestab.
                       leave keys-loop.
                    end.
                    if keyfunction(lastkey) = ""return""
                    then do:
                        par-etbcod = tt-estab.etbcod.
                        leave keys-loop.
                    end.    
                    else
                        next keys-loop.
                          "
            &form         = " frame f-linha " } 

        
 
HIDE frame f-linha no-pause.
end procedure.

procedure selforne.

              
    if par-forcod <> 0
    then do:          
        par-forcod = 0.
        run monta-tt.
    end.

        form    
            tt-forne.forcod column-label "For"
            forne.fornom column-label "Fornecedor"
            tt-forne.nro
        with frame f-linhaforne down centered row 04 
          title " Fornecedores " 
                    
          color withe/brown.

        status default "F4 Todas".
        assign 
            a-seeid = -1.
        
        par-forcod = 0.
        
        {sklclstb.i
            &file         = tt-forne
            &cfield       = tt-forne.forcod
            &noncharacter = /* 
            &ofield       = " forne.fornom tt-forne.nro" 
            &where        = " true "
            &color        = with
            &color1       = brown
            &locktype     = " no-lock " 
            &naoexiste1   = "run criattforne.  
                             leave keys-loop."
            &aftfnd1      = " find forne where forne.forcod = 
                                tt-forne.forcod no-lock. "
            &aftselect1   = "
                    if keyfunction(lastkey) = ""insert-mode"" 
                    then do:
                       run criattforne.
                       leave keys-loop.
                    end.
                    if keyfunction(lastkey) = ""return""
                    then do:
                        par-forcod = tt-forne.forcod.
                        leave keys-loop.
                    end.    
                    else
                        next keys-loop.
                          "
            &form         = " frame f-linhaforne " } 

        
 
HIDE frame f-linhaforne no-pause.
end procedure.




hide frame f-selsit no-pause. 




procedure selproduto.


        update par-procod 
                with frame fcab overlay row 3 color message side-label width 80
                no-box.

end.


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





procedure geraoc. 

    def var vi as int.
    def var pforcod like par-forcod.

    def var vcd     as int.
    
    find first abascdestoq where abascdestoq.localentrada = yes
        no-lock.
        
    pforcod = par-forcod.
    for each tt-marca.
        vi = vi + 1.    
    end.
    
    vcd = 0.
    for each tt-marca ,
        abascompra where recid(abascompra) = tt-marca.rec :
        
        find produ of abascompra no-lock.
        
        if vcd = 0
        then do:    
            if produ.catcod = 41
            then vcd = 996.
            else vcd = 999.
        end.  
        
        if vi = 1
        then do:
            pforcod = abascompra.forcod.
        end.
        /* 11.07.2019 */
        
        find abascusto where abascusto.procod = abascompra.procod
            no-lock no-error.
        if avail abascusto
        then do:
            abascompra.lippreco = abascusto.custocompra.
            
                abascompra.lippreco = if abascusto.ipiperccompra <> 0 and
                             abascusto.ipiperccompra <> ?
                          then abascompra.lippreco + (abascusto.custocompra * ipiperccompra / 100)
                          else abascompra.lippreco.  
            
        end.
        else do:        
            find estoq where 
                        estoq.etbcod = abascdestoq.etbcod and  
                        estoq.procod = abascompra.procod 
                         no-error.
            if avail estoq 
            then do:
                abascompra.lippreco = estoq.estcusto.
            end.    
        end.      
        if abascompra.lippreco = 0
        then abascompra.lippreco = 1.
        
    end.       
    
    if vcd = 0
    then vcd = 999.
    
    run abas/pedcomin.p (/*abascdestoq.etbcod - 28.06.19 */ vcd , pforcod, output recatu1). 
    
    find pedid where recid(pedid) = recatu1 no-lock no-error.
    if avail pedid
    then do on error undo:
        for each tt-marca where tt-marca.marca,
            abascompra where recid(abascompra) = tt-marca.rec:

            abascompra.AbCSit     = "PE".
            abascompra.etbPed     = pedid.etbcod.
            abascompra.pednum     = pedid.pednum.
            abascompra.pedtdc     = pedid.pedtdc.
            tt-marca.marca = no.    
        end. 
                        
        find current pedid exclusive.               
        pedid.pedsit = yes.
        pedid.sitped = "P".

        run abas/co_occons.p (recid(pedid)).

    end.

end procedure.


