    def shared var vclicod like gerloja.clien.clicod.   
    def shared var vqtd as int.
    find gerloja.clien where gerloja.clien.clicod = vclicod no-error.
    
    if avail gerloja.clien
    then do transaction:
        delete gerloja.clien.
        vqtd = vqtd + 1.
    end.
        
