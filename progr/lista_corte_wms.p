
{admcab.i}

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vbox as int  format "99".
def var vfil as int  format "999".

def var vpednum as int.

vdti = today.
vdtf = today.

update vdti label "Periodo de"
       vdtf label "Ate"
       with frame f-d 1 down side-label width 80.

if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
    "Verifique o periodo informado."
    view-as alert-box.
    undo.
end.    
       
update vbox at 1 label "Box"  with frame f-d.
find first tab_box where tab_box.box = vbox no-lock no-error.
if not avail tab_box
then do:
    bell.
    message color red/with
    "Verifique o BOX informado."
    view-as alert-box.
    undo.
end.

update vfil label "Filial" with frame f-d .
if vfil > 0
then do:
find first estab where estab.etbcod = vfil no-lock no-error.
if not avail estab
then do:
    bell.
    message color red/with
    "Verifique a FILIAL informada." view-as alert-box.
    undo.
end.

disp estab.etbnom no-label with frame f-d.
end.
    
def var varquivo as char.
    
varquivo = "/admcom/relat/lsita_corte." + string(time).
    
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""lsita_corte"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """LISTAGEM CORTE CORTE""" 
                &Width     = "100"
                &Form      = "frame f-cabcab"}

disp with frame f-d.

for each tdocbase where
         tdocbase.tdcbcod = "ROM" and
         tdocbase.DtEnv  >= vdti  and
         tdocbase.DtEnv  <= vdtf  and
         (if vbox > 0 then tdocbase.box     = vbox else true)  and
         (if vfil > 0 then tdocbase.etbdes  = vfil else true)
         no-lock:
    for each tdocbpro where of tdocbase no-lock:
        find produ where produ.procod = tdocbpro.procod no-lock.
        

        vpednum = tdocbpro.pednum.
        
        release abastransf.
        find abascorteprod where abascorteprod.dcbcod  = tdocbpro.dcbcod and
                                 abascorteprod.dcbpseq = tdocbpro.dcbpseq
            no-lock no-error.
        if avail abascorteprod
        then do:
            find abastransf of abascorteprod no-lock no-error.
            if avail abastransf
            then do:
                if abastransf.pedexterno <> ?
                then do:
                    if num-entries(abastransf.pedexterno,"_") > 1
                    then vpednum = int(entry(1,abastransf.pedexterno,"_")) no-error.
                    else vpednum = int(abastransf.pedexterno) no-error.
                    if vpednum = ?
                    then vpednum = tdocbpro.pednum.
                end.
            end.    
        end.
                                             
        
        disp produ.procod
             produ.pronom
             produ.catcod column-label "Cat"
             tdocbase.etbdes column-label "Filial"
             vpednum column-label "Pedido" format ">>>>>>>>>9"
             tdocbpro.movqtm column-label "Quant"
             tdocbpro.movqtm * (if produ.procvcom > 0
                                     then produ.procvcom
                                     else 1)    column-label "Volumes"
                                     format ">>>>>>9"
             tdocbpro.dcbcod  column-label "Numero!Corte"
             string(tdocbase.HrEnv,"hh:mm:ss")
                              column-label "Hora!Corte"
             with frame f-disp down  width 120.
    end.
end.
     
        /**     
        find first peddocbpro where peddocbpro.dcbcod  = tdocbpro.dcbcod and
                                 peddocbpro.procod  = tdocbpro.procod and
                                 peddocbpro.etbdes  = tdocbase.Etbdes and
                                 peddocbpro.pednum  = wroma.pednum
                                 no-error.
        if not avail peddocbpro
        then create peddocbpro.
        ASSIGN peddocbpro.dcbcod  = tdocbpro.dcbcod 
               peddocbpro.procod  = tdocbpro.procod 
               peddocbpro.pednum  = wroma.pednum
               peddocbpro.movqtm  = wroma.wped
               peddocbpro.QtdCont = 0
               peddocbpro.etbdes  = tdocbase.Etbdes.
        **/
        
        
    output close.

    run visurel.p(varquivo,"").
        
