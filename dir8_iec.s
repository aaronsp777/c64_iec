// Shows the directory on device 8

* = $C000

.label OPEN_CHANNEL = $F0
.label REOPEN_CHANNEL = $60
.label CLOSE_CHANNEL = $E0

.label DISK = 8
    // open _,8,0,"$"
    lda #DISK
    jsr LISTEN
    lda #OPEN_CHANNEL + 0
    jsr SECOND
    lda STATUS
    bpl open1
    lda #5  // device not present
    jmp ERROR

open1:
    lda #'$'
    jsr CIOUT
    bcs open_fail
    jsr UNLSN
    // open done
    lda #DISK
    jsr TALK
    lda #REOPEN_CHANNEL + 0
    jsr TALKSA

    jsr ACPTR  // ignore start address lo
    lda STATUS
    lsr
    lsr
    beq open2
    lda #4  // file not found
    jmp ERROR

 open2:   
    jsr ACPTR  // ignore start address hi

nextline:
    lda STATUS
    lsr
    lsr
    bcs end
    // Skip next address
    jsr ACPTR; jsr ACPTR

    lda STATUS
    lsr
    lsr
    bcs end

    // Read line number
    jsr ACPTR
    bcs end
    tax
    jsr ACPTR
    tay
    jsr printdec


nextbyte:
    lda STATUS
    lsr
    lsr
    bcs end

    jsr ACPTR
    bcs end

    beq nextline
    jsr CHROUT
    jmp nextbyte

end:
    jsr UNTLK 
    lda #DISK
    jsr LISTEN
    lda #CLOSE_CHANNEL + 0
    jsr SECOND
    jsr UNLSN
    lda #3
    jsr ERROR
    rts


open_fail:
    // TODO - fixme - .A contains error
    rts

printdec:
    // print decimal in x<, y>
    // TODO
    lda #13
    jsr CHROUT
    lda #'0'
    jsr CHROUT
    lda #' '
    jsr CHROUT
    rts

ERROR:
    ora #'0'
    jsr CHROUT
    rts

.label STATUS = $90
// .label ERROR = $F715
.label SECOND = $FF93
.label TALKSA = $FF96
.label ACPTR = $FFA5
.label CIOUT = $FFA8
.label UNLSN = $FFAE
.label LISTEN = $FFB1
.label TALK = $FFB4
.label UNTLK = $FFBA
.label CHROUT = $FFD2
