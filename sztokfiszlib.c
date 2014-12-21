#define _POSIX_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <inttypes.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include "sztokfiszlib.h"
#include <unistd.h>

void przygotuj_z_stdin(kula_t **kule, int *liczba_kul,
		       pixel ***obraz, int *szer, int *wys)
{
	scanf("%i %i %i\n", szer, wys, liczba_kul);
	*obraz = malloc(sizeof(pixel*) * *szer);
	int wlasciwa_liczba_kul = *liczba_kul;
	uint8_t kolor[sizeof(pixel)];
	while (*liczba_kul % 4 != 0)
		(*liczba_kul)++;
	for (int i = 0; i < *szer; ++i) {
		(*obraz)[i] = malloc(sizeof(pixel) * *wys);
	}
	kolor[0] = 0x00;
	(*kule) = malloc(sizeof(kula_t));
	(**kule).x = malloc(sizeof(float) * *liczba_kul);
	(**kule).y = malloc(sizeof(float) * *liczba_kul);
	(**kule).z = malloc(sizeof(float) * *liczba_kul);
	(**kule).r = malloc(sizeof(float) * *liczba_kul);
	(**kule).kol = malloc(sizeof(float) * *liczba_kul);
	for (int i = 0; i < wlasciwa_liczba_kul; ++i) {
		scanf("%f %f %f %f %"SCNu8" %"SCNu8" %"SCNu8"\n",
		      (**kule).x + i, (**kule).y + i,
		      (**kule).z + i, (**kule).r + i,
		      kolor + 1, kolor + 2, kolor + 3);
		memcpy((**kule).kol + i, kolor, sizeof(pixel));
	}
	for (int i = wlasciwa_liczba_kul; i < *liczba_kul; ++i) {
		*((**kule).x + i) = 0x7F800000; /* + nieskonczonosc */
		*((**kule).y + i) = 0x7F800000; /* + nieskonczonosc */
		*((**kule).z + i) = 0x7F800000; /* + nieskonczonosc */
		*((**kule).r + i) = 0.0;
	}

	for (int i = 0; i < *szer; ++i) {
		for (int j = 0; j < *wys; ++j) {
			(*obraz)[i][j] = 0x005588AA;
		}
	}
}

void zrob_plik_ppm(pixel **obraz, int szer, int wys)
{
	int wynik;
	size_t rozmiar = sizeof(pixel);
	unsigned char do_wypisania_koloru[rozmiar];
	/* magic PPM number */
	FILE* strumien = fopen("a.ppm", "w");
	if (strumien == NULL)
		goto fail;
	fprintf(strumien, "P3\n%i %i\n%i\n", szer, wys, 255);
	fprintf(strumien,"# Plik z wynikiem sledzenia promieni\n");
	for (int y = 0; y < wys; ++y) {
		for (int x = 0; x < szer; ++x) {
			memcpy(do_wypisania_koloru, obraz[x] + y, sizeof(pixel));
			for (size_t i = 1; i < rozmiar; ++i) {
				fprintf(strumien, "%"SCNu8" ",
					do_wypisania_koloru[i]);
			}
		}
		fprintf(strumien, "\n");
	}
	fflush(strumien);
	wynik = fclose(strumien);
	if (wynik != 0)
		goto fail;
	return;
 fail:
	fprintf(stderr, "Nie udalo sie zapisac wyniku. Kod bledu %i.\n", wynik);
	fprintf(stderr, "Opis bledu to %s.\n", strerror(wynik));
	exit(wynik);
}

void zwolnij_pamiec(pixel **obraz, const int szer, kula_t *const kule)
{
	for (int i = 0; i < szer; ++i) {
		free(obraz[i]);
	}
	free(obraz);
	free(kule->x);
	free(kule->y);
	free(kule->z);
	free(kule->r);
	free(kule->kol);
	free(kule);
}
