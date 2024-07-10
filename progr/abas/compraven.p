/*                                   
*
*/

{cabec.i}  

{setbrw.i}.

def input param par-parametros as char. 
def var varquivo as char.

def var vclien as char.
def var vendedor as char.
def var vnumero as char.
def var vpladat like plani.pladat.
def var vconta as int.
def var par-abatipo like abascompra.abatipo.
def var par-abcsit  like abascompra.abcsit.
def var par-etbcod  like abascompra.etbcod init 0.
def var par-forcod  like abascompra.forcod. 

par-abatipo = entry(1,par-parametros).
par-abcsit  = entry(2,par-parametros).



def var cfiltros   as char format "x(25)" extent 7
    init ["Situacao","Filial","Fornecedor",""].
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

def var vorietbcod  like abastransf.orietbcod.
def var voriplacod  like abastransf.oriplacod.
def var vabcobs     as char extent 4.
def var vcomcod     like compr.comcod.                                                                                
def buffer cpedid for pedid.
def buffer bpedid for pedid.
def var vpednum     like pedid.pednum.
def buffer bliped for liped.

def temp-table tt-compraven no-undo
    field etbcod        like abascompra.etbcod    
    field forcod        like abascompra.forcod   
    field dtpreventrega like abascompra.dtpreventrega
    field orietbcod     like abastransf.orietbcod
    field oriplacod     like abastransf.oriplacod
    field abcsit        like abascompra.abcsit
    field etbped        like abascompra.etbped
    field pednum        like abascompra.pednum
    field pedtdc        like abascompra.pedtdc
    field comcod        like pedid.comcod
    index chave is unique primary 
            etbcod asc
            forcod  asc
            dtpreventrega asc 
            abcsit    asc
            orietbcod asc 
            oriplacod asc
            etbped    asc
            pednum    asc
            pedtdc    asc.
            
def temp-table tt-abascompra no-undo
    field recvenda      as recid
    field recabascompra as recid
    index chave is unique primary 
            recvenda asc
            recabascompra asc.
            

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
        index x is unique primary rec asc.

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


   find first tt-marca where
        tt-marca.rec = recid(tt-compraven)
        no-error.
   vmarca = avail tt-marca. 
   find pedid where  
            pedid.etbcod = tt-compraven.etbped and 
            pedid.pednum = tt-compraven.pednum and 
            pedid.pedtdc = tt-compraven.pedtdc 
      no-lock no-error. 
    
    release plani. 
        find first plani where 
                    plani.etbcod = tt-compraven.orietbcod and  
                    plani.placod = tt-compraven.oriplacod 
            no-lock no-error.
    find forne where forne.forcod = tt-compraven.forcod no-lock. 
    
    find compr where compr.comcod = tt-compraven.comcod no-lock no-error.
    
    display 
        vmarca column-label "*" 
        tt-compraven.etbcod
        tt-compraven.forcod
        forne.fornom format "x(20)"
        tt-compraven.dtpreventrega  format "999999" column-label "Data"
        tt-compraven.orietbcod
        plani.numero        when avail plani column-label "Venda"
        tt-compraven.abcsit
        tt-compraven.comcod
        compr.comnom   format "x(10)" when avail compr
        tt-compraven.pednum when tt-compraven.pednum <> ?

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
        find tt-compraven where recid(tt-compraven) = recatu1 no-lock.
    if not available tt-compraven
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

    recatu1 = recid(tt-compraven).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-compraven
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
            find tt-compraven where recid(tt-compraven) = recatu1 no-lock.
            
            find pedid where 
                            pedid.etbcod = tt-compraven.etbped and
                            pedid.pednum = tt-compraven.pednum and
                            pedid.pedtdc = tt-compraven.pedtdc
                            no-lock no-error.
            release plani.
            
            esqcom2[1] = "".
                    find first plani where plani.etbcod = tt-compraven.orietbcod and
                                           plani.placod = tt-compraven.oriplacod
                            no-lock no-error.
                    if avail plani
                    then do:
                        esqcom2[1] = "NF.Origem". 
                    end.
             
            find forne where forne.forcod = tt-compraven.forcod no-lock no-error.
            
            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and esqpos1 < 4  and
                                           esqhel1[esqpos1] <> ""
                                        then  string(forne.fornom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(forne.fornom)
                                        else "".
            color display message
                tt-compraven.etbcod
                tt-compraven.forcod
                forne.fornom 
                tt-compraven.dtpreventrega 
                tt-compraven.orietbcod
                plani.numero      
                tt-compraven.abcsit
                tt-compraven.pednum 
                
               with frame frame-a.
           
            find first btt-marca no-error.
            
            esqcom1[1] = " Filtros".                
            esqcom1[2] = " Consulta".                
            
            esqcom1[3] = if par-abcsit = "AB" and 
                            par-forcod <> 0 and 
                            tt-compraven.forcod = par-forcod   
                         then " Marca"
                         else if avail pedid
                              then " Pedido"
                              else "".
            esqcom1[4] = if par-abcsit = "AB"
                         then " Gera OC"
                              else "".
            disp esqcom1 with frame f-com1.        
            disp esqcom2 with frame f-com2.
                    
            choose field tt-compraven.etbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0
                      page-down   page-up
                      tab PF4 F4 ESC return).
            
            color display normal
                tt-compraven.etbcod
                tt-compraven.forcod
                forne.fornom
                tt-compraven.dtpreventrega 
                tt-compraven.orietbcod
                plani.numero      
                tt-compraven.abcsit
                tt-compraven.pednum 

               with frame frame-a.
            
            /*
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
            */
            
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
                    if not avail tt-compraven
                    then leave.
                    recatu1 = recid(tt-compraven).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-compraven
                    then leave.
                    recatu1 = recid(tt-compraven).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-compraven
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-compraven
                then next.
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
                    recatu1 = recid(tt-compraven).
                    leave.        
                end.
                */
                
                if esqcom1[esqpos1] = " Filtros"
                then do:
                    pause 0.
                    display 
        "                   P E D I D O S    E S P E C I A L   -  V E N D A S "
                    with frame fpor1 centered width 81 no-box color message
                    row 5 overlay.

                    disp cfiltros with frame fpor centered no-labels row 6
                        width 40 
                        title "Filtro Por". 
                    choose field cfiltros with frame fpor.
                    ifiltros = frame-index.
                    par-filtro = cfiltros[ifiltros].        
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
                    
                     
                end.
                    
                
                
                
                if esqcom1[esqpos1] = " Marca "
                then do:
                    find first tt-marca where
                            tt-marca.rec = recid(tt-compraven)
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
                                for each tt-compraven.
                                    if tt-compraven.forcod <> par-forcod
                                    then next.           
                                    create tt-marca.
                                    tt-marca.marca = yes.
                                    tt-marca.rec = recid(tt-compraven).
                                end.
                                hide message no-pause.
                                recatu1 = ?.
                                leave. 
                            end.
                            else do:
                                create tt-marca.
                                tt-marca.marca = yes.
                                tt-marca.rec = recid(tt-compraven).
                            end.
                        end.
                        else do: 
                            create tt-marca. 
                            tt-marca.marca = yes.
                            tt-marca.rec = recid(tt-compraven).
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
                        tt-marca.rec = recid(tt-compraven).
                    end.
                     
                    hide frame fsub no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    
                    run geracompra.
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
                    
                            find first plani where 
                                    plani.etbcod = tt-compraven.orietbcod and
                                    plani.placod = tt-compraven.oriplacod
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

                    pause 0.
                    find first tt-abascompra where tt-abascompra.recvenda = recid(tt-compraven).
                    find abascompra where recid(abascompra) = tt-abascompra.recabascompra no-lock.                    
                    if length(abascompra.abcobs[1]) > 60
                    then do:
                        vabcobs[1] = substr(abascompra.abcobs[1],  1, 60).
                        vabcobs[2] = substr(abascompra.abcobs[1], 61,120).
                        vabcobs[3] = substr(abascompra.abcobs[1],121,181).
                        vabcobs[4] = substr(abascompra.abcobs[1],181).
                    end.
                    else do:
                        vabcobs[1] = abascompra.abcobs[1].
                        vabcobs[2] = abascompra.abcobs[2].
                        vabcobs[3] = abascompra.abcobs[3].
                        vabcobs[4] = abascompra.abcobs[4].
                    end.
                    disp 
                        /*abascompra.abccod at 1 label "  Pedido  "
                                    format ">>>>>>>>9"*/
                         vendedor at 1 label "  Vendedor"  format "x(40)"
                         vclien   at 1 label "  Cliente "  format "x(40)"
                         vnumero  at 1 label "  Numero Venda"
                            format "xxxxxxxxx"
                         vpladat              label "Data Venda"
                         tt-compraven.etbcod label "Filial Entrega" format ">>9"
                         vabcobs[1]      label "Observacao" format "x(60)"
                         vabcobs[2]      at 13  no-label    format "x(60)"
                         vabcobs[3]      at 13  no-label    format "x(60)"
                         vabcobs[4]      at 13  no-label    format                                 "x(60)" 
                     
                     with frame f-add 1 down  color message
                        row 5 side-label no-box width 80 overlay.
                    
                    for each tt-abascompra where tt-abascompra.recvenda = recid(tt-compraven).
                        find abascompra where recid(abascompra) = tt-abascompra.recabascompra no-lock.
                        find produ of abascompra no-lock.
                        disp abascompra.procod
                             produ.pronom format "x(30)"
                             abascompra.lipcor
                             abascompra.abcqtd column-label "Qtd.Ped" format ">>>9"
                             abascompra.qtdentregue column-label "Qtd.Ent" format ">>>9"
                                    with frame f-con centered
                                            color black/cyan width 80
                                            row 12 down.

                    end.
                    pause message "Consultando...".
                end.
                
                
                if esqcom1[esqpos1] = " pedido"
                then do:
                    find pedid where 
                            pedid.etbcod = tt-compraven.etbped and
                            pedid.pednum = tt-compraven.pednum and
                            pedid.pedtdc = tt-compraven.pedtdc
                            no-lock no-error.
                    
                    if avail pedid
                    then do:
                        hide frame f-com1 no-pause.
                        hide frame f-com2 no-pause.
                        hide frame frame-a no-pause.
                        run abas/co_occons.p (recid(pedid)).
                    end.    
                
                end.
                               
               
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

                /*
                if esqcom2[esqpos2] = " Quantidade"
                then do on error undo:
                    find current abascompra exclusive.
                    message "Quantidade Original" abascompra.qtdori.
                    update abascompra.abcqtd.
                end.
                */
                if esqcom2[esqpos2] = "NF.Origem"
                then do:
                    find first plani where plani.etbcod = tt-compraven.orietbcod and
                                           plani.placod = tt-compraven.oriplacod
                            no-lock no-error.
                    if avail plani
                    then  run not_consnota.p (recid(plani)).
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
        recatu1 = recid(tt-compraven).
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
    then find first tt-compraven no-lock no-error.

    if par-tipo = "seg" or par-tipo = "down" 
    then find next tt-compraven no-lock no-error.

    if par-tipo = "up" 
    then find prev tt-compraven no-lock no-error.
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
    for each tt-compraven.
        delete tt-compraven.
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
                                        

            find produ of abascompra no-lock.
            
            vsel= yes.
            find abastransf where abastransf.etbcod = abascompra.etbcod and
                                  abastransf.abtcod = abascompra.abtcod
                        no-lock no-error.
            
            vorietbcod = if avail abastransf
                         then abastransf.orietbcod
                         else abascompra.etbcod.
            voriplacod = if avail abastransf
                         then abastransf.oriplacod
                         else 0.
                                            
            find first tt-compraven where
                    tt-compraven.etbcod         = abascompra.etbcod and
                    tt-compraven.forcod         = abascompra.forcod and
                    tt-compraven.dtpreventrega  = abascompra.dtpreventrega and
                    tt-compraven.abcsit         = abascompra.abcsit and
                    tt-compraven.orietbcod      = vorietbcod and
                    tt-compraven.oriplacod      = voriplacod and
                    tt-compraven.etbped         = abascompra.etbped and
                    tt-compraven.pednum         = abascompra.pednum and
                    tt-compraven.pedtdc         = abascompra.pedtdc 
               no-error.
            if not avail tt-compraven           
            then do:
                create tt-compraven.  
                tt-compraven.etbcod         = abascompra.etbcod.
                tt-compraven.forcod         = abascompra.forcod.
                tt-compraven.dtpreventrega  = abascompra.dtpreventrega.
                tt-compraven.abcsit         = abascompra.abcsit.
                tt-compraven.orietbcod      = vorietbcod.
                tt-compraven.oriplacod      = voriplacod.
                tt-compraven.etbped         = abascompra.etbped.

                tt-compraven.pednum         = abascompra.pednum.
                tt-compraven.pedtdc         = abascompra.pedtdc.
            end.
            
            
            create tt-abascompra.
            tt-abascompra.recvenda      = recid(tt-compraven).
            tt-abascompra.recabascompra = recid(abascompra).
             
            if tt-compraven.comcod = ?
            then do: 
                run buscacompr.p (input produ.clacod, 
                                  input produ.fabcod, 
                                  output vcomcod).
                find compr where compr.comcod = vcomcod no-lock no-error.
                if not avail compr
                then tt-compraven.comcod = 0.
                else tt-compraven.comcod = vcomcod.
            end.                      

            find first tt-estab where
                tt-estab.etbcod = tt-compraven.etbcod no-error.
            if not avail tt-estab
            then create tt-estab.
            tt-estab.etbcod = tt-compraven.etbcod.
            tt-estab.nro    = tt-estab.nro     + 1.

            find first tt-forne where
                tt-forne.forcod = tt-compraven.forcod
                                                no-error.
            if not avail tt-forne
            then create tt-forne.
            tt-forne.forcod = tt-compraven.forcod.
            tt-forne.nro    = tt-forne.nro     + 1.
 
            
        end.
        
    end.      
    hide message no-pause.
    
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







procedure geraoc. 

    def var vi as int.
    def var pforcod like par-forcod.
    
    find first abascdestoq where abascdestoq.localentrada = yes
        no-lock.
        
    pforcod = par-forcod.
    for each tt-marca.
        vi = vi + 1.    
    end.
    
    for each tt-marca ,
        abascompra where recid(abascompra) = tt-marca.rec :
        if vi = 1
        then do:
            pforcod = abascompra.forcod.
        end.
        find estoq where 
                    estoq.etbcod = abascdestoq.etbcod and  
                    estoq.procod = abascompra.procod 
                     no-error.
        if avail estoq 
        then do:
            abascompra.lippreco = estoq.estcusto.
        end.    
        if abascompra.lippreco = 0
        then abascompra.lippreco = 1.
        
    end.       
    
    run abas/pedcomin.p (abascdestoq.etbcod, pforcod, output recatu1). 
    
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


procedure geracompra.

    if opsys <> "UNIX"
    then do: 
        message "Opcao disponivel somente em terminal LINUX" 
            view-as alert-box. 
        return.
    end.
    
    find first abascdestoq where abascdestoq.localentrada = yes
        no-lock.

    message "Confirma gerar pedidos de compra? " update sresp.
    if not sresp
    then return.
                
def var vpedtot     like pedid.pedtot.
def var vrepcod     like pedid.vencod.
             
    for each tt-marca. 
        for each tt-compraven where recid(tt-compraven) = tt-marca.rec. 
            vpedtot = 0. 
            find forne where forne.forcod = tt-compraven.forcod no-lock. 
            find repre where repre.repcod = forne.repcod        no-lock no-error. 
            vrepcod = if avail repre 
                      then repre.repcod 
                      else 0. 
            vpedtot = 0.
            for each tt-abascompra where tt-abascompra.recvenda = recid(tt-compraven). 
                find abascompra where recid(abascompra) = tt-abascompra.recabascompra exclusive. 
                find estoq where estoq.etbcod = abascdestoq.etbcod and 
                                 estoq.procod = liped.procod 
                    no-lock no-error. 
                if avail estoq 
                then abascompra.lippreco = estoq.estcusto.
                vpedtot = vpedtot + (abascompra.lippreco * abascompra.abcqtd). 
            end.  
            find last cpedid use-index ped 
                            where cpedid.etbcod = abascdestoq.etbcod and 
                            cpedid.pedtdc = 1  
                            no-lock no-error.
            if avail cpedid 
            then vpednum = cpedid.pednum + 1. 
            else vpednum = 1. 
            do transaction:  
                create bpedid. 
                assign bpedid.pedtdc    = 1 
                       bpedid.pednum    = vpednum 
                       bpedid.clfcod    = forne.forcod 
                       bpedid.regcod    = 999 
                       bpedid.peddat    = today  
                       bpedid.pedsit    = yes  
                       bpedid.sitped    = "A"  
                       bpedid.etbcod    = abascdestoq.etbcod  
                       bpedid.condat   = today 
                       bpedid.peddti   = today + 20 
                       bpedid.peddtf   = today + 25 
                       bpedid.crecod   = 90 
                       bpedid.fobcif   = no 
                       bpedid.modcod   = "PED"  
                       bpedid.vencod   = vrepcod 
                       bpedid.pedtot   = vpedtot 
                       bpedid.comcod   = tt-compraven.comcod 
                       bpedid.pedobs[1] = "" 
                       bpedid.pedobs[2] = "" 
                       bpedid.pedobs[3] = "" 
                       bpedid.pedobs[4] = "" 
                       bpedid.pedobs[5] = "" 
                       bpedid.pedobs[1] = "|Filial origem=" + string(tt-compraven.orietbcod,">>9").
                bpedid.pedobs[1] = bpedid.pedobs[1] +
                            "|Filial destino=" + string(tt-compraven.etbcod,">>9").
                            
            end. 
            for each tt-abascompra where tt-abascompra.recvenda = recid(tt-compraven). 
                find abascompra where recid(abascompra) = tt-abascompra.recabascompra 
                    exclusive-lock.  
                find first bliped where
                        bliped.pednum = bpedid.pednum and
                        bliped.pedtdc = bpedid.pedtdc and
                        bliped.etbcod = bpedid.etbcod and
                        bliped.procod = abascompra.procod
                    no-error.     
                if not avail bliped
                then do:    
                    create bliped.  
                    assign  
                        bliped.pednum = bpedid.pednum  
                        bliped.pedtdc = bpedid.pedtdc 
                        bliped.predt  = bpedid.peddat
                        bliped.predtf = bpedid.peddtf   
                        bliped.etbcod = bpedid.etbcod 
                        bliped.procod = abascompra.procod.  
                end.                        
                assign
                    bliped.lippreco = abascompra.lippre   
                    bliped.lipqtd = bliped.lipqtd + abascompra.abcqtd   
                    bliped.lipsit = "A"   
                    bliped.protip = "M". 

                abascompra.AbCSit     = "PE".
                abascompra.etbPed     = bpedid.etbcod.
                abascompra.pednum     = bpedid.pednum.
                abascompra.pedtdc     = bpedid.pedtdc.
            end. 
            assign
                tt-compraven.etbPed     = bpedid.etbcod.
                tt-compraven.pednum     = bpedid.pednum.
                tt-compraven.pedtdc     = bpedid.pedtdc.
            
        end.
    end.                     
    sresp = no.  
    message "Confirma enviar e-mail?" update sresp.  
    if sresp  
    then do:  
        run env-mail.     
    end.

end procedure.




procedure env-mail:
    def var varqmail as char.
    def var c-mail as char extent 5.
    def var v-assunto as char init "REQUISICAO DE MERCADORIAS".
    def var vi as int.
    def var vqt-pecas as int.
    def var vqt-itens as int.
    def var vlipcor like liped.lipcor.
    def var valor as dec format ">>>>9,99".
    def var vnum-ped as char.
    def var vqtd-ped as int.
    vnum-ped = "".
    vqtd-ped = 0.
    for each tt-marca. 
        for each tt-compraven where recid(tt-compraven) = tt-marca.rec. 
            find plani where plani.etbcod = tt-compraven.orietbcod and
                             plani.placod = tt-compraven.oriplacod
                             no-lock.
            vnum-ped = vnum-ped + string(plani.numero) + ", " .
            vqtd-ped = vqtd-ped + 1.
        end.      
    end.
    c-mail[1] = forne.email.
    varqmail = "./mailped.cmp".
    if search(varqmail) <> ?
    then do:
        vi = 1.
        input from value(varqmail).
        repeat:
            vi = vi + 1.
            import c-mail[vi].
        end.
        input close.
    end.
    vi = 0.
    repeat on endkey undo:
        update c-mail[1] label "   Para"  format "x(50)"
               c-mail[2] label "     Cc"  format "x(50)"
               c-mail[3] label "       "  format "x(50)"
               c-mail[4] label "       "  format "x(50)"
               c-mail[5] label "       "  format "x(50)"
               v-assunto label "Assunto"  format "x(50)"
               with frame f-mail width 80 side-label
               title " enviar e-mail ".
               
        if c-mail[1] = "" then next.
        if v-assunto = ""  then next.
        hide frame f-mail no-pause.     
        leave.
    end.
    
    if keyfunction(lastkey) = "end-error"
    then.
    else do:
        if opsys = "UNIX"
        then varquivo = "../relat/oc-mail." + string(time) .
        else varquivo = "..\relat\oc-mail." + string(time) .
        message varquivo. pause.
        
        output to value(varquivo).
            put 
                    "DREBES & CIA LTDA    <br>     " skip 
                    "REQUISICAO DE MERCADORIA <br>  " skip
                    .
 
            put "<br>" skip
                "Informamos o envio de " vqtd-ped 
                " pedidos de compra <br>" skip
                "Pedidos: " vnum-ped format "x(800)" 
                "<br>" skip
                "Favor confirmar o recebimento de todos os pedidos. "
                .

        output close.
        do vi = 1 to 5:
            if c-mail[vi] <> ""
            then do:
                unix silent value("/admcom/progr/mail.sh "
                                 + "~"" + v-assunto + "~"" + " ~"" 
                                 + varquivo + "~"" + " ~"" 
                                 + c-mail[vi] + "~""
                                 + " ~"pedidosespeciais@lebes.com.br~""
                                 + " ~"text/html~"").
                pause 0.    
            end.
            else leave.
        end.
        for each tt-marca. 
          for each tt-compraven where recid(tt-compraven) = tt-marca.rec. 

            find bestab where bestab.etbcod = tt-compraven.etbcod no-lock.

            find plani where plani.etbcod = tt-compraven.orietbcod and
                             plani.placod = tt-compraven.oriplacod
                             no-lock.
            
            find bpedid where bpedid.pedtdc = tt-compraven.pedtdc and
                             bpedid.etbcod  = tt-compraven.etbped and
                             bpedid.pednum  = tt-compraven.pednum
                             no-lock no-error.
            if avail bpedid
            then do:
                
                if opsys = "UNIX"
                then varquivo = "../relat/oc-" + string(bpedid.pednum) + ".txt".
                else varquivo = "..\relat\oc-" + string(bpedid.pednum) + ".txt".

                message varquivo. pause.
                output to value(varquivo).
 
                put 
                    "DREBES & CIA LTDA         " skip 
                    "REQUISICAO DE MERCADORIA   " skip.
               
                find first tt-abascompra where tt-abascompra.recvenda = recid(tt-compraven). 
                find babascompra where recid(babascompra) = tt-abascompra.recabascompra no-lock.
                
                find produ of babascompra no-lock.
                find fabri where fabri.fabcod = produ.fabcod no-lock.
                put fabri.fabfant "" skip.
                put fill("_",80) format "x(100)".
                
                for each bliped where bliped.pedtdc = bpedid.pedtdc and
                                      bliped.etbcod = bpedid.etbcod and
                                      bliped.pednum = bpedid.pednum 
                                      no-lock:
                    find estoq where estoq.etbcod = tt-compraven.orietbcod and
                                     estoq.procod = bliped.procod no-lock
                                     no-error.
                    find produ of bliped no-lock.
                    find abascompra where abascompra.pedtdc = bpedid.pedtdc and
                                     abascompra.etbped = bpedid.etbcod and
                                     abascompra.pednum = bpedid.pednum and
                                     abascompra.procod = bliped.procod
                                     no-lock no-error.
                    if avail abascompra
                    then vlipcor = abascompra.lipcor.
                    else vlipcor = "".    
                    disp produ.procod   column-label "Codigo" format ">>>>>>9"
                         produ.pronom   column-label "Produto" format "x(38)"
                         vlipcor        column-label "Cor"  format "x(15)"
                         bliped.lipqtd  column-label "Quant."  format ">>>9"
                         estoq.estvenda column-label "Preco"  
                                            format ">>>,>>9.99" when avail estoq
                         with frame f-disp1 down width 100.
                    down with frame f-disp1.     
                end.
                
                find first func where func.etbcod = plani.etbcod and
                                      func.funcod = plani.vencod no-lock no-error.
                put fill("_",80) format "x(80)" skip
                    "PEDIDO: " plani.numero format ">>>>>>>>9"  "" skip
                    "ORDEM DE COMPRA: " tt-compraven.pednum format ">>>>>>>>9"    
                                     "" skip 
                    "NF: " plani.numero
                    "     DATA VENDA: " plani.pladat format "99/99/9999"
                    "" skip.
                if plani.vencod <> 0 and avail func
                then put "NOME: " func.funnom "" skip.
                else put "NOME:.................................. "  skip.
                put "DATA: " today format "99/99/9999"
                    "     FILIAL: "  bestab.etbnom  "" skip.

                find first tt-abascompra where tt-abascompra.recvenda = recid(tt-compraven). 
                find babascompra where recid(babascompra) = tt-abascompra.recabascompra no-lock.

                    if length(babascompra.abcobs[1]) > 60
                    then do:
                        vabcobs[1] = substr(babascompra.abcobs[1],  1, 60).
                        vabcobs[2] = substr(babascompra.abcobs[1], 61,120).
                        vabcobs[3] = substr(babascompra.abcobs[1],121,181).
                        vabcobs[4] = substr(babascompra.abcobs[1],181).
                    end.
                    else do:
                        vabcobs[1] = babascompra.abcobs[1].
                        vabcobs[2] = babascompra.abcobs[2].
                        vabcobs[3] = babascompra.abcobs[3].
                        vabcobs[4] = babascompra.abcobs[4].
                    end.

                put "Observacao: " vabcobs[1] format "x(60)" skip
                     vabcobs[2] at 10 format "x(60)" skip
                     vabcobs[2] at 10 format "x(60)" skip
                     vabcobs[2] at 10 format "x(60)" skip.

                output close.

                if opsys = "UNIX"
                then varquivo = "../relat/oc-" + string(bpedid.pednum) + ".htm".
                else varquivo = "..\relat\oc-" + string(bpedid.pednum) + ".htm".

                message varquivo. pause.
                output to value(varquivo).
 
 
                put unformatted
                    "<b>DE  :</b> DREBES & CIA LTDA        <BR> " skip 
                    "<b>PARA:</b> " caps(fabri.fabfant) format "x(40)" 
                    "<BR>" skip
                    "<BR><b>COMPRA:</b> " bpedid.pednum format ">>>>>>>>9" skip
                        "<b>DATA:</b> " plani.pladat "<BR>"  skip
                    .
                
                PUT unformatted
                "<TABLE border=~"2~" frame=~"hsides~" rules=~"groups~"" skip
                "          summary=~"DREBES & CIA LTDA~">" skip
                "<CAPTION><b>" skip
                "<COLGROUP align=~"right~">" skip
                "<COLGROUP align=~"left~">" skip
                "<COLGROUP align=~"left~">" skip
                "<COLGROUP align=~"right~">" skip
                "<COLGROUP align=~"right~">" skip
                "<COLGROUP align=~"left~">"  skip
                "<THEAD valign=~"top~">" skip
                "<TR>" skip
                "<TH><b>Codigo<BR>" skip
                "<TH><b>Produto<BR>" skip
                "<TH><b>Cor<BR>" skip
                "<TH><b>Quant<BR>" skip
                "<TH><b>Preço<BR>" skip
                "<TBODY>" skip.
                
                for each bliped where bliped.pedtdc = bpedid.pedtdc and
                                      bliped.etbcod = bpedid.etbcod and
                                      bliped.pednum = bpedid.pednum 
                                      no-lock:
                    find estoq where estoq.etbcod = tt-compraven.orietbcod and
                                     estoq.procod = bliped.procod 
                                     no-lock no-error.
                    find produ of bliped no-lock.
                    find abascompra where abascompra.pedtdc = bpedid.pedtdc and
                                     abascompra.etbped = bpedid.etbcod and
                                     abascompra.pednum = bpedid.pednum and
                                     abascompra.procod = bliped.procod
                                     no-lock no-error.
                    if avail abascompra
                    then vlipcor = abascompra.lipcor.
                    else vlipcor = "".    

                    put unformatted
                        "<TR><TD>" produ.procod  
                        "<TD>" produ.pronom  format "x(40)"
                        "<TD>" vlipcor
                        "<TD>" bliped.lipqtd 
                        "<TD>".
                        if avail estoq
                        then put string(estoq.estvenda,">>>,>>9.99").
                    put "</TR>" skip.
 
                end.
                put "</TABLE>" skip.
                find first func where func.etbcod = plani.etbcod and
                                      func.funcod = plani.vencod no-lock no-error.

                put "<BR>" skip
                    "<b>FILIAL ORIGEM:</b> " bestab.etbcod    "<BR>" skip
                    "<b>PEDIDO:</b> " tt-compraven.pednum format ">>>>>>>>9"
                     "<BR>" skip   
                    "<b>VENDA:</b> " plani.numero   
                        format ">>>>>>>>9"              "<BR>" skip
                    "<b>DATA :</b> " plani.pladat 
                        format "99/99/9999"            "<BR>" skip
                    "<b>VENDEDOR:</b> " .       
                if plani.vencod <> 0 and avail func
                then put func.funnom .
                else put ".................................. ".
                put "<BR>"  skip.
                put "<b>FILIAL DESTINO:</b> " .
                if plani.etbcod <> bestab.etbcod
                then put string(plani.etbcod,">>9").
                else put string(bestab.etbcod,">>9").
                put "<BR>" skip.

                put "<b>OBS:</b> " vabcobs[1] format "x(60)" "<BR>" skip
                                   vabcobs[2] format "x(60)" "<BR>" skip
                                   vabcobs[3] format "x(60)" "<BR>" skip
                                   vabcobs[4] format "x(60)" "<BR>" skip.
                output close.
 
/***                pause 2 no-message.***/
                do vi = 1 to 5:
                    if c-mail[vi] <> ""
                    then do:
                       unix silent value("/admcom/progr/mail.sh "
                                 + "~"" + v-assunto + "~"" + " ~"" 
                                 + varquivo + "~"" + " ~"" 
                                 + c-mail[vi] + "~""
                                 + " ~"pedidosespeciais@lebes.com.br~""
                                 + " ~"text/html~"").
                        pause 0.
                    end.
                    else leave.
                end.
            end.                 
          end.  
        end.
        message varqmail. pause.
        
        output to value(varqmail).
        do vi = 2 to 5:
            if c-mail[vi] <> ""
            then export c-mail[vi].
        end.
        output close.
    end.
end procedure.      


