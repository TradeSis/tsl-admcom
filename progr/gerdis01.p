{admcab.i}
def input parameter p-catcod like produ.catcod.
def input parameter p-clacod like clase.clacod.

def temp-table tt-venloj
    field etbcod like movim.etbcod 
    field valor as dec
    index i1 etbcod
    index i2 valor descending.

def temp-table tt-venmes
    field etbcod like movim.etbcod 
    field valor as dec
    field anoref as dec
    field mesref as dec
    index i1 etbcod anoref mesref
    .

def buffer btt-venmes for tt-venmes.

def temp-table tt-classe
    field clacod like clase.clacod
    index i1 clacod.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
find clase where clase.clacod = p-clacod no-lock no-error.
if not avail clase
then next.
create tt-classe.
tt-classe.clacod = clase.clacod.
for each bclase where bclase.clasup = clase.clacod no-lock:
    create tt-classe.
    tt-classe.clacod = bclase.clacod.
    for each cclase where cclase.clasup = bclase.clacod no-lock:
        create tt-classe.
        tt-classe.clacod = cclase.clacod.
        for each dclase where dclase.clasup = cclase.clacod no-lock:
            create tt-classe.
            tt-classe.clacod = dclase.clacod.
            for each eclase where eclase.clasup = dclase.clacod no-lock:
                create tt-classe.
                tt-classe.clacod = eclase.clacod.
            end.
        end.
    end.
end.

    /**
    for each produ where produ.catcod = p-catcod no-lock,
        first tt-classe where tt-classe.clacod = produ.clacod no-lock:
    
        disp "processando...." produ.procod produ.pronom
         with frame f-d 1 down centered no-box no-label
         row 10 color message.
        pause 0.     
    
        for each movim where movim.procod = produ.procod and
                         movim.movtdc = 5 and
                         movim.movdat >= today - 180
                         no-lock.
                         
            find first tt-venmes where
                   tt-venmes.etbcod = movim.etbcod  and
                   tt-venmes.anoref = year(movim.movdat) and
                   tt-venmes.mesref = month(movim.movdat) no-error.
            if not avail tt-venmes
            then do:
                create tt-venmes.
                assign
                    tt-venmes.etbcod = movim.etbcod
                    tt-venmes.anoref = year(movim.movdat)
                    tt-venmes.mesref = month(movim.movdat) 
                    .
            end.
            tt-venmes.valor = tt-venmes.valor + (movim.movpc * movim.movqtm).
        end.
    end.
    for each tabaux where
             tabaux.tabela = "filref" + string(p-catcod)
             no-lock.
        for each tt-venmes where
                 tt-venmes.etbcod = int(tabaux.nome_campo)
                 :
            find first btt-venmes where
                       btt-venmes.etbcod = int(tabaux.valor_campo) and
                       btt-venmes.anoref = tt-venmes.anoref and
                       btt-venmes.mesref = tt-venmes.mesref
                       no-error.
            if not avail btt-venmes
            then do:
                create btt-venmes.
                assign
                    btt-venmes.etbcod = int(tabaux.valor_campo)
                    btt-venmes.anoref = tt-venmes.anoref 
                    btt-venmes.mesref = tt-venmes.mesref
                    btt-venmes.valor  = tt-venmes.valor
                    .
            end.           
        end.         
    end.
    def var vtotger as dec.         
    for each tt-venmes:
        find first tt-venloj where
                   tt-venloj.etbcod = tt-venmes.etbcod
                   no-error.
        if not avail tt-venloj
        then do:
           create tt-venloj.
           tt-venloj.etbcod = tt-venmes.etbcod. 
        end.
        tt-venloj.valor = tt-venloj.valor + tt-venmes.valor.
        vtotger = vtotger + tt-venmes.valor.         
    end.
    */
def var vqtdfil as int.

def temp-table tt-fil
    field etbcod like estab.etbcod 
    field qtdtam as int
    field pct as dec.
    
def temp-table tt-distr
    field codtipo like tipodistr.codtip
    field etbcod like estab.etbcod
    field tamanho like tipodistr.tamanho
    field qtdtam as int
    field pct as dec decimals 5 format ">>9.99999".

def var a as dec decimals 5 format ">>9.99999".
def var b as dec decimals 5 format ">>9.99999".
def var c as dec decimals 5 format ">>9.99999".
      
for each tipodistr where 
        tipodistr.catcod = p-catcod 
        by tipodistr.codtipo
        by tipodistr.tamanho:
     for each etbtam where etbtam.catcod = p-clacod and
                          etbtam.tamanho = tipodistr.tamanho and
                          etbtam.situacao = "E" 
                           no-lock.
        create tt-distr.
        tt-distr.codtipo = tipodistr.codtipo.
        tt-distr.etbcod = etbtam.etbcod.
        tt-distr.tamanho = tipodistr.tamanho.
         
        if tipodistr.qtdtam = 0
        then assign
                vqtdfil = vqtdfil + 1
                tt-distr.qtdtam =  1.
        else assign
                vqtdfil = vqtdfil + tipodistr.qtdtam
                tt-distr.qtdtam = tipodistr.qtdtam.
     end.
     assign a = 0 b = 0 c = 0.
     a = 100 / vqtdfil.
     b = 100 - (a * vqtdfil).   
     /*
     repeat:
        if a * vqtdfil = 100
        then leave.
        if b = .00001
        then leave.
        a = a + (b / vqtdfil).
        b = 100 - (a * vqtdfil).
     end.
     */
     for each tt-distr:
        tt-distr.pct = a.
        if b <> 0 and tt-distr.qtdtam = 1
        then assign
                tt-distr.pct = tt-distr.pct + b
                b = 0.
        
     end.
end.

run rel-distr.

procedure rel-distr:
    def var varquivo as char.
    def var v-des as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/relpdis." + string(time).
    else varquivo = "..~\relat~\relpdis." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""gerdis01"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """ PARAMETROS PARA DISTRIBUICAO """ 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    for each tt-distr break by tt-distr.codtipo
                            by tt-distr.tamanho
                            by tt-distr.etbcod:
        if first-of(tt-distr.codtipo)
        then do:
            v-des = "".
            for each tipodistr where 
                     tipodistr.codtipo = tt-distr.codtipo
                        no-lock:
                v-des = v-des + tipodistr.tamanho + "-" + 
                            trim(string(tipodistr.qtdtam,">9")) + ";".
            end.      
            disp tt-distr.codtipo label "Tipo Dis." 
                 v-des format "x(60)" no-label   
                 with frame f-tdis 1 down side-label.              
        end.
        if first-of(tt-distr.tamanho)
        then do:
            disp tt-distr.tamanho column-label "Tam"
                with frame f-distr.
        end.        
        disp tt-distr.etbcod column-label "Fil"
             (tt-distr.pct * tt-distr.qtdtam) 
                (total by tt-distr.tamanho) column-label "% Distr"
                format ">>9.99999"
             with frame f-distr down.
        down with frame f-distr.     
    end.
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.
