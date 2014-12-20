#include <inttypes.h>

#ifndef SZTOKFISZLIB_H
#define SZTOKFISZLIB_H

typedef float pixel;

typedef struct {
	float *x;
	float *y;
	float *z;
	float *r;		/* promien */
	pixel *kol;
} kula_t;

/* Gdy wejscie jest niepoprawne zachowanie funkcji nie jest okreslone. */
/* Wczytuje z stdin liczbe kul, rozmiar obrazka. */
/* alokuje miejsce i wczytuje kule do tablicy. */
/* Po tym mozna od razu robic sztokfisz. */
/* Format wejscia: szer, wys, liczba_kul\n, potem x, y, z, r, R, G, B kul \n */
extern void przygotuj_z_stdin(kula_t **kule, int *liczba_kul,
			      pixel ***obraz, int *szer, int *wys);

extern void zrob_plik_ppm(pixel **obraz, int szer, int wys);

extern void zwolnij_pamiec(pixel **obraz, const int szer, kula_t *const kule);

#endif
