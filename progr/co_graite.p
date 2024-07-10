/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}
/***
    def var vpreqtent like proenoc.qtdmercaent.
***/
    def var vlipqtd   like liped.lipqtd.
/***
    def var vlipqtdcanc like proenoc.qtdmercacanc.
***/
 
def var vgrade1      like taman.tamcod format "xxx" extent 16.
def var vgrade2      like taman.tamcod format "xxx" extent 16.
def var vbarra2      as char format "x" extent 16.
 vbarra2 = "|".
    def var vseq as int.
    def var vconta as int.
    def var vcontatot as int.
    def var vqtdgrades as int.
  
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial ["Alteracao","",""," ",""].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5
    initial [" Alteracao de Grade ",
             " Consulta ",
             " Consulta ",
             " Consulta ",
             "  "].
def var esqhel2         as char format "x(12)" extent 5.

def input parameter precpai as recid.
def input parameter precped as recid.

def buffer item-produ for produpai.

find pedid where recid(pedid) = precped no-lock.
find produpai where recid(produpai) = precpai no-lock.
find lipedpai of pedid where lipedpai.itecod = produpai.itecod no-lock no-error.
    
if pedid.sitped <> "A"
then 
    assign esqcom1 = "" .

def var vcornom     like cor.cornom.

    form
        esqcom1
            with frame f-com1
                 row 23
                    no-box no-labels side-labels column 1 centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

/*
def shared workfile wfcor
    field itecod    like produ.itecod
    field cornom    like cor.cornom
    field corcod    like cor.corcod
    field grade     as int format ">>>>" extent 27
    field lippreco  like liped.lippreco
    field alterado  as   log.
*/


def new shared workfile wfite
    field itecod    like produ.itecod
    field lipqtd    as   int
    field preqtent  as   int
    field lipqtdcanc as int    
    field lippreco  like liped.lippreco.

def workfile wfitecor
    field itecod    like produ.itecod
    field corcod    like cor.corcod
    field cornom    like cor.cornom
    field tot       as int
    field qtd       as int
    field grade     as int format ">>>" extent 64
    field lippreco  like liped.lippreco.


def new shared workfile wfcor
    field itecod    like produ.itecod
    field corcod    like cor.corcod
    field cornom    like cor.cornom
    field seq       as int
    field grade     as int format ">>>" extent 16
    field rec-produ as recid extent 16
    field lippreco  like liped.lippreco
    field alterado  as log.

/*
def shared workfile wfcor
    field itecod    like produ.itecod
    field corcod    like cor.corcod
    field cornom    like cor.cornom
    field seq       as int
    field grade     as int format ">>>" extent 16
    field rec-produ as recid extent 16
    field lippreco  like liped.lippreco
    field alterado  as log.
*/
/***
for each liped of pedid no-lock:
***/
for each liped where liped.etbcod = lipedpai.etbcod
                     and liped.pedtdc = lipedpai.pedtdc
                     and liped.pednum = lipedpai.pednum
                     and liped.lipcor = string(lipedpai.paccod)
                   no-lock.
    
    find produ of liped no-lock no-error.
    if not avail produ
    then next.
    
    if produ.itecod <> lipedpai.itecod
    then next.
    
    find first wfite where wfite.itecod = produ.itecod no-error.
    if not available wfite
    then create wfite.
    assign
        wfite.itecod   = produ.itecod
        wfite.lippreco = liped.lippreco.
end.

for each wfite .
    
    for each produ where produ.itecod = wfite.itecod no-lock.

        find first wfitecor where
                wfitecor.itecod = produ.itecod and
                wfitecor.corcod = produ.corcod
                no-error.
        if not avail wfitecor
        then create wfitecor.
        assign
            wfitecor.itecod = produ.itecod
            wfitecor.corcod = produ.corcod.
            wfitecor.qtd    = wfitecor.qtd + 1.    
    end.
   
    for each wfitecor.
        
        vseq = 1.
        vconta = 0.
        vcontatot = 0.
        vqtdgrades = wfitecor.qtd / 16.
        for each produ where 
                produ.itecod = wfitecor.itecod and
                produ.corcod = wfitecor.corcod
                no-lock
                by produ.procod.
            vconta = vconta + 1.
            vcontatot = vcontatot + 1.
            
            if vconta = 16
            then assign
                    vseq = vseq + 1
                    vconta = 1.
            find first wfcor where
                    wfcor.itecod = produ.itecod and
                    wfcor.corcod = produ.corcod and
                    wfcor.seq    = vseq
                no-error.
            if  not available wfcor 
            then create wfcor.
            assign
                wfcor.itecod = produ.itecod
                wfcor.corcod = produ.corcod
                wfcor.seq    = vseq.
                wfcor.rec-produ[vconta] = recid(produ).
        
            find gratam where gratam.gracod = produ.gracod and
                          gratam.tamcod = produ.protam
                    no-lock no-error.
            find cor   of produ no-lock.
            find liped of pedid where 
                liped.procod = produ.procod no-lock.
            assign    
                    wfcor.cornom = cor.cornom
                    wfcor.lippreco = wfite.lippreco.
                
            if avail liped
            then do:
/***
                for each proenoc of liped no-lock.
                    assign                              
                        wfcor.grade[vconta] = wfcor.grade[vconta] +
                                    proenoc.qtdmerca.
                        wfitecor.grade[vcontatot] = 0.
                end.
***/
            end.            
        end.                            
    end. 
end.                            


        vgrade1 = "".
        vconta = 0.
        for each produ where produ.itecod = produpai.itecod
            no-lock
            by produ.procod.
            vconta = vconta + 1.
            if vconta > 16 then leave.
            vgrade1[vconta] = produ.protam.
        end.  
        vgrade2 = "".
        vconta = 0.
        def var vi as int.
        vi = 0.
        for each produ where produ.itecod = produpai.itecod
            no-lock
            by produ.procod.
            vi = vi + 1.
            if vi <= 16 then next.
            vconta = vconta + 1.
            vgrade2[vconta] = produ.protam.
        end.  
        
        form 
            produpai.pronom format "x(10)" 
                   space(1) "|" space(0)
         vgrade1[1] space(0) "|" space(0)
         vgrade1[2] space(0) "|" space(0)
         vgrade1[3] space(0) "|" space(0)
         vgrade1[4] space(0) "|" space(0)
         vgrade1[5] space(0) "|" space(0)
         vgrade1[6] space(0) "|" space(0)
         vgrade1[7] space(0) "|" space(0)
         vgrade1[8] space(0) "|" space(0)
         vgrade1[9] space(0) "|" space(0)
         vgrade1[10] space(0) "|" space(0)
         vgrade1[11] space(0) "|" space(0)
         vgrade1[12] space(0) "|" space(0)
         vgrade1[13] space(0) "|" space(0)
         vgrade1[14] space(0) "|" space(0)
         vgrade1[15] space(0) "|" space(0)
         vgrade1[16] space(0) "|" space(0) skip
          space(10) space(1)    space(1)
         vgrade2[1] space(0) vbarra2[1] space(0)
         vgrade2[2] space(0) vbarra2[2] space(0)
         vgrade2[3] space(0) vbarra2[3] space(0)
         vgrade2[4] space(0) vbarra2[4] space(0)
         vgrade2[5] space(0) vbarra2[5] space(0)
         vgrade2[6] space(0) vbarra2[6] space(0)
         vgrade2[7] space(0) vbarra2[7] space(0)
         vgrade2[8] space(0) vbarra2[8] space(0)
         vgrade2[9] space(0) vbarra2[9] space(0)
         vgrade2[10] space(0) vbarra2[10] space(0)
         vgrade2[11] space(0) vbarra2[11] space(0)
         vgrade2[12] space(0) vbarra2[12] space(0)
         vgrade2[13] space(0) vbarra2[13] space(0)
         vgrade2[14] space(0) vbarra2[14] space(0)
         vgrade2[15] space(0) vbarra2[15] space(0)
         vgrade2[16] space(0) vbarra2[16] space(0)
         "TOT"
            with frame fgratam no-box no-labels
                  color white/cyan row 12 width 81
                    overlay.
        disp produpai.pronom
             vgrade1
             vbarra2 when vconta <> 0
             vgrade2 when vconta <> 0
           fill("-",80) format "x(80)"
            with frame fgratam.


def var vuso        as log             extent 27.
def var vtot as int format ">>>>".

    def new shared frame fcor.
        form 
         wfcor.cornom format "x(11)"
                        space(0) "|" space(0)
         wfcor.grade[1] space(0) "|" space(0)
         wfcor.grade[2] space(0) "|" space(0)
         wfcor.grade[3] space(0) "|" space(0)
         wfcor.grade[4] space(0) "|" space(0)
         wfcor.grade[5] space(0) "|" space(0)
         wfcor.grade[6] space(0) "|" space(0)
         wfcor.grade[7] space(0) "|" space(0)
         wfcor.grade[8] space(0) "|" space(0)
         wfcor.grade[9] space(0) "|" space(0)
         wfcor.grade[10] space(0) "|" space(0)
         wfcor.grade[11] space(0) "|" space(0)
         wfcor.grade[12] space(0) "|" space(0)
         wfcor.grade[13] space(0) "|" space(0)
         wfcor.grade[14] space(0) "|" space(0)
         wfcor.grade[15] space(0) "|" space(0)
         wfcor.grade[16] space(0) "|" space(0)
         vtot            

         with frame fcor
            4 down row 15 centered width 160 no-labels no-box
                overlay.

/***
    vpreqtent = 0.
    vlipqtd   = 0.
    vlipqtdcanc = 0.
    run busca-liped-filho (recid(pedid),
                           lipedpai.itecod,
                           output vlipqtd,
                           output vpreqtent,
                           output vlipqtdcanc).
***/                           


disp 
     produpai.itecod       column-label "Codigo"
/*     produpai.refer                                    format "x(10)"*/
     produpai.pronom       column-label "Descricao"    format "x(19)"
     vlipqtd       column-label "Qtd"          format ">>>>9.99"
/*
     vPreQtEnt     column-label "Entr."        format ">>>>9"
     vlipqtdcanc   column-label "Canc"         format ">>>>9"
*/
     lipedpai.lippreco     column-label "Preco"        format ">>,>>9.99"
     /*
     v-valmerca         column-label "Total"        format ">>>,>>9.99"
     */
     
    with frame f-proenoc1 1 down centered  row 09 no-box width 81
                 overlay no-underline color message.
    display 
"                                  G R A D E                                   ~   " 
        with frame fgrad centered width 81 no-box color message
                row 11 overlay.
    
 
bl-princ:
repeat:   
    pause 0.
    disp esqcom1 with frame f-com1.
    /*disp esqcom2 with frame f-com2.*/
    if  recatu1 = ? then
        find first wfcor where wfcor.itecod = produpai.itecod
                         no-lock no-error.
    else
        find wfcor where recid(wfcor) = recatu1 no-lock.
    if  not available wfcor then do:
        message "Cadastro de wfcor Vazio".
        undo, leave.
    end.
    clear frame fcor all no-pause.
    display
        wfcor.cornom
        wfcor.grade
            with frame fcor.
    color disp black/cyan wfcor.grade
                with frame fcor.

    recatu1 = recid(wfcor).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next wfcor where wfcor.itecod = produpai.itecod
                        no-lock no-error.
        if  not available wfcor then
            leave.
        if frame-line(fcor) = frame-down(fcor) then
            leave.
        down with frame fcor.
        display
            wfcor.cornom
            wfcor.grade
                with frame fcor.
        color disp black/cyan wfcor.grade
                with frame fcor.
    end.
    up frame-line(fcor) - 1 with frame fcor.

    repeat with frame fcor:
        find wfcor where recid(wfcor) = recatu1 no-lock.
        status default
            if esqregua
            then esqhel1[esqpos1] + if
                                       esqhel1[esqpos1] <> ""
                                    then string(wfcor.cornom)
                                    else ""
            else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                    then string(wfcor.itecod) + "-" +
                                         wfcor.cornom
                                    else "".

        choose field wfcor.cornom help ""
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down   page-up
                  PF4 F4 ESC return
                  A B C D E F G H I J K L M N O P Q R S T U V W Y X Z
                  a b c d e f g h i j k l m n o p q r s t u v w y x z
                  1 2 3 4 5 6 7 8 9 0).

        if (asc(keyfunction(lastkey)) >= 48  and
            asc(keyfunction(lastkey)) <= 57)  or
           (asc(keyfunction(lastkey)) >= 65  and
            asc(keyfunction(lastkey)) <= 90)  or
           (asc(keyfunction(lastkey)) >= 97  and
            asc(keyfunction(lastkey)) <= 122)
        then do on error undo, retry on endkey undo, leave:
            /*
            vcornom = vcornom + keyfunction(lastkey).
            find first cor where
                             wfcor.cornom begins vcornom no-lock no-error.
            if not avail wfcor then do:
                vcornom = keyfunction(lastkey).
                find first wfcor where
                                 wfcor.cornom begins vcornom no-lock no-error.
            end.
            if available wfcor then recatu1 = recid(wfcor).
            leave.
            */
        end.
        status default "".
        if keyfunction(lastkey) = "TAB" then do:
            if  esqregua then do:
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
        if  keyfunction(lastkey) = "cursor-right" then do:
            if  esqregua then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
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
        if keyfunction(lastkey) = "cursor-left" then do:
            if  esqregua then do:
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
        if  keyfunction(lastkey) = "page-down" then do:
            do reccont = 1 to frame-down(fcor):
                find next wfcor where wfcor.itecod = produpai.itecod
                                 no-lock no-error.
                if not avail wfcor
                then leave.
                recatu1 = recid(wfcor).
            end.
            leave.
        end.
        if  keyfunction(lastkey) = "page-up" then do:
            do reccont = 1 to frame-down(fcor):
                find prev wfcor  where wfcor.itecod = produpai.itecod
                                no-lock  no-error.
                if not avail wfcor
                then leave.
                recatu1 = recid(wfcor).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next wfcor  where wfcor.itecod = produpai.itecod
                            no-lock no-error.
            if not avail wfcor
            then next.
            color display white/cyan wfcor.cornom.
            if frame-line(fcor) = frame-down(fcor)
            then scroll with frame fcor.
            else down with frame fcor.
        end.
        if  keyfunction(lastkey) = "cursor-up" then do:
            find prev wfcor  where wfcor.itecod = produpai.itecod
                           no-lock  no-error.
            if not avail wfcor
            then next.
            color display white/cyan wfcor.cornom.
            if frame-line(fcor) = 1
            then scroll down with frame fcor.
            else up with frame fcor.
        end.
        if  keyfunction(lastkey) = "end-error" then
            leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave:
          hide frame fcor no-pause.
          if  esqregua then do:
              display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                      with frame f-com1.
            if  esqcom1[esqpos1] = "Alteracao" then do with frame fcor:
                vuso = no.
                find item-produ where item-produ.itecod = wfcor.itecod.
                for each gratam where gratam.gracod = item-produ.gracod.
                    vuso[gratam.graord] = yes.
                end.
                update
                    wfcor.grade[1]  when vuso[1]
                    wfcor.grade[2]  when vuso[2]
                    wfcor.grade[3]  when vuso[3]
                    wfcor.grade[4]  when vuso[4]
                    wfcor.grade[5]  when vuso[5]
                    wfcor.grade[6]  when vuso[6]
                    wfcor.grade[7]  when vuso[7]
                    wfcor.grade[8]  when vuso[8]
                    wfcor.grade[9]  when vuso[9]
                    wfcor.grade[10] when vuso[10]
                    wfcor.grade[11] when vuso[11]
                    wfcor.grade[12] when vuso[12]
                    wfcor.grade[13]  when vuso[13]
                    wfcor.grade[14]  when vuso[14]
                    wfcor.grade[15]  when vuso[15]
                    wfcor.grade[16]  when vuso[16].
                    
                vtot = 0.

                wfcor.alterado = yes.

                do  vi = 1 to 16:
                    vtot = vtot + wfcor.grade[vi].
                end.
                disp vtot.

                run acerta-liped (recid(wfcor)).
                
            end.
          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                    with frame f-com2.
          end.
        end.
        display wfcor.cornom
                wfcor.grade
                    with frame fcor.
       color disp black/cyan wfcor.grade
                with frame fcor.
        if  esqregua then
            display esqcom1[esqpos1] with frame f-com1.
        else
            display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(wfcor).
    end.
end.
/*
color display normal 
        wfcor.cornom
        wfcor.grade
            with frame fcor.
*/            
hide frame f-com1 no-pause.
hide frame f-com2 no-pause.
hide frame fgratam no-pause.
hide frame fcor no-pause.            
hide frame f-proenoc1 no-pause.
hide frame fgrad no-pause.




/***
procedure busca-liped-filho.
def input parameter par-recid-pedid as recid.
def input parameter par-itecod as int.
def output parameter vlipqtd like proenoc.qtdmerca.
def output parameter vpreqtent like proenoc.qtdmercaent.
def output parameter vlipqtdcanc like proenoc.qtdmercacanc.

find pedid where recid(pedid) = par-recid-pedid no-lock.
    
    /* Busca quantidades do liped dos filhos */
    for each produ where
            produ.itecod = par-itecod
            no-lock.
        for each liped of pedid where
                    liped.procod = produ.procod
                    no-lock.
            for each proenoc of liped no-lock.
                vlipqtd     = vlipqtd       + proenoc.qtdmerca.        
                vpreqtent   = vpreqtent     + proenoc.qtdmercaent.
                vlipqtdcanc = vlipqtdcanc   + proenoc.qtdmercacanc.
            end.
        end.                    
    end.            

end procedure.
***/


procedure acerta-liped.
def input parameter par-recid-wfcor as recid.

message "so consulta".
/*
find wfcor where recid(wfcor) = par-recid-wfcor.

do vi = 1 to 16 transaction.

    find produ where
        recid(produ) = wfcor.rec-produ[vi] no-lock no-error.
    if not avail produ
    then next.
            
    find first liped of pedid where
                liped.procod = produ.procod
        exclusive no-error.                
    if not avail liped
    then do: 
        create liped. 
        assign 
            liped.etbped    = pedid.etbped 
            liped.pedtdc    = pedid.pedtdc 
            liped.procod    = produ.procod 
            liped.lipsit    = "A" 
            liped.pednum    = pedid.pednum 
            liped.lipqtd    = wfcor.grade[vi]
            liped.lippreco  = lipedpai.lippreco 
            liped.lipipi    = lipedpai.lipipi 
            liped.lipdes    = lipedpai.lipdes 
            liped.lipacfin  = lipedpai.lipacf 
            liped.lipsubst  = lipedpai.lipsubst 
/*            liped.lipout    = lipedpai.lipoutros  */
            liped.lipfrete  = lipedpai.lipfrete 
            /*                liped.lipvrbpubl   = vlipvrbpubl */ . 
    end.                
    else do:
        if wfcor.grade[vi] = 0
        then do:
            for each proenoc of liped.
                delete proenoc.
            end.    
            delete liped.
        end.
        else do:
            liped.lipqtd = wfcor.grade[vi].
            for each proenoc of liped.
                proenoc.qtdmerca = liped.lipqtd.
            end.
        end.
    end.
end.
*/

end procedure.


