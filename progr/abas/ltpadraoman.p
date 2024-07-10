
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
def var vemite      like abasLT.emite.

def var vtipo as char .
vtipo = par-tipo.


def var vestoqdepos like estoq.estatual.
def var vatende     like estoq.estatual.
def var vreservado  like estoq.estatual.
def var vEtbCod   like abasLT.EtbCod.
def var vdisponivel like estoq.estatual.

def buffer babasLT for abasLT.
def buffer bestab    for estab.   

form produ.procod label "Produto"
     produ.pronom no-label format "x(18)"
     with frame f-prod side-label 1 down width 80
                 overlay color withe/brown row 3
                            /***title produ.refer ***/.
def var vtipoEmite as log format "CD-Loja/Fornecedor-CD" label "Tipo LT [C/F]" init yes.

l1:
repeat  with frame f-linha:
    update vtipoEmite with frame f-buspro.
    if vtipoEmite /* Loja */
    then do:
        update vemite with no-validate with frame f-buspro side-labels row 3 overlay width 80.
        find estab where estab.etbcod = vemite no-lock no-error.
        if avail estab 
        then do:
            if estab.tipoLoja <> "CD"
            then do:
                message "Emite tem que ser um CD".
                next.
            end.
        end.
        else do:
            message "CD nao encontrado".
            next.
        end.
        disp estab.etbnom no-label
            with frame f-buspro.
    end.
    else do:
        update vemite with frame f-buspro.
        find forne where forne.forcod = vemite no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor nao cadastrado".
            next.
        end.
        disp forne.fornom @ estab.etbnom with frame f-buspro.     
    end.     

def temp-table ttdis
    field linha         as int    format "99"    
    field loja          like abasLT.EtbCod       extent 12 format "->>99"
 field leadtimeinfo        as int                  extent 12 format ">>>>>"
 field modaleadtimeinfo        as int                  extent 12 format ">>>>>" .


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
    skip   
    ttdis.leadtimeinfo[01]    at 1
    ttdis.leadtimeinfo[02]    
    ttdis.leadtimeinfo[03]    
    ttdis.leadtimeinfo[04]    
    ttdis.leadtimeinfo[05]    
    ttdis.leadtimeinfo[06]    
    ttdis.leadtimeinfo[07]    
    ttdis.leadtimeinfo[08]    
    ttdis.leadtimeinfo[09]    
    ttdis.leadtimeinfo[10]    
    ttdis.leadtimeinfo[11]    
    ttdis.leadtimeinfo[12]    
    "MOVEIS"
    skip   
    ttdis.modaleadtimeinfo[01]    at 1
    ttdis.modaleadtimeinfo[02]    
    ttdis.modaleadtimeinfo[03]    
    ttdis.modaleadtimeinfo[04]    
    ttdis.modaleadtimeinfo[05]    
    ttdis.modaleadtimeinfo[06]    
    ttdis.modaleadtimeinfo[07]    
    ttdis.modaleadtimeinfo[08]    
    ttdis.modaleadtimeinfo[09]    
    ttdis.modaleadtimeinfo[10]    
    ttdis.modaleadtimeinfo[11]    
    ttdis.modaleadtimeinfo[12]    
    "MODA  "
    
    with no-label frame frame-a  no-box
     4 down centered color white/red row 6.

def var vleadtimeinfo like abasLT.leadtimeinfo.
def var vmodaleadtimeinfo like abasLT.modaleadtimeinfo.

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

    if vtipoemite
    then do:
        if bestab.tipoloja <> "NORMAL"
        then next.
    end.    
    else do:
        if bestab.tipoLOja <> "CD"
        then next.
    end.
    if vi = 0
    then do:
        vconta = vconta + 1.
        create ttdis.
        assign ttdis.linha = vconta.
        recdis = recid(ttdis).
    end.  
    find ttdis where recid(ttdis) = recdis.
    vi = vi + 1.
    ttdis.loja    [vi] = bestab.etbcod.
    vleadtimeinfo = 0.
    vmodaleadtimeinfo = 0.
    
    for each abasLT where    abasLT.emite  = vemite 
                        and  abasLT.etbcod = bestab.etbcod    
                                no-lock.
        vleadtimeinfo     = vleadtimeinfo    +  abasLT.leadtimeinfo.
        vmodaleadtimeinfo = vleadtimeinfo    +  abasLT.modaleadtimeinfo.
        
    end. 
    ttdis.leadtimeinfo    [vi] = vleadtimeinfo.
    ttdis.modaleadtimeinfo[vi] = vmodaleadtimeinfo.
    
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

            color display message ttdis.leadtimeinfo
                        with frame frame-a.
            choose field ttdis.leadtimeinfo[01] help ""
                go-on(cursor-down cursor-up
/*                      cursor-left cursor-right*/
                      page-down   page-up
                      PF4 F4 ESC return) .

            color display normal ttdis.leadtimeinfo
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
                color display white/red ttdis.leadtimeinfo[01] with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttdis
                then next.
                color display white/red ttdis.leadtimeinfo[01] with frame frame-a.
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
                        
                        update ttdis.leadtimeinfo [vi] 
                            when ttdis.loja[vi] <> 0 . 
                         update ttdis.modaleadtimeinfo [vi] 
                            when ttdis.loja[vi] <> 0 . 

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
        ttdis.leadtimeinfo[01]           when loja[01]  <> 0
        ttdis.leadtimeinfo[02]           when loja[02]  <> 0
        ttdis.leadtimeinfo[03]           when loja[03]  <> 0
        ttdis.leadtimeinfo[04]           when loja[04]  <> 0
        ttdis.leadtimeinfo[05]           when loja[05]  <> 0
        ttdis.leadtimeinfo[06]           when loja[06]  <> 0
        ttdis.leadtimeinfo[07]           when loja[07]  <> 0
        ttdis.leadtimeinfo[08]           when loja[08]  <> 0
        ttdis.leadtimeinfo[09]           when loja[09]  <> 0
        ttdis.leadtimeinfo[10]           when loja[10]  <> 0
        ttdis.leadtimeinfo[11]           when loja[11]  <> 0
        ttdis.leadtimeinfo[12]           when loja[12]  <> 0
        
        ttdis.modaleadtimeinfo[01]           when loja[01]  <> 0
        ttdis.modaleadtimeinfo[02]           when loja[02]  <> 0
        ttdis.modaleadtimeinfo[03]           when loja[03]  <> 0
        ttdis.modaleadtimeinfo[04]           when loja[04]  <> 0
        ttdis.modaleadtimeinfo[05]           when loja[05]  <> 0
        ttdis.modaleadtimeinfo[06]           when loja[06]  <> 0
        ttdis.modaleadtimeinfo[07]           when loja[07]  <> 0
        ttdis.modaleadtimeinfo[08]           when loja[08]  <> 0
        ttdis.modaleadtimeinfo[09]           when loja[09]  <> 0
        ttdis.modaleadtimeinfo[10]           when loja[10]  <> 0
        ttdis.modaleadtimeinfo[11]           when loja[11]  <> 0
        ttdis.modaleadtimeinfo[12]           when loja[12]  <> 0
        
        with frame frame-a.
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
        if xttdis.loja[vi] = 0 or
           xttdis.loja[vi] = ?
           then next.
        /*if xttdis.leadtimeinfo[vi] = 0 then next.**/
        vEtbCod = xttdis.loja[vi].
        find xestab where xestab.etbcod = xttdis.loja[vi] no-lock no-error. 
        find first abasLT where abasLT.EtbCod = vetbcod 
                            and abasLT.emite  = vemite
                           no-lock no-error. 
        
        vrec = recid(abasLT).
        
        if not available abasLT 
        then do: 
            do transaction:
                create abasLT. 
                assign 
                   abasLT.EtbCod   = vEtbCod 
                   abasLT.emite    = vemite.
                vrec = recid(abasLT).   
                find current abasLT no-lock no-error.
                
            end.
                                    
        end. 
        do transaction:
            
            find abasLT where recid(abasLT) = vrec no-lock
                no-error.
            if avail abasLT
            then do:
                find current abasLT exclusive.
                abasLT.leadtimeinfo = xttdis.leadtimeinfo[vi].
                abasLT.modaleadtimeinfo = xttdis.modaleadtimeinfo[vi].
                if abasLT.leadtimeinfo = 0 and
                   abasLT.modaleadtimeinfo = 0
                then delete abaslt.
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

