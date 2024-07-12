/*  prepedidpro.p */

{cabec.i}

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def var par-tipo  as char.
def var par-setor as char.
def var par-tiporom   as char.
def var par-tipodistr as char.
def var par-ordem as char.
def var vmarca as log format "*/".
def var vprocod like produ.procod.

def var vtipo as char .
vtipo = par-tipo.


def var vestoqdepos like estoq.estatual.
def var vatende     like estoq.estatual.
def var vreservado  like estoq.estatual.
def var vEtbCod   like abasgrade.EtbCod.
def var vdisponivel like estoq.estatual.

def buffer babasgrade for abasgrade.
def buffer bestab    for estab.   

form produ.procod label "Produto"
     produ.pronom no-label format "x(18)"
     with frame f-prod side-label 1 down width 80
                 overlay color withe/brown row 3
                            /***title produ.refer ***/.


l1:
repeat  with frame f-linha:
   update vprocod with no-validate with frame f-buspro
    side-labels row 3 overlay width 80.
   find produ where produ.procod = vprocod no-lock no-error.
   if avail produ then do:
      display produ.procod produ.pronom produ.fabcod with frame f-prod.
   end.
   else
      next.   
   
/*
run estoque.
*/



def temp-table ttdis
    field linha         as int    format "99"    
    field loja          like abasgrade.EtbCod       extent 12 format "->>99"
    field estatual      like estoq.estatual     extent 12 format "->>>>"
    field abgqtd        as int                  extent 12 format ">>>>>" .


form
/*  ttdis.linha         format ">"*/
    ttdis.loja[01]  
    ttdis.loja[02]  
    ttdis.loja[03]   
    ttdis.loja[04]   
    ttdis.loja[05]   
    ttdis.loja[06]   
    ttdis.loja[07]   
    ttdis.loja[08]   
    ttdis.loja[09]   
    ttdis.loja[10]   
    ttdis.loja[11]   
    ttdis.loja[12]   
    
    skip
"------------------------------------------------------------------------------"
    ttdis.estatual[01]  at 1
    ttdis.estatual[02]  
    ttdis.estatual[03]   
    ttdis.estatual[04]   
    ttdis.estatual[05]   
    ttdis.estatual[06]   
    ttdis.estatual[07]   
    ttdis.estatual[08]   
    ttdis.estatual[09]   
    ttdis.estatual[10]   
    ttdis.estatual[11]   
    ttdis.estatual[12]   
    "Estoque"
    skip   
    ttdis.abgqtd[01]    at 1
    ttdis.abgqtd[02]    
    ttdis.abgqtd[03]    
    ttdis.abgqtd[04]    
    ttdis.abgqtd[05]    
    ttdis.abgqtd[06]    
    ttdis.abgqtd[07]    
    ttdis.abgqtd[08]    
    ttdis.abgqtd[09]    
    ttdis.abgqtd[10]    
    ttdis.abgqtd[11]    
    ttdis.abgqtd[12]    
    "Grade"
    skip(2)      
    with no-label frame frame-a  no-box.

def var vabgqtd like abasgrade.abgqtd.
def var recdis as recid.
def var vconta as int.
def var vi as int.
vconta = 0.
vi = 0.
   for each ttdis.
    delete ttdis.
   end.


for each bestab 
                    no-lock by bestab.etbcod.

    
    if vi = 0
    then do:
        vconta = vconta + 1.
        create ttdis.
        assign ttdis.linha = vconta.
        recdis = recid(ttdis).
    end.  
    find ttdis where recid(ttdis) = recdis.
    vi = vi + 1.
    find estoq where estoq.etbcod = bestab.etbcod and
                     estoq.procod = produ.procod  no-lock no-error.
    ttdis.estatual[vi] = if avail estoq
                        then estoq.estatual
                        else 0.
    ttdis.loja    [vi] = bestab.etbcod.
    vabgqtd = 0.
    for each abasgrade where  abasgrade.EtbCod = bestab.etbcod 
                        and  abasgrade.procod =  produ.procod    
                                no-lock.
        vabgqtd     = vabgqtd    +  abasgrade.abgqtd.
    end. 
    ttdis.abgqtd    [vi] = vabgqtd.
    if vi = 12
    then vi = 0.
end.


def buffer bttdis       for ttdis.
def var vttdis         like ttdis.linha.


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
    esqpos2  = 1.

bl-princ:
repeat:

/*    disp esqcom1 with frame f-com1.*/
/*    disp esqcom2 with frame f-com2.*/
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttdis where recid(ttdis) = recatu1 no-lock.
    if not available ttdis
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttdis).
    /*
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    */
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttdis
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
            find ttdis where recid(ttdis) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttdis.linha)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttdis.linha)
                                        else "".

            color display message ttdis.abgqtd
                        with frame frame-a.
            choose field ttdis.abgqtd[01] help ""
                go-on(cursor-down cursor-up
/*                      cursor-left cursor-right*/
                      page-down   page-up
                      PF4 F4 ESC return) .

            color display normal ttdis.abgqtd
                        with frame frame-a.
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
                    if not avail ttdis
                    then leave.
                    recatu1 = recid(ttdis).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttdis
                    then leave.
                    recatu1 = recid(ttdis).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttdis
                then next.
                color display white/red ttdis.abgqtd[01] with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttdis
                then next.
                color display white/red ttdis.abgqtd[01] with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form ttdis
                 with frame f-ttdis color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                
                do with frame frame-a.
                    find ttdis where
                            recid(ttdis) = recatu1 
                        exclusive.
                        
                    do vi = 1 to 12. /* on endkey undo .*/

                        if keyfunction(lastkey) = "END-ERROR" 
                        then do:
                            run atualiza.
                            next bl-princ.
                        end.
                        
                        update ttdis.abgqtd [vi] when ttdis.loja[vi] <> 0 . 
                        run atualiza.
                        run estoque.
                    end.
                end.
                run atualiza.
                find next ttdis no-error.
                if avail ttdis
                then recatu1 = recid(ttdis).
                leave.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        /*
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(ttdis).
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

end.

procedure frame-a.
display /*dis.linha         when linha = 0*/
        ttdis.loja[01]          when loja[01]  <> 0 
        ttdis.loja[02]          when loja[02]  <> 0 
        ttdis.loja[03]          when loja[03]  <> 0 
        ttdis.loja[04]          when loja[04]  <> 0 
        ttdis.loja[05]          when loja[05]  <> 0 
        ttdis.loja[06]          when loja[06]  <> 0 
        ttdis.loja[07]          when loja[07]  <> 0 
        ttdis.loja[08]          when loja[08]  <> 0 
        ttdis.loja[09]          when loja[09]  <> 0 
        ttdis.loja[10]          when loja[10]  <> 0 
        ttdis.loja[11]          when loja[11]  <> 0 
        ttdis.loja[12]          when loja[12]  <> 0 
        ttdis.abgqtd[01]           when loja[01]  <> 0
        ttdis.abgqtd[02]           when loja[02]  <> 0
        ttdis.abgqtd[03]           when loja[03]  <> 0
        ttdis.abgqtd[04]           when loja[04]  <> 0
        ttdis.abgqtd[05]           when loja[05]  <> 0
        ttdis.abgqtd[06]           when loja[06]  <> 0
        ttdis.abgqtd[07]           when loja[07]  <> 0
        ttdis.abgqtd[08]           when loja[08]  <> 0
        ttdis.abgqtd[09]           when loja[09]  <> 0
        ttdis.abgqtd[10]           when loja[10]  <> 0
        ttdis.abgqtd[11]           when loja[11]  <> 0
        ttdis.abgqtd[12]           when loja[12]  <> 0
        ttdis.estatual[01]      when loja[01]  <> 0
        ttdis.estatual[02]      when loja[02]  <> 0
        ttdis.estatual[03]      when loja[03]  <> 0
        ttdis.estatual[04]      when loja[04]  <> 0
        ttdis.estatual[05]      when loja[05]  <> 0
        ttdis.estatual[06]      when loja[06]  <> 0
        ttdis.estatual[07]      when loja[07]  <> 0
        ttdis.estatual[08]      when loja[08]  <> 0
        ttdis.estatual[09]      when loja[09]  <> 0
        ttdis.estatual[10]      when loja[10]  <> 0
        ttdis.estatual[11]      when loja[11]  <> 0
        ttdis.estatual[12]      when loja[12]  <> 0
        with frame frame-a 3 down centered color white/red row 6.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first ttdis where true
                                                no-lock no-error.
    else  
        find last ttdis  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next ttdis  where true
                                                no-lock no-error.
    else  
        find prev ttdis   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev ttdis where true  
                                        no-lock no-error.
    else   
        find next ttdis where true 
                                        no-lock no-error.
        
end procedure.
         

procedure atualiza.
def var vi as int.
def buffer xttdis for ttdis.
def buffer xestab for estab.
def var vlipseq as int.
def var vrec as recid.
for each xttdis.
    do vi = 1  to 12.
        if xttdis.loja[vi] = 0 then next.
        /*if xttdis.abgqtd[vi] = 0 then next.**/
        vEtbCod = xttdis.loja[vi].
        find xestab where xestab.etbcod = xttdis.loja[vi] no-lock no-error. 
        find first abasgrade where abasgrade.EtbCod = vEtbCod 
                              and abasgrade.procod =  produ.procod  
                           no-lock no-error. 
        
        vrec = recid(abasgrade).
        
        if not available abasgrade 
        then do: 
            do transaction:
                create abasgrade. 
                assign 
                   abasgrade.EtbCod   = vEtbCod 
                   abasgrade.procod   = produ.procod 
                   abasgrade.etbfun   = setbcod.
                   abasgrade.funcod   = sfuncod.
                vrec = recid(abasgrade).   
                find current abasgrade no-lock no-error.
                
            end.
                                    
        end. 
        do transaction:
            
            find abasgrade where recid(abasgrade) = vrec no-lock
                no-error.
            if avail abasgrade
            then do:
                find current abasgrade exclusive.
                abasgrade.abgqtd = xttdis.abgqtd[vi].
                if abasgrade.abgqtd = 0
                then delete abasgrade   .
                else do.
                end.
            end.       
        end.
                    
    end.
end.

end procedure.


procedure estoque.   
    /*
   find estoq where estoq.EtbCod = sEtbCod and
                    estoq.procod = produ.procod
                    no-lock no-error.
   vestoqdepos = if avail estoq
                 then estoq.estatual
                 else 0.
   vdisponivel = disponivel(produ.procod).
   qtdocvado  = reservado (produ.procod).
   disp vestoqdepos 
        vdisponivel
        qtdocvado
        with frame f-prod.

   find fabri of produ no-lock.
    */
end procedure.
