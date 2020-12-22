;; this is beginning to take form!
; comments are working and db works as well

	bra snd_init
	bra snd_exit
	bra snd_vblank

.db $53, $4e, $44, $48      ; SNDH
.db $54, $43, $34, $39, $00 ; TC49
.db $48, $44, $4e, $53, $00 ; HDNS

snd_init:

	; select register 7 (enable and disable channels)
	ld0 #$07
	st0 $ff8800

	; tone channels enabled, noise disabled
	ld0 #$38 ; binary 0011 1000
	st0 $ff8802
	
	; select register 8 (ch1 volume control)
	ld0 #$08
	st0 $ff8800
	
	; highest
	ld0 #$0f
	st0 $ff8802
	
	; select register 0 (ch1 freq)
	ld0 #$00
	st0 $ff8800
	
	ld0 #$c0
	st0 $ff8802
	
	rts
	
snd_exit:

	rts
	
snd_vblank:
	
	rts