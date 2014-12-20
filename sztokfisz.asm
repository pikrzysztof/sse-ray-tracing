; 64-bit intel

; Drugie zadanie zaliczeniowe z programowania w asemblerze.
; Napisane przez Krzysztofa Piecucha, nr albumu 332534.

global sztokfisz

section .data
	align 16
	CZTERY_MINUS_JEDYNKI_FLOAT DD 0xBF800000, 0xBF800000, 0xBF800000,      \
	                              0xBF800000
	CZTERY_JEDYNKI_FLOAT DD 0x3f800000, 0x3f800000, 0x3f800000, 0x3f800000
	CZTERY_DWOJKI_FLOAT DD 0x40000000, 0x40000000, 0x40000000, 0x40000000
	CZTERY_MINUS_DWOJKI_FLOAT DD 0xC0000000, 0xC0000000, 0xC0000000,       \
	                             0xC0000000
	CZTERY_MINUS_CZWORKI_FLOAT DD 0xC0800000, 0xC0800000, 0xC0800000,      \
	                              0xC0800000
	CZTERY_MINUS_ZERA_FLOAT DD 0x800000, 0x800000, 0x800000, 0x800000
	CZTERY_PLUS_NIESKONCZONOSCI DD 0x7F800000, 0x7F800000, 0x7F800000,     \
	                               0x7F800000
section .bss
	align 16
	x resd 1 		;do iteracji po planszy, szerokosc tablicy
	y resd 1		;do iteracji po planszy, wysokosc tablicy
	n resd 1		;do iteracji po kulach, dlugosc tablicy
	max resd 1
	wspolrzedne resd 4 	;do wczytywania, wrzucania z sse
	kolory resd 4
	kolor resd 1

section .text

; w xmm0 jest x, ktory teraz obrabiamy
; w xmm1 jest x_0 - srodek kuli
; w xmm2 jest y, ktory teraz obrabiamy
; w xmm3 y_0
; w xmm4 z_0
; w xmm5 - r
; w xmm6 sa kolory
; w xmm7 jest -1f, przydaje sie.
; w xmm8 potem bedziemy trzymac z_0, rejestr roboczy
; w xmm9 jest -4f
sztokfisz_wlasciwy: ;; po skoku tutaj xmm0 ma zmieniona wartosc na chyba -2f, -2f, -3f, -4f
; najpierw liczymy delte i -b do wyliczenia pierwiastka rownania kwadratowego
	subps xmm0, xmm1
	subps xmm2, xmm3
	mulps xmm2, xmm2	;w xmm2 mamy (y - y_0)^2
	mulps xmm0, xmm0	;w xmm0 mamy (x - x_0)^2
	mulps xmm5, xmm5
	mulps xmm5, xmm7	;w xmm5 jest (-1) * r^2
	movaps xmm8, xmm4
	mulps xmm8, xmm4	;w xmm8 jest teraz z_0^2
	addps xmm0, xmm2	;liczymy wyraz wolny, najpierw polsumy
	addps xmm5, xmm8
	addps xmm0, xmm5      ;ostatecznie wyraz wolny jest w xmm0 ("deltowe c")
	addps xmm4, xmm4	;wyraz przy -z jest w xmm4 ("deltowe -b")
	mulps xmm0, xmm9	;w xmm0 jest deltowe -4c (bo a == 1 zawsze)
	movaps xmm1, xmm4
	mulps xmm1, xmm1	;w xmm1 teraz jest b^2
	addps xmm0, xmm1	;w xmm0 jest teraz delta
;W tym miejscu stan jest nastepujacy:
; w xmm0 jest delta
; w xmm4 jest "-b"
; w xmm7 jest -1f
; w xmm9 jest -4f
; w xmm6 sa kolory (nieszczegolnie to sa jakies fajne liczby, ale SA TO LICZBY!)
; wolne, robocze rejestry:
; xmm1, xmm2, xmm3, xmm5, xmm8, xmm10-15

; Teraz plan jest taki:
; 1) wyznaczyc miejsca, gdzie jest ujemna delta
; 2) tam, gdzie ujemna delta ustawic -b (czyli xmm4) na +nieskonczonosc
; oraz kolor kuli, ktora jest zwiazana z tym rejestrem na same zera (kolor tla)
; Dzieki temu jak policzymy sobie gdzie sie przecina, to wyjda jakies sensowne
; wyniki, funkcja min bedzie mozna wyciagnac najblizsza kule i jej kolor.
	movaps xmm8, [CZTERY_PLUS_NIESKONCZONOSCI] ;przyda sie potem
	pxor xmm1, xmm1		;teraz chcemy wyznaczyc gdzie delta jest >= 0
	cmpleps xmm1, xmm0	;tam gdzie delta bedzie nieujemna w xmm1 sa 1.
; teraz nalezy wykorzystac zawartosc xmm1, zeby ustawic b = nieskonczonosc
; tam gdzie nie ma pierwiastka
	pand xmm0, xmm1		;wywalamy ujemne delty, zostawiamy zera
	sqrtps xmm0, xmm0	;pierwiastek z delty
	mulps xmm0, xmm7	;xmm0 ma -pierwiastek z delty,czyli prawie wynik
	pand xmm0, xmm1
; w tym miejscu mamy w xmm0 juz -pierwiastek z delty, trzeba tylko poustawiac
; xmm4 (-b) tak jak opisane wczesniej i dalej realizowac plan
; USTAWIANIE xmm4 tak jak opisane:
; xmm4 zandowac z xmm1, zeby zostaly tylko te wartosciowe wyniki
; ustawic kolory tam gdzie ujemna delta (kolor & xmm1)
; zanegowac xmm1
; zandowac xmm1 z wektorem z samymi +niesk
; zorowac te +niesk z xmm4
	pand xmm4, xmm1		;w xmm4 zostaja tylko -b od nieujemnych delt
	pand xmm6, xmm1
; do tego momentu powinno juz przyjsc xmm8 z pamieci
	pand xmm4, xmm1	        ;zostawiamy tylko b tam, gdzie delta nieujemna
	cmpeqps xmm2, xmm2	;ustawianie samych jedynek w do negacji xmm1
	pxor xmm1, xmm2
	; do tego momentu powinno juz przyjsc xmm8 z pamieci
	pand xmm8, xmm1		;w xmm8 zostaja +niesk tylko tam gdzie maja byc
; wrzucone do xmm4
	por xmm4, xmm8
	addps xmm0, xmm4	;rozwiazanie rownania kwadratowego w xmm0
	movaps xmm2, xmm0	;zachowamy sobie na potem rozwiazania
; W tym miejscu stan jest nastepujacy:
; w xmm0 jest rozwiazanie rownania kwadratowego
; w xmm6 sa kolory
; w xmm7 jest -1f
; w xmm9 jest -4f
; plan na teraz: wyciagnac minimum z rownania kwadratowego, rozciagnac to na
; caly wektor. potem porownac wyniki rown kwadr z minimum i tej maski uzyc do
; wyciagniecia koloru - wziac maksimum z kolorow zandowanych z ta maska
; kolory sa dodatnie!
	movhlps xmm1, xmm0
	minps xmm0, xmm1	;w xmm0 sa minima, trzeba jeszcze z nich dwoch
	shufps xmm1, xmm0, 0x55 ;drugi od lewej element na pierwsze od lewe
	minps xmm0, xmm1	     ;teraz w xmm0 na pierwszym miejscu od lewej
; mamy minimum. Teraz trzeba to skopiowac wszedzie
	shufps xmm0, xmm0, 0x00	;xmm0 jest caly wypelniony najmniejszym wynikiem
	cmpeqps xmm0, xmm2	;w xmm2 sa pierwotne wyniki
	pand xmm2, xmm0		;w xmm2 tylko min i same zera
	pand xmm6, xmm0		;w xmm6 zostaja tylko zera i jedyny,wlasciwy kolor
; w xmm6 mamy tylko kolor, ktory powinien przetrwac.
; w xmm2 jest tylko jeden dobry wynik
; teraz lokalizujemy ta jedyna niezerowa pare liczb
	movaps [wspolrzedne], xmm2
	movaps [kolory], xmm6
	mov rax, [wspolrzedne]
	mov r9, [kolory]
	cmp eax, 0
	jne .znaleziony
	shr rax, 32
	shr r9, 32
	cmp eax, 0
	jne .znaleziony
	mov rax, [wspolrzedne + 8]
	mov r9, [kolory + 8]
	cmp eax, 0
	jne .znaleziony
	shr r9, 32
	shr rax, 32
	cmp eax, 0
	je petla.po_wlasciwym_sztokfiszu
.znaleziony:
	cmp [max], eax
	jl .lepszy
	jmp petla.po_wlasciwym_sztokfiszu
.lepszy:
	mov [kolor], r9d
	cmp eax, 0x7F800000
	jne .jest_nienieskonczonosc
	mov eax, 0xFFFFFFFFFFFFFFFF
.jest_nienieskonczonosc:
	mov [max], eax
	jmp petla.po_wlasciwym_sztokfiszu


; Procedura sztokfisz, rozpis argumentow:
; rdi - wskaznik na zbior kul
; esi - liczba kul (dlugosc tablicy)
; rdx - pixel **obraz
; ecx - int szer (obrazu)
; r8d  - int wys (obrazu)
petla:
.po_iksach:
	cmp ecx, [x]		;w ecx iterujemy po x
	je .koniec_po_iksach
	mov r10, rdx		;r10 wskazuje na miejsce, gdzie bedziemy wkladac
	mov r10, [r10]
	add rdx, 8		;rdx juz wskazuje na kolejna kolumne
	mov r8d, 0		;w r8d jest iteracja po y
	pxor xmm2, xmm2
.po_igrekach:
	cmp r8d, [y]
	je .koniec_po_igrekach
	mov [kolor], dword 0
	mov [max], dword 0
; przygotowujemy sledzenie promieni z tego miejsca
	mov r11, [rdi]	       ;iksy kul
	mov r12, [rdi + 8]     ;igreki kul
	mov r13, [rdi + 16]    ;zety kul
	mov r14, [rdi + 24]    ;r kul
	mov r15, [rdi + 32]    ;kolory kul
	mov esi, [n]
.po_kulach:
	cmp esi, 0
	je .koniec_po_kulach
	add esi, -4
; przygotuj jedno wywolanie wlasciwego sztokfisza
	pxor xmm0, xmm0
	cvtsi2ss xmm0, ecx
	shufps xmm0, xmm0, 0x0000
	movaps xmm1, [r11]
	cvtsi2ss xmm2, r8d
	shufps xmm2, xmm2, 0x0000
	movaps xmm3, [r12]
	movaps xmm4, [r13]
	movaps xmm5, [r14]
	movaps xmm6, [r15]
	jmp sztokfisz_wlasciwy
.po_wlasciwym_sztokfiszu:
	add r11, 4 * 4		;przesuwamy wskaznik o 4 floaty przodu
	add r12, 4 * 4
	add r13, 4 * 4
	add r14, 4 * 4
	add r15, 4 * 4
	jmp .po_kulach
.koniec_po_kulach:
	mov r9d, [kolor]
	mov [r10], r9d
	add r10, 4		;nastepna komorka!
	add r8d, 1
	jmp .po_igrekach
.koniec_po_igrekach:
	add ecx, 1
	jmp .po_iksach
.koniec_po_iksach:
	jmp sztokfisz.koniec_z_popem

sztokfisz:
	cmp rdx, 0
	je .koniec
	cmp ecx, 0
	jle .koniec
	cmp rdi, 0
	je .koniec
	cmp esi, 0
	jle .koniec
	cmp r8, 0
	jle .koniec
	mov [y], r8d
	mov [x], ecx
	mov ecx, 0
	mov [n], esi		;liczba kul jest zawsze wielokrotnoscia 4.
	push r9			;w obliczu gigantycznej funkcji mozna sobie
	push r10		;pozwolic na push wszystkiego
	push r11
	push r12
	push r13
	push r14
	push r15
	movaps xmm7, [CZTERY_MINUS_JEDYNKI_FLOAT]
	movaps xmm9, [CZTERY_MINUS_CZWORKI_FLOAT]
	movaps xmm10, [CZTERY_JEDYNKI_FLOAT]
	jmp petla

.koniec:
	ret

.koniec_z_popem:
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	pop r9
	ret

; *EOF*