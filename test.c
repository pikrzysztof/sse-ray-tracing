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
	sztokfisz(kule, liczba_kul, obraz, szer, wys);
	zrob_plik_ppm(obraz, szer, wys);
	zwolnij_pamiec(obraz, szer, kule);
	return EXIT_SUCCESS;
}
