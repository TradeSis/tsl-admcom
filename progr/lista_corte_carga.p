
{admcab.i}

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vbox as int  format "99".
def var vfil as int  format "999".
def var vpedido as int format ">>>>>>9".
def var vcarga as int format ">>>>>>9".

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
if vbox > 0
then do:
find first tab_box where tab_box.box = vbox no-lock no-error.
if not avail tab_box
then do:
    bell.
    message color red/with
    "Verifique o BOX informado."
    view-as alert-box.
    undo.
end.
end.

update vcarga label "Carregamento" with frame f-d.
/*if vbox = 0 and vcarga = 0
then do:
    bell.
    message color red/with
    "Informar BOX ou CARGA."
    view-as alert-box.
    undo.
end.    
*/

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
                &Cond-Var  = "150" 
                &Page-Line = "66" 
                &Nom-Rel   = ""lsita_corte"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """LISTAGEM CORTE """ 
                &Width     = "150"
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
        find first eblji where
                   eblji.numero_filial = tdocbase.etbdes and
                   eblji.numero_pedido = tdocbpro.dcbcod and
                   eblji.procod = produ.procod and
                   (if vcarga > 0
                    then eblji.numero_carregamento = vcarga else true)
                   no-lock no-error.
        if not avail eblji
        then next.
        find ebljh of eblji no-lock no-error.
        if avail ebljh
        then find plani where plani.placod = ebljh.plani-placod and
                              plani.etbcod = ebljh.plani-etbcod and
                              plani.pladat = ebljh.plani-pladat and
                              plani.movtdc = 6
                              no-lock no-error.
        if avail plani
        then find movim where movim.etbcod = plani.etbcod and
                              movim.placod = plani.placod and
                              movim.movtdc = plani.movtdc and
                              movim.movdat = plani.pladat and
                              movim.procod = produ.procod
                              no-lock no-error.
        disp produ.procod
             produ.pronom
             tdocbase.etbdes column-label "Filial"
             tdocbpro.pednum
             tdocbpro.movqtm column-label "Qtd!Pedida"
             tdocbpro.qtdcon column-label "Qtd!Separada"
             eblji.quantidade when avail eblji column-label "Qtd!Embarcada"
                        format ">>>>>9"
             eblji.numero_carregamento when avail eblji 
                    column-label "Numero!Carregamento"
                    format ">>>>>>9"
             plani.numero when avail plani column-label "NF-e"
             movim.movqtm when avail movim column-label "Qtd NF-e"
             with frame f-disp down  width 150.
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
        
