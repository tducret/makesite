<!-- title: Trouvez le billet de train le moins cher grâce à ce module Python -->

Il vous arrive de rechercher des billets de train, et ne pas être capable d'ajouter tous les critères et filtres qui vous intéressent ?

**Ça m'arrive très souvent.**

Par exemple, je cherche des billets de train pour :

- Toulouse → Paris
- 2 adultes + 1 enfant avec une carte Enfant+
- 3 vélos
- pendant les vacances de la Toussaint
- le moins cher
- le plus court

Un vrai casse-tête en utilisant les sites traditionnels.

Vous ne pourrez pas obtenir l'ensemble des billets disponibles sur une période donnée par exemple. C'est dommage si vous n'avez pas de contrainte sur la date de départ...

Au mieux, vous aurez un [calendrier de prix](https://www.oui.sncf/calendar), avec le meilleur prix pour chaque jour du mois.

![Calendrier des prix Toulouse → Paris en septembre 2018 sur Oui.sncf](../images/20180905/calendrier.png)

Malheureusement, ce calendrier n'est disponible que pour les trajets les plus courants. Si vous sortez des cas prévus, gare à l'erreur :

![Message renvoyé quand on essaie d'obtenir le calendrier des prix pour Toulouse -> Cannes](../images/20180905/erreur.png)

De même, il n'est pas possible d'obtenir le calendrier des prix en prenant en compte une carte de réduction Enfant+, ou de réserver un emplacement vélo 😞

L'autre solution, c'est de :

- rechercher les billets de train à partir de la date de départ,
- de cliquer sur la recherche des trains suivants,
- de cliquer sur la recherche des trains suivants,
- de cliquer sur la recherche des trains suivants,
- ...
- jusqu'à la date de fin.

Bref, une tâche longue et pénible...

**Ce sont justement mes critères pour démarrer un nouveau projet !**

# Le choix du service

Pour obtenir les tarifs de billets de train en France, deux solutions existent : le portail officiel [Oui.sncf](https://www.oui.sncf/) (anciennement Voyage-sncf) et [Trainline](https://www.trainline.eu/) (anciennement Capitaine Train).

Au-delà du site web, chacun propose une application mobile.

**C'est de ce côté que je regarde pour créer un module Python.**

En effet, contrairement à leurs sites web, l'application mobile fait des appels "en clair" à leurs API internes. Il suffit d'utiliser l'application, et d'espionner les échanges avec leurs serveurs. J'utilise pour ce type d'analyse le logiciel [Charles](https://www.charlesproxy.com/), mais il existe également [mitmproxy](https://mitmproxy.org/).

> Vous pouvez en savoir plus en lisant l'article sur le [reverse engineering de l'application mobile ING Direct]({{ site.baseurl }}{% post_url 2018-05-24-reverse-engineering-de-l-application-mobile-ing-direct %}).

Bref, après avoir regardé les possibilités des deux applications, mon choix s'est orienté sur **Trainline**.

L'application mobile de Oui.sncf ne permet pas de réserver des billets de train avec emplacement vélo... C'est rédibitoire pour moi :)

# Un module Python

La suite du projet consiste alors à analyser les requêtes entre l'application et les serveurs de Trainline. On regarde :

- les URL (exemple : https://api.serveur.com/rechercher_trains)
- les paramètres d'entrée et leur format (exemple : {"gare_depart": "Toulouse", "gare_arrivee": "Bordeaux"})
- la logique des échanges (quelle requête est exécutée après telle autre...)
- les réponses (exemple : {["heure_depart": "8:58", "heure_arrivee": "10:57", "prix": 15.0}])

Ensuite, on développe un module Python qui va permettre d'envoyer ces requêtes à partir de fonctions.
Ce module masque complétement le contenu des requêtes et le format de l'API.

--------------

En suivant cette logique *(et après quelques heures de développement)*, **le [module trainline](https://pypi.org/project/trainline/) est né** !

Voici un exemple d'utilisation :

```python
# -*- coding: utf-8 -*-
import trainline

resultats = trainline.search(
	departure_station="Toulouse",
	arrival_station="Bordeaux",
	from_date="15/10/2018 08:00",
	to_date="15/10/2018 21:00")

print(resultats.csv())
```

On obtient alors :

```csv
departure_date;arrival_date;duration;number_of_segments;price;currency;transportation_mean;bicycle_reservation
15/10/2018 08:00;15/10/2018 10:55;02h55;1;5,0;EUR;coach;unavailable
15/10/2018 08:00;15/10/2018 10:50;02h50;1;4,99;EUR;coach;unavailable
15/10/2018 08:19;15/10/2018 10:26;02h07;1;20,5;EUR;train;10,0
15/10/2018 08:19;15/10/2018 10:26;02h07;1;65,0;EUR;train;unavailable
```

Beaucoup plus simple que de composer les requêtes HTTP à la main, non?

# Testons le module sur un exemple

Reprenons l'exemple de l'introduction :

- Toulouse → Paris
- 2 adultes + 1 enfant avec une carte Enfant+
- 3 vélos
- pendant les vacances de la Toussaint
- le moins cher
- le plus court

Le module va nous aider dans cette recherche.

> *Les vacances de la Toussaint 2018 vont du samedi 20 octobre au lundi 5 novembre.*

```python
# -*- coding: utf-8 -*-
import trainline

Papa = trainline.Passenger(birthdate="01/01/1986")
Maman = trainline.Passenger(birthdate="01/01/1987")
Enfant = trainline.Passenger(birthdate="01/01/2012",
cards=[trainline.ENFANT_PLUS])

resultats = trainline.search(
	passengers=[Papa, Maman, Enfant],
	departure_station="Toulouse",
	arrival_station="Paris",
	from_date="20/10/2018 08:00",
	to_date="15/11/2018 21:00",
	bicycle_with_or_without_reservation=True)

print(resultats.csv())
```

On obtient alors tous les trains possibles pendant cette période au format csv.

Il suffit alors de récupérer ces résultats et les ouvrir sur un tableur pour les trier, et obtenir le billet le moins cher.

> Nota : J'ai ajouté la colonne **prix_total**, correspondant au prix des billets de train + le prix de la réservation des emplacements vélos. Soit : price + bicycle_reservation

![Tri des résultats par prix total sous Excel](../images/20180905/excel.png)

**Bilan** : deux dates intéressantes, le 23 et 24 octobre, avec un prix total de 35€ pour nous 3 et nos vélos ! (le prix maximum étant de 301,50€...)

Une fois le billet repéré, rendez-vous sur [Trainline](https://www.trainline.eu/) pour le réserver.

# Une commande dans le terminal

Le module Python Trainline est pratique, mais il nécessite de développer ou d'adapter un petit programme pour chaque recherche.

Il doit y avoir plus simple...

En complément du module, j'ai donc créé l'utilitaire `trainline_cli.py`, avec une interface en ligne de commande (CLI).

Cela s'utilise donc dans le terminal, comme un `ls` ou un `grep`.

Si je recherche les billets de train de Toulouse à Bordeaux pour les 2 prochaines heures, je tape dans le terminal :

```bash
trainline_cli.py --departure="Toulouse" --arrival="Bordeaux" --next=2hours
```

Ou encore plus court (une fois que vous serez habitués) :

```bash
trainline_cli.py -d Toulouse -a Bordeaux -n 2h
```

Vous obtiendrez les résultats au format csv.

Rendez-vous sur [la page Github du projet Trainline](https://github.com/tducret/trainline-python) pour plus de détails sur le module Python et l'outil (installation, exemples d'utilisation).