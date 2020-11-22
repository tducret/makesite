<!-- title: Un robot d'achat et de vente de Bitcoins développé en Python -->

Qu'il s'agisse d'adolescents qui ont fait fortune ou de personnes qui achètent de la drogue sur le *"dark web"*, les cryptomonnaies font parler d'elles en ce moment.
Dans cet article, je vous présente mon **robot de trading en Python**. Il achètera à votre place des cryptomonnaies quand elles baissent, et les revendra quand elles remontent. Basique !

# L'origine du projet

En fait, ce projet est un effet collatéral d'un projet de récupération du solde de mes différents comptes bancaires. L'idée est de créer une alternative open source à [Linxo](https://www.linxo.com/), que l'on peut héberger chez soi.

Vous pouvez en savoir plus en lisant l'article sur le [reverse engineering de l'application mobile ING Direct]({{ site.baseurl }}{% post_url 2018-05-24-reverse-engineering-de-l-application-mobile-ing-direct %}).

## Revolut

L'idée initiale était donc de créer une bibliothèque Python pour interroger mes comptes bancaires [Revolut](https://www.revolut.com/).
Comme pour *ING Direct*, j'ai décidé d'analyser les échanges entre l'application mobile de la banque et leurs serveurs.

Cela m'a permis de créer [le package Python **revolut**](https://pypi.org/project/revolut). 

Après installation, un appel à la commande `revolut_cli.py` vous permettra de récupérer le solde de vos comptes Revolut dans le terminal.

Cela ressemblera à ça :

```csv
Nom du compte;Solde;Devise
EUR CURRENT;100,50;EUR
GBP CURRENT;20,00;GBP
USD CURRENT;0,00;USD
AUD CURRENT;0,00;AUD
BTC CURRENT;0,00123456;BTC
EUR SAVINGS (Mon coffre);10,30;EUR
```
Le code source et tous les détails du projet sont sur [le projet Github revolut-python](https://github.com/tducret/revolut-python).

# Et ensuite...

L'histoire pourrait s'arrêter là, mais en décembre 2017, Revolut a annoncé [le lancement du moyen le plus simple et le plus rapide d'acheter des cryptomonnaies](https://blog.revolut.com/revolut-launches-easiest-fastest-way-to-buy-cryptocurrencies/).

Et effectivement, c'est très simple !

Sur l'application mobile, on peut créer un porte-monnaie virtuel pour chaque devise : euros, dollars, livres sterling... et désormais bitcoins, ethereum, litecoin et j'en passe.

![Echange de livres sterling en bitcoins sur l'application Revolut](../images/20180817/revolut.png)

Il suffit alors d'alimenter un des porte-monnaie (par exemple en le rechargeant par carte bancaire en euros), et l'on peut faire des échanges vers le porte-monnaie de son choix.

**24h/24, 7j/7, avec le cours du moment.**

Il est facile de faire ces conversions à la main avec l'application, mais si vous souhaitez acheter ou revendre au meilleur prix, il faut :

1. suivre le cours des devises (très) régulièrement
2. détecter le bon moment pour acheter
3. sortir son smartphone
4. lancer l'application Revolut
5. taper son mot de passe
6. convertir le montant souhaité dans l'autre devise

Bon, j'exagère un peu 🤥, mais il est clair que l'on préfère profiter de la plage que de suivre le cours €/Bitcoins.

**Si seulement on pouvait automatiser cette tâche fastidieuse...**

L'idée du robot était née.

# Principes du robot

N'ayant pas de formation dans la finance, mon robot est très simple.

- Point de départ (la référence) : j'échange 100€ en bitcoins.
- Désormais, le robot va vérifier régulièrement si la revente de ces 0.0176 bitcoins rapporte au moins 1% d'intérêts par rapport à la référence (donc 101€ dans notre cas). Quand cela se produit, le robot fait la conversion des bitcoins en euros automatiquement.
- À partir de là, le robot va vérifier si la revente de ces 101€ rapporte plus que 0.01777 bitcoins (0.0176 +1% de marge), et fera la conversion des euros en bitcoins si cela se produit.

Et ainsi de suite...

![Principe de fonctionnement du robot revolutbot](../images/20180817/bot.png)

# Implémentation

Pour implémenter ce robot, j'ai complété le package Python **revolut** avec **les fonctions de conversion et d'échange de devises**. Il a fallu faire ces manipulations sur l'application mobile, et analyser de nouveau les échanges avec les serveurs de Revolut pour comprendre leur API.

Une fois ces fonctions en place, j'ai développé le robot `revolutbot.py`, qui respecte les principes présentés plus haut. Il écrit par ailleurs dans un fichier csv l'ensemble des transactions effectuées.

Ce robot est activable par ligne de commande. On peut donc l'ajouter dans une [table cron](https://fr.wikipedia.org/wiki/Cron#crontab) pour qu'il scrute régulièrement le cours euros/bitcoins sans que vous n'ayez à y penser.

Chez moi, le robot se lance toutes les minutes sur un Raspberry Pi.

**Nota :** *l'exemple illustré ici parle de conversion d'euros en bitcoins, mais le robot fonctionne avec tout type de conversion reconnu sur Revolut : euros/dollars, bitcoins/ethereum, livres sterling/zloty polonais, etc.*

Les détails techniques d'installation et de configuration se trouvent sur [la page du projet revolut-python](https://github.com/tducret/revolut-python).