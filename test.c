#include <stdio.h>
#include <stdlib.h>
#include "sztokfiszlib.h"

extern void sztokfisz(kula_t *kule, int liczba_kul,
		      pixel **obraz, int szer, int wys);

int main()
{
	kula_t *kule;
	int liczba_kul, szer, wys;
	pixel **obraz;
	przygotuj_z_stdin(&kule, &liczba_kul, &obraz, &szer, &wys);
	fprintf(stderr, "kule: %p\n\tkule.x: %p, kule.y: %p, kule.z: %p, kule.r: %p"
		"\n", (void *) kule, (void *) kule->x, (void *) kule->y,
		(void *) kule->z, (void *) kule->r);
	fprintf(stderr, "obraz: %p\n\t", (void *) obraz);
	for (int i = 0; i < szer; ++i) {
		fprintf(stderr, "obraz[%i]: %p, ", i, (void *) obraz[i]);
	}
	fprintf(stderr, "\n");
	sztokfisz(kule, liczba_kul, obraz, szer, wys);
	zrob_plik_ppm(obraz, szer, wys);
	zwolnij_pamiec(obraz, szer, kule);
	return EXIT_SUCCESS;
}
