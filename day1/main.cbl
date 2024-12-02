IDENTIFICATION DIVISION.
PROGRAM-ID. Day1.

ENVIRONMENT DIVISION.
    INPUT-OUTPUT SECTION.
    FILE-CONTROL.
        SELECT inputFile ASSIGN TO 'input.txt'
            ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD  inputFile.
01  inputFileRecord PIC X(100).

WORKING-STORAGE SECTION.
01 indexCounter PIC 9(4) VALUE 0.
01 COL-1 OCCURS 1000 TIMES PIC X(5).
01 COL-2 OCCURS 1000 TIMES PIC X(5).
01 EOF PIC X VALUE 'N'.
77 WS-ROW PIC 9(5) VALUE 0.
77 WS-COLUMN PIC 9(5) VALUE 0.
77 CALCTMP BINARY-LONG.
77 CALCTMP2 BINARY-LONG.
77 TOTAL BINARY-LONG VALUE 0.
01 trash PIC X(10).
01 splitArray PIC X(100) OCCURS 10 TIMES INDEXED BY idx.

PROCEDURE DIVISION.
    MAIN-PROGRAM.
        DISPLAY "Hello World!".

        PERFORM INITIALIZE-GRID.
        PERFORM DISPLAY-GRID.

        SORT COL-1 ON ASCENDING KEY COL-1
        SORT COL-2 ON ASCENDING KEY COL-2

        PERFORM DISPLAY-GRID.

        PERFORM CALCULATE_DISTANCES.

        STOP RUN.

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

    CALCULATE_DISTANCES.
        PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 1000
            MOVE COL-1(WS-ROW) TO CALCTMP
            MOVE COL-2(WS-ROW) TO CALCTMP2
            DISPLAY "Subtracting " CALCTMP2 " from " CALCTMP
            SUBTRACT CALCTMP2 FROM CALCTMP
            MOVE FUNCTION ABS(CALCTMP) TO CALCTMP
            DISPLAY "Adding " CALCTMP " to " TOTAL
            ADD CALCTMP TO TOTAL
        END-PERFORM
        DISPLAY "Total " TOTAL.

    DISPLAY-GRID.
        PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 1000
            DISPLAY "Row " WS-ROW ": " COL-1(WS-ROW) ", " COL-2(WS-ROW)
        END-PERFORM.
