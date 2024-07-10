{cabec.i}

def input parameter par-rec as recid.


find mdfviagem where recid(mdfviagem) = par-rec no-lock.


def var vemitpro      as log format " /T" label "".
def var vufemi      like plani.ufemi.
def var vufdes      like plani.ufdes.
def var vmunicemi   like munic.cidnom format "x(12)".
def var vmunicdes   like munic.cidnom Format "x(12)".


def var vserie       like plani.serie column-label "Ser".
def var vnumero      like plani.numero format ">>>>>>>>9".
def var vpesobrutoKG like mdfnfe.pesobrutokg.
def var vvalornota   like mdfnfe.valornota.


def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vtabemite as char.
def var vtabdesti as char.

def var vnfeID          like a01_infnfe.ID format "x(44)".
def var vinfnfeChave    like a01_infnfe.chave format "x(44)".

def var vibge-uf-emite as char format "!!".
def var vano           as char format "x(2)".
def var vmes           as char format "x(2)".
def var vemite_cnpj    as char format "x(14)".
def var vmodelo        as char format "x(2)".
def var voperacao as log init no.
def var vrota as int init 1.

 def var vpos as int.
 def var vtam as int.
 
/**
        chave-nfe = "NFe" + ibge-uf-emite + 
                        substr(string(year(tt-plani.pladat),"9999"),3,2) +
                         string(month(tt-plani.pladat),"99") +
                         vemitecgc +
                         modelo-documento +
                         string(int(serie-nfe),"999") +
                         string(tt-plani.numero,"999999999").
 
**/
 
    
    form
        mdfnfe.rotaseq column-label "Sq" 
        vemitpro column-label "*" format " /T" 
        mdfnfe.nfeID    format "xxxxxxxxx..."
        vserie  
        vnumero 
        "EMITE"
        mdfnfe.tabemite no-label format  "x(3)"
        mdfnfe.emite    no-label format ">>>>>>99"
        vufemi          no-label
        /**
        vmunicemi   no-label        
        **/
        mdfnfe.pesobrutoKg no-label space(0) " Kg"
        
        skip
        space(33)
        "DESTI"
        mdfnfe.tabdesti no-label format  "x(3)"
        mdfnfe.desti    no-label format ">>>>>>99"
        vufdes    no-label
        /**
        vmunicdes no-label
        **/
        
        mdfnfe.valornota no-label space(0) " R$"
        with frame frame-nfe 2 down centered color white/red row 12
        title " Incluindo NFEs " no-underline width 80.



repeat with frame fbipa 1 down row 10 centered no-box side-labels
    width 80.
    
    vnfeID = "".
    hide message no-pause.
   message "ENTER 'Digita Numero', P 'Pesquisa NFE pela Placa' ou 'BIPA CHAVE'".
    
    update vnfeID colon 6 label "Chave"  
     help "ENTER-Digita P-Pesquisa NFE ou BIPA CHAVE"
        go-on (p P).
       
    if keyfunction(lastkey) = "P"
    then do:
        run mdfe/escveinfe.p (input recid(mdfviagem)).
        clear frame frame-nfe all no-pause.
        for each mdfnfe of mdfviagem no-lock.
            run mostra.
        end.    
        next.
    end.
    
    if vnfeID = ""
    then do:
        update vetbcod like estab.etbcod colon 4 label "Etb".
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom format "x(1)" no-label.
        vemite_cnpj = estab.etbcgc.
        update vserie label "Ser" format "x(3)".
        update vnumero.
        find first plani where plani.etbcod = estab.etbcod and
                               plani.emite = estab.etbcod and
                               plani.serie  = vserie and
                                plani.numero = int(vnumero)
            no-lock no-error.
        if not avail plani
        then do:
            find first plani where plani.etbcod = estab.etbcod and
                                   plani.emite = estab.etbcod and
                                   plani.serie  = string(int(vserie)) and
                                   plani.numero = int(vnumero)
            no-lock no-error.
            if not avail plani
            then do:
                hide message no-pause.
                message "Nota nao Encontrada".
                pause 1.
                undo, retry.
            end.
        end.
        vvalornota = plani.platot.
        disp vvalornota.
                    
        find first a01_infnfe where
                a01_infnfe.etbcod = plani.etbcod and
                a01_infnfe.placod = plani.placod
                no-lock no-error.
            if not avail a01_infnfe
            then do:
                hide message no-pause.
                message "Chave NFE nao encontrada".
                pause 1.
                undo, retry.
            end.    
            
            vnfeID         = a01_infnfe.ID.
            vinfnfechave   = a01_infnfe.chave.
            disp vnfeid.
            
            find x26_vol of a01_infnfe no-lock no-error.
            if not avail x26_vol  or
               x26_vol.pesoB = 0
            then update vpesobrutokg label "Peso" format ">>>>,>>9.99".
            else vpesobrutokg = x26_vol.pesob.   
            
            vnfeID         = a01_infnfe.ID.
            vinfnfechave   = a01_infnfe.chave.
            disp vvalornota format ">>>>,>>9.99" label "Valor"
                vpesobrutokg vnfeID.
           
        vemite = plani.emite.
        vdesti = plani.desti.
        find tipmov of plani no-lock.
        if tipmov.movtnota
        then do:
            vtabemite = "ESTAB".
            if tipmov.movttra or tipmov.movtdc = 36
            then do:
                vtabdesti = "ESTAB".
            end.    
            else do:
                if tipmov.movtvenda
                then vtabdesti = "CLIEN".
                else vtabdesti = "FORNE".
            end.
        end.
        else do:
            vtabemite = "FORNE".
            vtabdesti = "ESTAB".
        end.
        pause 1 no-message.
        
    end.
    else do:
        if vnfeID begins "NFE"
        then vnfeID = substr(vnfeID,4).
        
        vinfnfechave = "NFe" + substring(vnfeID,1,34). 
        
        vpos = 1.
    
        vtam = 2.
        vibge-uf-emite = substring(vnfeID,vpos,vtam).
        vpos = vpos + vtam.
        
        vtam     = 2.
        vano           = substring(vnfeID,vpos,vtam).
        vpos = vpos + vtam.
        
        vtam = 2.
        vmes           = substring(vnfeID,vpos,vtam).
        vpos = vpos + vtam.
        
        vtam = 14.
        vemite_cnpj    = substring(vnfeID,vpos,vtam).
        vpos = vpos + vtam.
        
        vtam = 2.
        vmodelo        = substring(vnfeID,vpos,vtam).
        vpos = vpos + vtam.
        
        vtam = 3.
        vserie         = substring(vnfeID,vpos,vtam).
        vpos = vpos + vtam.
        
        vtam = 9.
        vnumero        = int(substring(vnfeID,vpos,vtam)).

    
        disp vserie vnumero.

        find first a01_infnfe where
            a01_infnfe.chave = vinfnfechave
            no-lock no-error.
        if not avail    a01_infnfe
        then do:

            find first forne where
                forne.forcgc = vemite_cnpj
                no-lock no-error.
            if not avail forne
            then do:
                hide message no-pause.
                message "Fornecedor nao cadastrado " vemite_cnpj.
                pause.
                undo, retry.
            end.    
            
            hide message no-pause.
            message "NFE é emissao TERCEIROS" forne.forcod
                                              forne.fornom.
            message "              CONFIRMA?" update sresp.
            if not sresp
            then undo, retry.
        
            vtabemite = "FORNE".
            vemite    = forne.forcod.

            vtabdesti = "ESTAB".
            update vetbcod.
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                hide message no-pause.
                message "Estabelecimento nao cadastrado".                
                pause.
                undo, retry.
            end.
            disp estab.etbnom.
            vdesti = estab.etbcod.
            update
                vpesobrutokg
                vvalornota .
                
        end.                        
        else do:
            find plani where plani.etbcod = a01_infnfe.etbcod and
                             plani.placod = a01_infnfe.placod
                no-lock no-error.

            if not avail plani
            then do:
                hide message no-pause.
                message "Nota nao encontrada".
                pause.
                undo, retry.
            end.
            vemite = plani.emite.
            vdesti = plani.desti.
            find tipmov of plani no-lock.
            if tipmov.movtnota
            then do:
                vtabemite = "ESTAB".
                if tipmov.movttra or tipmov.movtdc = 36
                then do:
                    vtabdesti = "ESTAB".
                end.    
                else do:
                    if tipmov.movtvenda
                    then vtabdesti = "CLIEN".
                    else vtabdesti = "FORNE".
                end.
            end.
            else do:
                vtabemite = "FORNE".
                vtabdesti = "ESTAB".
            end.

            find x26_vol of a01_infnfe no-lock no-error.
            if not avail x26_vol  or
               x26_vol.pesoB = 0
            then update vpesobrutokg.
            else vpesobrutokg = x26_vol.pesob.   
            vvalornota = plani.platot.
        end.
        
                                     
    end.

   
    create mdfnfe.

    ASSIGN
    mdfnfe.etbcod      = mdfviagem.etbcod
    mdfnfe.NfeID       = vnfeID
    mdfnfe.infNfeChave = vinfnfechave
    
    mdfnfe.MdfVCod     = mdfviagem.MdfVCod
    mdfnfe.RotaSeq     = vrota
    mdfnfe.tabemite    = vtabemite
    mdfnfe.Emite       = vemite
    mdfnfe.tabdesti    = vtabdesti
    mdfnfe.Desti       = vdesti
    mdfnfe.cnpj        = vemite_cnpj
    mdfnfe.serie       = vserie
    mdfnfe.numero      = int(vnumero)
    mdfnfe.MdfeCod     = ?.
    mdfnfe.valornota   = vvalornota.
    mdfnfe.pesobrutokg = vpesobrutokg.
    
    if voperacao = no then voperacao = yes.
    vrota = vrota + 1.

    run mostra.   
    
    
end.


   
procedure mostra.
    
    vufemi = "**". vmunicemi = "**".
    vufdes = "**". vmunicdes = "**".
    
    if mdfnfe.tabemite = "ESTAB" or 
       mdfnfe.tabemite = ""
    then do:
        find estab where estab.etbcod = mdfnfe.emite no-lock no-error.
        if avail estab 
        then do:
            find munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = estab.ufecod.
            
        end.    
    end.
    if mdfnfe.tabemite = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.emite no-lock no-error.
        if avail forne 
        then do:
            find munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = forne.ufecod.
        end. 
    end.        
 
    if mdfnfe.tabdesti = "ESTAB" or 
       mdfnfe.tabdesti = ""
    then do:
        find estab where estab.etbcod = mdfnfe.desti no-lock no-error.
        if avail estab 
        then do:
            find munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = estab.ufecod.
        end.            
    end.        
    
    if mdfnfe.tabdesti = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.desti no-lock no-error.
        if avail forne 
        then do:
            find munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = forne.ufecod.
        end.            
    end.        



    find first a01_infnfe where
        a01_infnfe.chave = mdfnfe.infnfechave
        no-lock  no-error.

    vserie  = string(mdfnfe.serie).
    vnumero = mdfnfe.numero.

    vemitpro = avail a01_infnfe.
    
    if avail a01_infnfe
    then do:
        find plani where plani.etbcod = a01_infnfe.etbcod and
                         plani.placod = a01_infnfe.placod
            no-lock no-error.
        if avail plani
        then do:
            vserie  = plani.serie.
            vnumero = plani.numero.
                    
        end.
                                             
    end.    
    
    display 
        mdfnfe.rotaseq 
        vemitpro
        mdfnfe.nfeID  
        vserie
        vnumero
        mdfnfe.tabemite 
        mdfnfe.emite   
        vufemi  
           /**
        vmunicemi
        **/
        mdfnfe.tabdesti 
        mdfnfe.desti   
        vufdes   
        /**
        vmunicdes
        **/
        mdfnfe.pesobrutokg
        mdfnfe.valornota
        with frame frame-nfe.

    down with frame frame-nfe.
    
end procedure. 
