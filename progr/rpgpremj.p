{admcab.i}

{seltpmo.i " " "PREMIO"}
def var vetbcod like estab.etbcod.
def var vdti as date.
def var vdtf as date.
def var vfuncod like func.funcod.
def var vsit as char init "LIB".
 
def temp-table tt-estab 
    field etbcod like estab.etbcod.

def temp-table tt-titluc
    field etbcod like titluc.etbcod
    field vencod like titluc.vencod
    field titnum like titluc.titnum
    field titsit like titluc.titsit
    field titvlcob like titluc.titvlcob
    field clifor like titluc.clifor
    field titdtven like titluc.titdtven 
    field titdtpag like titluc.titdtpag 
    field desti as char
    index i1 etbcod desti titnum
    .
     
update vetbcod at 10 label "Filial"
        with frame f1 1 down width 80
        side-label.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp  estab.etbnom no-label with frame f1.
    create tt-estab.
    tt-estab.etbcod = estab.etbcod.
end.
else do:
    for each estab no-lock.
        create tt-estab.
        tt-estab.etbcod = estab.etbcod.
    end.    
end. 
pause 0.

run d-tipo-sel-m.
def var vi as int.

if keyfunction(lastkey) = "END-ERROR"
then do:

    do vi = 1 to 8:
        if dm-tipo[vi] = "*"
        then v-tipodes = dd-tipo[vi]. 
    end.
    if v-tipodes = ? or
       v-tipodes = ""
    then undo.
end.
if v-tipodes = ?
then undo.
if v-tipodes = ""
then undo.

if v-tipodes = "VENDEDOR"
then do:
    update vfuncod at 7 label "Consultor"
        with frame f1.
    if vfuncod > 0
    then do:
    find func where func.etbcod = vetbcod and
                func.funcod = vfuncod
                no-lock.
    disp   func.funnom  no-label with frame f1.
    end.
end.

update vdti    at 1 label "Periodo Inicial"   format "99/99/9999"
       vdtf     label "Final"             format "99/99/9999"
       with frame f1.

if vdti = ? or
   vdtf = ? or
   vdti > vdtf
then undo.
   
vsit = "".
update vsit at 8 label "Situacao" format "x(3)"
        validate(vsit = "LIB" or
                 vsit = "PAG" or
                 vsit = "EXC" or
                 Vsit = "BLO" or
                 Vsit = "NEG" or
                 vsit = "PEN" or
                 Vsit = "   ", "")
        help "LIB=Liberado PAG=Pago BLO=Bloqueado EXC=Excluido PEN=PendentePB"
    with frame f1.
        
def var v-retorna as log.        

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/rpgprem1u." + string(time).
else varquivo = "l:~\relat~\rpgprem1u." + string(time).

if vsit  = "PAG"
then do:
    for each tt-estab no-lock:
    disp "Processando.... " tt-estab.etbcod no-label
        with frame f-m 1 down centered row 10
        color message no-box side-label.
    pause 0.     
    vetbcod = tt-estab.etbcod.
    for each titluc where
        titluc.etbcod = vetbcod and
        (if vfuncod > 0
        then  titluc.vencod = vfuncod else true) and
        titluc.titdtpag >= vdti and
        titluc.titdtpag <= vdtf 
        no-lock:
        disp titluc.titnum no-label with frame f-m.
        pause 0.
        v-retorna = yes.
        do vi = 1 to 8:
            if dm-tipo[vi] = "*"
            then do:
                v-tipodes = dd-tipo[vi]. 

                if v-tipodes = "CREDIARISTA" AND
                    titluc.vencod = 150
                then v-retorna = no.
                else do:    
                    if acha("PREMIO",titluc.titobs[2]) = v-tipodes
                    then v-retorna = no.
                end.
                if v-retorna = no 
                then leave.
            end.
        end.
        if v-retorna = yes
        then next.
        
        if vsit <> "" and
            titluc.titsit <> vsit
        then next. 
        find first foraut where
                  foraut.forcod = titluc.clifor no-lock.
        create tt-titluc.
        assign
            tt-titluc.etbcod = titluc.etbcod
            tt-titluc.vencod = titluc.vencod
            tt-titluc.titnum = titluc.titnum
            tt-titluc.titsit = titluc.titsit
            tt-titluc.titvlcob = titluc.titvlcob
            tt-titluc.clifor = titluc.clifor
            tt-titluc.titdtven = titluc.titdtven
            tt-titluc.titdtpag = titluc.titdtpag
            tt-titluc.desti = v-tipodes
             .
    end.
    end.         
end.
else do:
    for each tt-estab no-lock:
    disp "Processando.... " tt-estab.etbcod no-label
        with frame f-m1 1 down centered row 10
        color message no-box side-label.
    pause 0. 
    vetbcod = tt-estab.etbcod.
    for each titluc where
         titluc.etbcod = vetbcod and
         (if vfuncod > 0
            then titluc.vencod = vfuncod else true) and
         titluc.titdtven >= vdti and
         titluc.titdtven <= vdtf 
         no-lock:
        disp titluc.titnum no-label with frame f-m1.
        pause 0.
         v-retorna = yes.
        do vi = 1 to 8:
            if dm-tipo[vi] = "*"
            then do:
                v-tipodes = dd-tipo[vi]. 

                if v-tipodes = "CREDIARISTA" AND
                    titluc.vencod = 150
                then v-retorna = no.
                else do:    
                    if acha("PREMIO",titluc.titobs[2]) = v-tipodes
                    then v-retorna = no.
                end.
            end.
        end.
        if v-retorna = yes
        then next.
                
        if  vsit <> "" and
            titluc.titsit <> vsit
        then next. 
        
        find first foraut where
                          foraut.forcod = titluc.clifor no-lock.
              
        create tt-titluc.
        assign
            tt-titluc.etbcod = titluc.etbcod
            tt-titluc.vencod = titluc.vencod
            tt-titluc.titnum = titluc.titnum
            tt-titluc.titsit = titluc.titsit
            tt-titluc.titvlcob = titluc.titvlcob
            tt-titluc.clifor = titluc.clifor
            tt-titluc.titdtven = titluc.titdtven
            tt-titluc.titdtpag = titluc.titdtpag
            tt-titluc.desti = v-tipodes
             .
    end.   
    end.
end.

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "100"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA COMERCIAL"""
            &Tit-Rel   = """ RELATORIO DE PREMIOS "" + v-tipodes  "
            &Width     = "100"
            &Form      = "frame f-cabcab"}

disp with frame f1.

          
for each tt-titluc use-index i1
        break by tt-titluc.etbcod
              by tt-titluc.desti
              by tt-titluc.vencod:

    if first-of(tt-titluc.etbcod)
    then  disp tt-titluc.etbcod column-label "Fil"
            with frame f-disp.
    
    if first-of(tt-titluc.desti)
    then disp tt-titluc.desti format "x(10)" no-label 
                with frame f-disp.
                
    find first foraut where
               foraut.forcod = tt-titluc.clifor no-lock.
        
   find first func where func.funcod = tt-titluc.vencod
                         and func.etbcod = tt-titluc.etbcod no-error.   

  if not avail func
  then next.

    disp tt-titluc.etbcod
         func.UserCod
         tt-titluc.vencod    
         tt-titluc.titnum       format "x(10)"
         tt-titluc.titsit           format "x(3)"
         tt-titluc.titvlcob(total by tt-titluc.vencod)
         tt-titluc.clifor           format ">>>>>>>>>9"
         foraut.fornom no-label  format "x(40)"
         tt-titluc.titdtven     format "99/99/99"
         tt-titluc.titdtpag     format "99/99/99"
         with frame f-disp down width 150.

end.
             
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.             
