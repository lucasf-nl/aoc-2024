    INITIALIZE-GRID.
        OPEN INPUT inputFile

        PERFORM UNTIL EOF = "Y"
            READ inputFile INTO inputFileRecord
                AT END
                    SET EOF TO "Y"
                NOT AT END
                    ADD 1 TO indexCounter
                    DISPLAY "Processing Line " indexCounter ": " inputFileRecord

                    UNSTRING inputFileRecord DELIMITED BY SPACE
                        INTO COL-1(indexCounter),
                             trash,
                             trash,
                             COL-2(indexCounter)
                    END-UNSTRING

            END-READ
        END-PERFORM

        CLOSE inputFile.

    DISPLAY-GRID.
        PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 1000
            DISPLAY "Row " WS-ROW ": " COL-1(WS-ROW) ", " COL-2(WS-ROW)
        END-PERFORM.