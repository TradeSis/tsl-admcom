def var vletra as ch.
def var vok as log.
def var v2 as int.
def buffer b2menu for menu.
def var vf6 as log.
def var vniv as i.
def var vaux as char.
def var vaux1 as char.
def var letra as char extent 7 initial ["a","b","c","d","e","f","g"].
def var vmostra1 as log.
def var vmostra2 as log.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqcom1         as char format "x(35)" extent 16.            
def var esqcom2         as char format "x(42)" extent 16.
def var esqcom3         as char format "x(19)" extent 12.
def var esqcom4         as char format "x(33)" extent 13.
def var esqcom5         as char format "x(33)" extent 13.
def var v1 as char.
def buffer bmenu for menu.

def var vhelp as char format "x(65)" .                      
def input parameter par-parametro as char.
def var par-modulo as char.

esqcom1 = "".

def var i as int.
def var esqord1 as int extent 16.
def var esqord2 as int extent 16.

{cabec.i}

def var vdesc1 as char.
def var vdesc2 as char.
def var vdesc3 as char.
def var vprograma  as char.
def var vparametro as char.

par-modulo = acha("MODULO",par-parametro).
i = 0.
for each menu where menu.aplicod = par-modulo and menu.menniv = 1 no-lock.
    i = i + 1.
    if i > 16 
    then do:
        message "Problema Numero de NIVEIS DE PROCESSOS - MODULO " par-modulo.
        pause 1 no-message.
        leave.
    end.
    v2 = 0.        
    for each b2menu where b2menu.aplicod = par-modulo and
                        b2menu.menniv  = 2 and
                        b2menu.ordsup  = menu.menord no-lock.  
        v2 = v2 + 1. 
    end.
    esqcom1[i] = (if v2 > 16 then "!" + string(v2) + "! " else "" ) + 
                caps(menu.mentit)  .
    esqord1[i] = menu.menord.
end.

i = 0.

form esqcom1
          with frame f-com1 col 2 three-d
                 row 4 no-box no-labels side-labels overlay 1 col.
form esqcom2
          with frame f-com2 col 37 three-d
                 row 3 title v1  no-labels side-labels overlay 1 col.
form
      esqcom3[1]
      esqcom3[2]
      esqcom3[3]
      esqcom3[4] skip
      esqcom3[5]
      esqcom3[6]
      esqcom3[7]
      esqcom3[8]  /*skip
      esqcom3[9]
      esqcom3[10]
      esqcom3[11]
      esqcom3[12]   */
          with frame f-com3 three-d
                 row 21 no-box no-labels side-labels overlay.

find aplicativo where aplicativo.aplicod = par-modulo no-lock.
{tsframe.i 
           "MODULO"
           aplicativo.aplinom 
           """ESCOLHA O PROCESSO"""
           """BS/MENU""" } .

disp esqcom3 with frame f-com3.

esqpos1 = 1.    
esqpos2 = 1.
disp  esqcom1 with frame f-com1.
color display message esqcom1[esqpos1] with frame f-com1.
disp  esqcom2 with frame f-com2.

repeat:
    esqcom2 = "".
    i = 0. 
    esqord2 = 0.
    for each menu where menu.aplicod = par-modulo and
                        menu.menniv  = 2 and
                        menu.ordsup  = esqord1[esqpos1] no-lock.  
        i = i + 1. 
        if i > 16 
        then leave.
        esqord2[i] = menu.menord.  

        vok = yes.
        if not sremoto
        then run sys/tsmsegur.p  
                (menu.menpro, 
                 sfuncod, 
                 menu.mencod, 
                 no, /* Com mensagem? */ 
                 output vok).
        if vok and
           menu.menpro <> ""
        then esqcom2[i] = string(if i <= 9
                          then string(i)
                          else letra[i - 9]) + ". " + caps(menu.mentit).
        else esqcom2[i] = "   " + lc(menu.mentit).        
        vniv = 2.
    end.
    if i = 0
    then do:
        find first bmenu where
            bmenu.aplicod = par-modulo and
            bmenu.menniv = 1 and
            bmenu.ordsup = 0 and
            bmenu.menord = esqord1[esqpos1]
            no-lock no-error.
        if avail bmenu
        then do:
            vniv = 1.
            esqord2[1] = esqord1[esqpos1].
            esqcom2[1] = "1. " + bmenu.mentit.
        end.
    end.
    hide frame f-com2 no-pause.
    v1 = esqcom1[esqpos1].

    display esqcom2 with frame f-com2.
    display esqcom3 with frame f-com3.
    
    vhelp = "Para As Opcoes Abaixo 'TECLE' LETRA entre [] ".
    substring(esqcom1[esqpos1],34,2) = "->".
    disp esqcom1[esqpos1] with frame f-com1.    
    vf6 = no.
    if func.superusuario
    then do:
        message color normal "CTRL-A - Controle de Acessos".
    end.

    readkey.
    
    if keyfunction(lastkey) = "HELP"
    then run applhelp.p.
    
    hide message no-pause.
    if keylabel(lastkey) = "CTRL-A" 
    then do:
        if not func.superusuario
        then do:
            next.
        end.
        vf6 = yes.
        message "DIGITE a OPCAO DO MENU".
        readkey.
    end.
    
    esqcom1[esqpos1] = v1.
    disp esqcom1[esqpos1] with frame f-com1.    
    
    def var vord as int.
    vord = if keyfunction(lastkey) = "a" then 10 else
           if keyfunction(lastkey) = "b" then 11 else
           if keyfunction(lastkey) = "c" then 12 else
           if keyfunction(lastkey) = "d" then 13 else
           if keyfunction(lastkey) = "e" then 14 else
           if keyfunction(lastkey) = "f" then 15 else
           if keyfunction(lastkey) = "g" then 16 else 
           if length(keyfunction(lastkey)) = 1
           then int(keyfunction(lastkey))
           else ?.

    find first menu where
        menu.aplicod = par-modulo and
        menu.menniv = vniv and
        menu.ordsup = (if vniv = 1 then 0 else esqord1[esqpos1]) and
        menu.menord = esqord2[vord]
        no-lock no-error.
    if avail menu then    do:
        find bmenu where 
            bmenu.aplicod = menu.aplicod and
            bmenu.menniv = 1 and
            bmenu.ordsup = 0 and
            bmenu.menord = menu.ordsup
            no-lock no-error.
        vaux = (if menu.menare <> ""
                then caps(menu.menare)
                else "BS") 
                    + "/" + menu.menpro.
        vaux1 = aplicativo.aplinom + 
                if avail bmenu
                then ("/" + bmenu.mentit)
                else "".
        {tsframe.i 
               "MODULO"
               vaux1
               menu.mentit
               vaux}               

               if vf6
               then do:
                    run sys/menseg.p (menu.menpro).
               end.
               else do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    run sys/tsmexec.p (menu.menpro,
                                   sfuncod,
                                   menu.mencod,
                                   output vok).
               end.
                
               SPROGRAMA = "logapl".

        hide all no-pause.
        disp  esqcom1 with frame f-com1.
        color display message esqcom1[esqpos1] with frame f-com1.
        disp  esqcom2 with frame f-com2.
        {tsframe.i 
               "MODULO"
               aplicativo.aplinom 
               """ESCOLHA O PROCESSO"""
               """BS/MENU""" } .
        next.
    end.                              
    
    color display normal esqcom1[esqpos1] with frame f-com1.

    vletra = keyfunction(lastkey).
        
    color display messages esqcom1[esqpos1] with frame f-com1.
            
    if keyfunction(lastkey) = "End-Error"
    then do:
        run hide.
        return.
    end.
    if keyfunction(lastkey) = "cursor-down"
    then do:
        color display normal esqcom1[esqpos1] with frame f-com1.
        esqpos1 = if esqpos1 = 16 then 16 else esqpos1 + 1.
        color display messages esqcom1[esqpos1] with frame f-com1.
    end.
    if keyfunction(lastkey) = "cursor-up"
    then do:                                                      
        color display normal esqcom1[esqpos1] with frame f-com1.
        esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
        color display messages esqcom1[esqpos1] with frame f-com1.
    end.
    
end.    


procedure hide.
hide frame f-com1   no-pause. 
hide frame f-com2   no-pause. 
hide frame f-com3   no-pause. 
hide frame sa       no-pause. 
hide frame sa1      no-pause.
hide frame border  no-pause.  
hide frame f-com4 no-pause.  
hide frame border2  no-pause.  
hide frame f-com5 no-pause.  
end procedure.
