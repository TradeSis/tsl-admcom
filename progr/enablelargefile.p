output to /admcom/logs/enablelargefile.logs.

for each _Database-Feature
   where _database-feature._DBFeature-ID = 5:
        disp 
            _DBFeature-ID format ">9" label "ID"
            _DBFeature_Name format "x(20)" label "NAME"
            _DBFeature_Active format "9" label "ACTIVE"
            _DBFeature_Enabled format "9" label "ENABLED"
       with frame ft down. 
 output close.
