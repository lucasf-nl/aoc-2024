IDENTIFICATION DIVISION.
PROGRAM-ID. Day1Part2.

COPY 'input_file.cpy'.

WORKING-STORAGE SECTION.
COPY 'input_working_storage.cpy'.
77 SIMSCORE_RIGHT_COUNT BINARY-LONG.
77 SIMSCORE_RIGHT_ROW BINARY-LONG.
77 SIMSCORE_LEFT_NUM BINARY-LONG.
77 SIMSCORE_RIGHT_NUM BINARY-LONG.
77 SIMSCORE BINARY-LONG.

PROCEDURE DIVISION.
    MAIN-PROGRAM.
        PERFORM INITIALIZE-GRID.
        PERFORM CALCULATE-SIMILARITY-SCORE.

        STOP RUN.

    COPY 'input_initialize.cpy'.

    CALCULATE-SIMILARITY-SCORE.
        PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > 1000
            MOVE 0 TO SIMSCORE_RIGHT_COUNT
            MOVE COL-1(WS-ROW) TO SIMSCORE_LEFT_NUM

            PERFORM VARYING SIMSCORE_RIGHT_ROW FROM 1 BY 1 UNTIL SIMSCORE_RIGHT_ROW > 1000
                MOVE COL-2(SIMSCORE_RIGHT_ROW) TO SIMSCORE_RIGHT_NUM;

                IF SIMSCORE_RIGHT_NUM = SIMSCORE_LEFT_NUM
                    DISPLAY COL-2(SIMSCORE_RIGHT_ROW) " matches " SIMSCORE_LEFT_NUM " so I'm adding it to the simscore of " SIMSCORE
                    ADD 1 TO SIMSCORE_RIGHT_COUNT
                END-IF
            END-PERFORM

            *> because cobol is cobol the new value is actually stored in SIMSCORE_RIGHT_COUNT
            MULTIPLY SIMSCORE_LEFT_NUM BY SIMSCORE_RIGHT_COUNT
            ADD SIMSCORE_RIGHT_COUNT TO SIMSCORE
        END-PERFORM
        DISPLAY "Simscore " SIMSCORE.