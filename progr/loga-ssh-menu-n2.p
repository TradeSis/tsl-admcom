{/admcom/progr/admcab.i}

def input parameter p-recid as recid.

find sshmenu where recid(sshmenu) = p-recid no-lock.

def temp-table tt-sshmenu like sshmenu
        index i1 aplicod menniv ordsup menord
        index i2 ordsup menord.

def shared frame f-linha.    
form    tt-sshmenu.menord
        tt-sshmenu.mentit format "x(30)"
        with frame f-linha 10 down no-label row 4 width 38.


def buffer bsshmenu for sshmenu.
for each bsshmenu  no-lock.
    create tt-sshmenu.
    buffer-copy bsshmenu to tt-sshmenu.
    tt-sshmenu.mentit = caps(tt-sshmenu.mentit).
end.
    
form    tt-sshmenu.menord
        tt-sshmenu.mentit format "x(30)"
        with frame f-linha1 15 down no-label row 4 column 40 width 38
        overlay
        .
         
{setbrw.i}


def var vprograma as char.
l2:
    repeat:

    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?.
        
    hide frame f-linha1 no-pause.
    clear frame f-linha1 all.

    {sklclstb.i  
        &color = with/cyan
        &file = tt-sshmenu  
        &cfield = tt-sshmenu.mentit
        &noncharacter = /* 
        &ofield = " tt-sshmenu.menord "
        &aftfnd1 = " "
        &where  = " tt-sshmenu.ordsup = sshmenu.menord "
        &aftselect1 = " 
                        if tt-sshmenu.menpro <> """"
                        then do:
                            vprograma = tt-sshmenu.menpro + "".p"".
                            if search(vprograma) <> ?
                            then
                            run value(tt-sshmenu.menpro + "".p""). 
                            else do:
                                bell.
                                message color red/with
                                ""Programa "" vprograma "" não disponível""
                                view-as alert-box.
                            end.
                            hide all.
                            view frame fc1. pause 0.
                            view frame fc2. pause 0.
                            view frame f-linha. pause 0.
                            view frame f-linha1. pause 0.
                            next keys-loop.
                        end.
                        else do:
                            bell.
                            message color red/with
                            ""Programa "" vprograma "" não disponível""
                            view-as alert-box.
                        end.
                     
                        "
        &go-on = TAB 
        &naoexiste1 = "  leave l2. "  
        &otherkeys1 = "  "
        &locktype = " no-lock use-index i2 "
        &form   = " frame f-linha1 "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        
        leave l2.       
    END.
end.

hide frame f-linha1 no-pause.
clear frame f-linha1 all.
