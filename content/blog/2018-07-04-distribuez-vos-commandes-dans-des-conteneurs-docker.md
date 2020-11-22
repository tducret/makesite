<!-- title: Distribuez vos commandes dans des conteneurs Docker -->

Vous avez déjà voulu **partager un de vos programmes** ?

Pas facile de le faire fonctionner sur différents systèmes d'exploitation. Pas évident de connaitre toutes les choses à installer avant pour pouvoir s'en servir.

Dans cet article, je vais vous expliquer comment convertir une commande en un conteneur Docker.

**Fini l'aléatoire**, le conteneur s'exécutera de la même manière à chaque fois, et s'installera sur n'importe quel ordinateur en une ligne de commande.

# Docker?

> « Docker est un outil qui peut empaqueter une application et ses dépendances dans un conteneur isolé, qui pourra être exécuté sur n'importe quel serveur ». Ceci permet d'étendre la flexibilité et la portabilité d’exécution d'une application, que ce soit sur la machine locale, un cloud privé ou public, une machine nue, etc. [(source Wikipedia)](https://fr.wikipedia.org/wiki/Docker_%28logiciel%29)

Si vous voulez en savoir plus, je vous invite à lire l'article [Docker pour les nuls](https://www.cachem.fr/docker-revolution-conteneur/).

# Création du Dockerfile

Pour créer une image Docker (le modèle de vos conteneurs), on écrit un fichier **Dockerfile**. On prend une image de base comme point de départ (par exemple un OS Ubuntu), et l'on décrit les étapes à dérouler pour installer votre commande.

Dans cet article, nous allons créer l'image Docker d'une commande Python 3.

On va donc rechercher une image de départ qui contient Python 3 sur [le store Docker](https://store.docker.com) (le catalogue des images Docker).

Un clic sur **View Available Tags** nous permet de voir les versions disponibles. Pour cet exemple, on choisit l'image `python:3`

Ainsi, le Dockerfile commencera par la ligne d'import suivante :

```dockerfile
FROM python:3
```

À partir de là, il faut imaginer que l'on se trouve sur un serveur vierge et que l'on souhaite installer la commande souhaitée.

Ici, la commande utilisée pour cet article est installable via `pip`. On va donc indiquer la commande `pip install -U amazonscraper` dans le Dockerfile, en la précédant du mot-clé `RUN`, qui correspond aux commandes à exécuter lors de la construction de l'image Docker. 

```dockerfile
FROM python:3

RUN pip install -U amazonscraper
```

Vous pouvez bien-sûr ajouter d'autres commandes et fichiers si votre installation le nécessite.

> Vous trouverez plus de détails dans [la documentation officielle du Dockerfile](https://docs.docker.com/engine/reference/builder/).

Ce Dockerfile pourrait être suffisant pour construire l'image. Néanmoins, il peut être intéressant de définir le script exécuté par défaut lors du lancement du conteneur. Cela réduit la longueur de la commande de lancement du conteneur. Ici, on souhaite utiliser la commande `amazon2csv.py` par défaut. On la rajoute donc dans le Dockerfile, précédée du mot-clé `ENTRYPOINT`.

```dockerfile
FROM python:3

RUN pip install -U amazonscraper

ENTRYPOINT [ "amazon2csv.py" ]
```

**Simple, non?**

## Construction de l'image

Pour construire l'image Docker, il faut tout d'abord démarrer un terminal et se placer à l'endroit où se trouve le Dockerfile. On va alors lancer la commande suivante :

```bash
docker build -t amazon2csv .
```

où *amazon2csv* est le nom de l'image que je souhaite créer.

![La construction de l'image s'est bien déroulée](../images/20180704/build.png)

# Test de lancement d'un conteneur

Pour vérifier le fonctionnement du conteneur, on lance dans le terminal la commande suivante :

```bash
docker run -it --rm amazon2csv --help
```

On obtient bien l'aide de la commande amazon2csv.py.

On peut également utiliser la commande pour faire une recherche sur Amazon des 10 premiers livres liés au développement Python (plus d'infos sur [la page du projet amazon-scraper-python](https://github.com/tducret/amazon-scraper-python/))

```bash
docker run -it --rm amazon2csv --keywords="Python programming" --maxproductnb=10
```

![Recherche de "Python programming" sur Amazon](../images/20180704/amazon2csv.png)

**Ça fonctionne !**

## Faciliter l'utilisation grâce à un alias

Pour ne pas avoir à taper systématiquement la commande de lancement du conteneur, on peut créer un **alias**. Pour cela, on ajoute dans son fichier `~/.bashrc` ou `~/.bash_profile` la ligne :

```bash
alias amazon2csv="docker run -it --rm amazon2csv"
```

Quittez le terminal, et relancez-le (pour charger ce nouvel alias). Vous pouvez désormais démarrer un conteneur en tapant uniquement *amazon2csv*.

![Lancement du conteneur avec l'alias](../images/20180704/alias.png)

## Une autre option

Si vous souhaitez partager votre commande avec d'autres personnes, ou l'utiliser sur d'autres ordinateurs, vous pouvez publier votre image sur le [Docker Hub](https://hub.docker.com/). 

> Pour en savoir plus, vous pouvez lire la partie *Publier des images sur Docker Hub* de l'article [Utilisation de Docker Hub](https://lucasvidelaine.wordpress.com/2018/01/29/utilisation-de-dockerhub/).

Une fois sur le hub, la récupération de votre image est alors très facile. Par notre exemple :

```bash
docker pull thibdct/amazon2csv
```

Il faut également savoir que si l'on demande l'exécution d'un conteneur dont l'image n'a pas été téléchargée (avec `docker run -it --rm amazon2csv --help` par exemple), docker va la télécharger sur le hub directement... pratique! Le `docker pull` est donc facultatif.

Je vous vois venir :

> "OK OK, mais c'était quand même pratique l'alias."

## Mieux que l'alias !

Je vous propose à la place un script qui :

- s'installe en une ligne de commande
- s'appelle très facilement,
- peut mettre à jour la commande,
- peut être désinstallé,
- **que vous pouvez utilisez pour vos commandes**.

Vous voulez essayer chez vous?

*Le seul prérequis : avoir installé Docker sur son ordinateur. Allez faire un tour sur [Get Docker](https://www.docker.com/get-docker) si ça n'est pas le cas. La Docker Community Edition est gratuite.*

Voici la ligne d'installation pour notre exemple :

```bash
curl -s https://raw.githubusercontent.com/tducret/amazon-scraper-python/master/amazon2csv \
> /usr/local/bin/amazon2csv && chmod +x /usr/local/bin/amazon2csv
```

Cela télécharge le script et le place dans `/usr/local/bin` (vous pouvez modifier ce chemin par un autre, dans la mesure où il se trouve dans votre $PATH). Enfin, on rend le script exécutable avec `chmod +x`.


Vous pouvez alors exécuter ces commandes dans le terminal pour vérifier le bon fonctionnement :

```bash
amazon2csv --help
amazon2csv --keywords="Python programming" --maxproductnb=2
```

Le script se chargera de faire le *docker run* en lui passant les paramètres demandés.

Pour faire une **mise à jour** (le script se chargera de faire le *docker pull*):

```bash
amazon2csv --upgrade
```

Et pour **désinstaller** le tout (suppression du script et de l'image), il suffit d'appeler :

```bash
amazon2csv --uninstall
```

Je vous invite à regarder [le code source](https://github.com/tducret/amazon-scraper-python/blob/master/amazon2csv) si vous êtes curieux, ou si vous souhaitez vous en servir.

Pour l'utiliser pour votre commande, vous devez simplement modifier la ligne suivante (et renommer le script à votre guise) :

```bash
DOCKER_IMAGE="thibdct/amazon2csv"
```

## Performances

Il est logique de se demander si l'utilisation d'un conteneur pour lancer une commande est performante.

Comparons le temps d'exécution de la commande dans le conteneur avec celle installée normalement.

On exécute la commande `time` suivie de ce que l'on souhaite mesurer.

`time docker run -it --rm amazon2csv --help` *(on teste ici la commande dans le conteneur)*

```bash
real	0m2.265s
user	0m0.160s
sys	0m0.031s
```

`time amazon2csv.py --help` *(ici, la commande est installée de manière classique, sans conteneur)*

```bash
real	0m0.644s
user	0m0.525s
sys	0m0.083s
```

`time docker run -it --rm amazon2csv --keywords="Python programming" --maxproductnb=10`

```bash
real	0m3.903s
user	0m0.160s
sys	0m0.027s
```

`amazon2csv.py --keywords="Python programming" --maxproductnb=10`

```bash
real	0m2.241s
user	0m0.830s
sys	0m0.100s
```

Le temps d'exécution est donc plus long lorsque la commande est dans un conteneur *(mais personne n'est surpris)*.

L'écart de **1,6 secondes** semble se maintenir entre l'exécution directe et celle via un conteneur. Cela correspond certainement au temps de démarrage du conteneur sur mon ordinateur *(vous aurez peut-être une meilleure performance chez vous)*.

A vous de juger si cette perte de performance est acceptable, mais il faut bien sûr la mettre en balance avec le gain de temps sur le plan de la facilité de déploiement de la commande.