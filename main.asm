;; this is beginning to take form!
; comments are working and db works as well

	bra snd_init
	bra snd_exit
	bra snd_vblank

.db $53, $4e, $44, $48 ; SNDH

snd_init:

	ld0 #$ff ; hello
	rts
	
snd_exit:

	rts
	
snd_vblank

	rts