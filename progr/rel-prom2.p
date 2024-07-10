{admcab.i}

{setbrw.i}

def temp-table tt-relat
field etbcod      as integer   
field pladat      as date
field planum      like plani.numero
field procod      as integer
field pronom      as char
field sequencia   as char      
index idx01 etbcod.

def var vdti as date.
def var vdtf as date.
def var vsequencia-promo as integer.
def var vimei as integer.
def var varquivo as char.
def var vlista-promo as char.
def var vcont     as integer.
def var vpromo-aux as char.
def var v-tem-promo as log.

def temp-table tt-planos
    field codviv as int format ">>>9"
    index ch-codviv codviv.

form
    a-seelst format "x" column-label "*"
    estab.etbcod
    estab.etbnom
        with frame f-nome
             centered down title "LOJAS"
             color withe/red overlay.

def var v-cod as int.
def var v-cont as int.
def buffer bestab for estab.

def temp-table tt-lj  like estab.
def var vdata as date.

assign sresp = false.
                
update sresp label "Seleciona Filiais?" with frame f-plaviv.

if sresp
then do:
                
    bl_sel_filiais:
    repeat:
                    
        hide frame f-inclui. 

        run p-seleciona-filiais.

        if keyfunction(lastkey) = "end-error"
        then leave bl_sel_filiais.
                                     
    end.

end.

display "*** Gerando todas as Filiais ***" skip
                with frame f-plaviv.

pause.                    
                    

update vdti label "Periodo de........" format "99/99/9999"  with frame f-plaviv.
    
display " a " with frame f-plaviv.

update  vdtf no-label format "99/99/9999"  with frame f-plaviv.

disp skip  with frame f-plaviv.    

update vsequencia-promo format ">>>>>>9" with frame f-plaviv .

find first ctpromoc where ctpromoc.sequencia = vsequencia-promo no-lock no-error.

disp skip 
     vsequencia-promo label "N. Módulo........." format ">>>>>>9"
                        with frame f-plaviv side-labels.
                                  pause 0.
                                  
update vimei label "IMEI.............." with frame f-plaviv .

    for each estab no-lock:

        release tt-lj.
        if can-find (first tt-lj)
        then do:
         
            find first tt-lj where tt-lj.etbcod = estab.etbcod no-lock no-error.
            if not avail tt-lj
            then next.

        end.
        
        disp estab.etbcod label "Loja"
             with frame f-mostra centered side-labels. pause 0.
             
        do vdata = vdti to vdtf:
            disp vdata no-label
                 with frame f-mostra. pause 0.
        
            for each plani where plani.movtdc = 5
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = vdata no-lock:
                
                find first tbprice where tbprice.etb_venda = plani.etbcod
                                     and tbprice.nota_venda = plani.numero
                                     and tbprice.data_venda = plani.pladat
                                    no-lock no-error.
                               
                if vimei <> 0
                    and avail tbprice
                    and string(vimei) <> tbprice.serial
                then next.
                
                assign vlista-promo = ""
                       v-tem-promo  = no.
                
                do vcont = 1 to num-entries(plani.usercod,";"):
    
                    assign vpromo-aux = trim(entry(vcont,plani.usercod,";")).
        
                    if vpromo-aux = "" then next.
            
                    release ctpromoc.
                    find first ctpromoc
                         where ctpromoc.sequencia = int(vpromo-aux)
                                    no-lock no-error.

                    if avail ctpromoc
                    then do:    
                        assign 
                            vlista-promo =
                               vlista-promo + trim(string(ctpromoc.sequencia))
                                            + "; ".

                        if vsequencia-promo = 0
                            or vsequencia-promo = ctpromoc.sequencia
                        then assign v-tem-promo  = yes.

                    end.
                    pause 0.

                end.
                
                if v-tem-promo             
                then
                for each movim where movim.etbcod = plani.etbcod
                                 and movim.placod = plani.placod
                                  no-lock:
                    
                    if movim.movtdc <> plani.movtdc then next.
                    if movim.movdat <> plani.pladat then next.

                    find first produ where produ.procod = movim.procod
                                                    no-lock no-error.

                    create tt-relat.
                    assign tt-relat.etbcod    = movim.etbcod
                           tt-relat.pladat    = movim.movdat
                           tt-relat.planum    = plani.numero
                           tt-relat.procod    = movim.procod.
                           
                    if avail produ
                    then tt-relat.pronom = produ.pronom.
                    
                    assign tt-relat.sequencia = vlista-promo.
                    
                end.
            end.
        end.             
    end.
        
	if opsys = "UNIX"
    then varquivo = "../relat/rel-viv3." + string(time).
    else varquivo = "..\relat\rel-viv3." + string(time).
 
	{mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""rel-vivo""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """RELATÓRIO DE VENDAS NO MÓDULO DE PROMOÇÕES - DE "" 
                   + string(vdti,""99/99/9999"") + "" A ""
                   + string(vdtf,""99/99/9999"")"
        &Width     = "120"
        &Form      = "frame f-cabcab"}

        for each tt-relat:
                 
            disp
            tt-relat.etbcod format ">>>9" label "Filial"
            tt-relat.pladat format "99/99/9999"  label "Data"
			tt-relat.planum format ">>>>>>>>>9" label "NF Venda"
			tt-relat.procod format ">>>>>>>>9"  label "Cod"
			tt-relat.pronom format "x(55)"      label "Produto"
			tt-relat.sequencia format "x(20)" Label "Nº Módulo"
            skip with width 200.
                   
        end.

    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.                       
    else do:
        {mrod.i}.
    end.

procedure p-seleciona-filiais:
            
{sklcls.i
    &File   = estab
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = estab.etbnom    
    &Ofield = " estab.etbcod"
    &Where  = " estab.etbcod <= 200"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "estab.etbcod" 
    &PickFrm = "99999" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each bestab where bestab.etbcod <= 200 no-lock:
                a-seelst = a-seelst + "","" + string(bestab.etbcod,""99999"").
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.             
repeat :
    v-cod = 0.
    v-cod = int(substr(a-seelst,v-cont,5)).
    v-cont = v-cont + 6.
    if v-cod = 0
    then leave.
    create tt-lj.
    tt-lj.etbcod = v-cod.
end.

end.

sresp = no.

message "Gerar EXCEL ?" update sresp.

if sresp = no then leave.

if sresp = yes then 
output to /admcom/relat/rel-prom2.csv.
for each tt-relat:
                 
            disp
            tt-relat.etbcod format ">>>9" label "Filial"
            ";"
			tt-relat.pladat format "99/99/9999"  label "Data"
			";"
			tt-relat.planum format ">>>>>>>>>9" label "NF Venda"
			";"
			tt-relat.procod format ">>>>>>>>9"  label "Cod"
			";"
			tt-relat.pronom format "x(55)"      label "Produto"
			";"
			tt-relat.sequencia format "x(20)" Label "Nº Módulo"
            skip with width 200.
                   
        end.
output close.

message "Arquivo rel-prom2.csv gerado em L:/relat" view-as alert-box.