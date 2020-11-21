<!-- title: Comment j'automatise mes tests avec Pytest, Travis et Coveralls -->

Lorsque l'on crée un projet en Python, on peut avoir tendance à se focaliser sur le développement des fonctionnalités.

- J'ai un objectif,
- je réfléchis aux fonctions à écrire,
- je les code,
- je les teste,
- je modifie ce qui pose problème,
- et je continue jusqu'à avoir le comportement souhaité.

Le problème avec cette approche, c'est qu'en reprenant le code quelques semaines ou mois plus tard, on ne se souvient plus de certains détails du contenu. On continue, on fait des évolutions... et **CRAC**. Ça ne fonctionne plus comme avant 😭

**D'où vient le problème ?**

Il va falloir analyser pas-à-pas le déroulement du programme, fonction après fonction, paramètre d'entrée après paramètre d'entrée, ligne après ligne...

Au mieux, avec un debugger ([pdb](https://docs.python.org/3/library/pdb.html) en Python). Au pire, en faisant des **print** à des endroits stratégiques (je le sais, je fais pareil !).

La tentation est alors grande de jeter l'éponge si le problème est vraiment complexe.

Je vais vous expliquer dans cet article comment améliorer la maintenabilité de votre code. Ou dit différemment, vous faciliter la vie !

Vous apprendrez comment ajouter des tests à votre projet, qui seront joués automatiquement lors d'une modification de votre code. Vous pourrez ainsi détecter la moindre régression, au plus vite.
En fin d'article, vous pourrez même vérifier le taux de couverture de vos tests. C'est-à-dire le pourcentage de lignes de code par lesquels passent vos tests.

# Pytest

Tester son programme revient à écrire des appels aux fonctions de votre programme, et indiquer la valeur attendue en sortie.

Un outil est alors utilisé pour lire les tests, les exécuter, et vous prévenir si le comportement attendu n'est pas le bon.

Supposons qu'on ait écrit une fonction pour faire la somme de deux nombres :

```python
def addition(a, b):
    return a+b
```

Le test pourrait être le suivant :

```python
def test_addition_2_plus_3():
    assert addition(2,3) == 5
```

`assert` est une notion qui revient souvent dans les tests logiciels. En français, on peut le traduire par *affirmer que*. On utilise `assert` en indiquant derrière le test à vérifier. Il doit être vrai pour que le teste passe.

```python
def test_addition_4_plus_5():
    assert addition(4,5) == 10
    # Ce test va échouer !
```

Il existe plusieurs outils pour exécuter les tests en Python.

Voici mon **TOP 3** :

- [unittest](https://docs.python.org/3/library/unittest.html) : l'outil intégré à Python
- [nose](http://nose.readthedocs.io/en/latest/) : l'outil qui étend les fonctions de unittest
- [pytest](https://docs.pytest.org/en/latest/) : du même type que nose, mais avec une syntaxe différente

Lors de mes recherches, **pytest** a retenu mon attention par sa syntaxe simple et sa compatibilité avec de nombreux outils externes (cf. Travis, que je vous présente un peu plus bas).

![Python Testing with pytest](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/livre_pytest.jpg)

Un très bon livre lui est d'ailleurs dédié : [Python Testing with pytest](http://pythontesting.net/books/pytest/).

 **nose** est vraiment comparable, et il revient à chacun de se faire sa propre idée. 

## Mise en place des tests

Par convention, on crée à la racine du projet un dossier `test`, dans lequel on crée des fichiers de tests du type `test_*.py` (un fichier par thème ou module). Cela permettra à **pytest** de les trouver tout seul.

Voici à quoi ressemble la structure de mon projet [amazon-scraper-python](https://github.com/tducret/amazon-scraper-python/) :

```bash
.
├── .travis.yml
├── Dockerfile
├── LICENSE
├── MANIFEST.in
├── README.md
├── amazon2csv.py
├── amazonscraper
│   ├── __init__.py
│   ├── client.py
├── pytest.ini
├── requirements.txt
├── setup.cfg
├── setup.py
└── test
    └── test_amazonscraper.py
```

On voit justement `test/test_amazonscraper.py`.

Jeton un oeil à l'intérieur de **test_amazonscraper.py** :

```python
import amazonscraper

def test_amazonscraper_get_products_with_keywords():

    products = amazonscraper.search(
                                keywords="Python",
                                max_product_nb=10)

    assert len(products) == 10
```

Ce test permet de vérifier que l'appel à la fonction de recherche (avec le mot-clé "Python" et un nombre de résultats maximal de 10) nous renvoie bien 10 résultats.

Pour exécuter le test, on s'assure tout d'abord d'avoir installé **pytest** :

```bash
pip install -U pytest
```

On se place ensuite dans le répertoire du projet, et on lance la commande `pytest -v` (*v* est l'option *verbose* pour avoir plus de détails).


![Résultat de la commande pytest](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/pytest_test_amazonscraper_get_products_with_keywords.png)

## Mock

*(ajouté le 26/11/2018)*

[`Mock`](https://docs.python.org/dev/library/unittest.mock.html) est un moyen très pratique de tester des fonctions nécessitant des appels à d'autres librairies ou API. Celui-ci **imite** cette fonction en la remplaçant par une fonction de votre choix.

Voici un exemple (récupéré [ici](https://rhodesmill.org/brandon/slides/2014-07-pyohio/clean-architecture/)) qui remplace la requête vers un serveur web (ici une recherche de définition via l'API de DuckDuckGo) par une fonction interne qui renvoie une définition de notre choix.

La fonction originale à tester :

```python
import requests

def find_definition(word):
    q = 'define ' + word
    url = 'http://api.duckduckgo.com/?'
    url += urlencode({'q': q, 'format': 'json'})
    response = requests.get(url)     # <== On va imiter cette fonction
    data = response.json()           # <== ainsi que celle-ci
    definition = data[u'Definition']
    if definition == u'':
        raise ValueError('that is not a word')
    return definition
```

Le test :

```python
from mock import patch

class FakeRequestsLibrary(object):
    def get(self, url):
        self.url = url
        return self
    def json(self):
        return self.data

def test_find_definition():
    fake = FakeRequestsLibrary()
    fake.data = {u'Definition': u'abc'}
    with patch('requests.get', fake.get):  # <== On la remplace ici
        definition = find_definition('testword')

    assert definition == 'abc'
    assert fake.url == (
        'http://api.duckduckgo.com/'
        '?q=define+testword&format=json')
```

> Cette possibilité de test sera particulièrement utile quand vous souhaiterez tester la logique de votre application sans dépendre d'un appel à une API externe (qui pourrait aussi allonger la durée du test).

## Doctest

En plus des tests dans un fichier dédié (du type `test_*.py`), on peut écrire des tests directement dans le code.
On les appelle les **doctest**.

Dans le commentaire de description de la fonction (appelé également *docstring*), il suffit de décrire l'appel à tester (précédé de `>>>`), et le retour attendu.

Reprenons l'exemple de tout à l'heure, où l'on souhaite tester que la fonction **addition** est bien capable de faire `2+3 = 5` :

```python
def addition(a, b):
    """ Fonction qui additionne 2 nombres
    >>> addition(2,3)
    5
    """
    return a+b
```

C'est très pratique, car en plus de donner un exemple d'utilisation pour documenter le code, on vient de créer un test automatisé.

Il suffit alors d'appeler `pytest --doctest-modules` pour que ces doctests soient également joués.

On peut également décrire des cas d'erreurs, par exemple :

```python
def addition(a, b):
    """ Fonction qui additionne 2 nombres
    >>> addition(2,3)
    5
    >>> addition("a",5)
    Traceback (most recent call last):
    ...
    TypeError: must be str, not int
    """
    return a+b
```

*(les `...` entre **Traceback** et **TypeError** permettent de ne pas recopier intégralement l'erreur.)*

![Résultat de la commande pytest avec doctest : OK](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/pytest_doctest_addition_OK.png)

Pour vous montrer ce qui se passerait en cas d'échec d'un test (suite à une régression par exemple), je modifie la valeur attendue pour 2+3, en mettant 6.

Voici le retour, qui indique clairement l'endroit où le test échoue.

![Résultat de la commande pytest avec doctest : NOK](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/pytest_doctest_addition_NOK.png)

## Travis

Nous avons désormais de bonnes bases pour que le code soit plus facile à maintenir. Il suffit d'exécuter régulièrement la commande **pytest** pour s'assurer que tout fonctionne correctement...

Et si on pouvait également automatiser cette étape 🤔

![Travis CI](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/travis.png)

C'est ici qu'entre en jeu [Travis CI](https://travis-ci.org/).

Le principe de tester régulièrement le code n'est pas nouveau : on parle d'intégration continue.

Néanmoins, **Travis** présente l'avantage d'être très simple d'utilisation et gratuit pour les projets open source.

Dans votre projet, vous rajoutez un fichier `.travis.yml`, avec les consignes d'installation et de lancement des tests.
Voici à quoi ça ressemble pour un de mes projets :

```yml
language: python
python:
  - "3.6"
# Commande pour installer votre code
install:
  - pip install .
# Commandes pour installer les dépendances
before_script:
  - pip install -r requirements.txt
# Commande pour exécuter les tests
script:
  - pytest
```

Rendez-vous ensuite sur [le site de Travis-CI](https://travis-ci.org/) pour vous inscrire (via les identifiants de votre compte Github).

Vous pourrez alors choisir les repository des projets Github à tester.

![Sélection des projets à tester sur Travis](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/travis_selection_repository.png)

Il suffit alors de faire un commit pour déclencher les tests sur Travis.

![Visualisation du déroulement des tests sur travis-ci.org](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/build_travis.png)

Et si jamais cela ne se passait pas comme prévu, vous recevez un petit mail :

![Exemple de mail envoyé par Travis quand une modification de code provoque une erreur](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/mail_travis_build_broken.png)

Ce n'est qu'un aperçu, les possibilités sont très nombreuses :

- plusieurs types de serveurs de tests
- plusieurs versions de Python
- dépôt du package généré sur Pypi
- déploiement automatique
- envoi de notifications (email, IRC, Slack, webhooks...)

Plus d'infos sur [la documentation Travis](https://docs.travis-ci.com/user/getting-started/)

## Coveralls

Un dernier point à regarder de près quand on fait des tests : la couverture de code.
Il s'agit d'analyser par quelles lignes passent vos tests... et par quelles lignes ils ne passent pas.
On fait alors un rapport entre le nombre de lignes *couvertes* et le nombre de lignes total.
On obtient un pourcentage : le taux de couverture de code, qui donne une indication sur la qualité des tests sur le projet.
Un projet avec 50% de taux de couverture de code donne une mauvaise image, car les tests mis en place passent seulement par la moitié des lignes de code. On risque de garder de nombreux morceaux de code obsolètes, sans le savoir, jusqu'au jour où...

On peut faire cette analyse très facilement avec **pytest** et le plugin **pytest-cov**.

```bash
pip install pytest-cov
```

Exemple d'utilisation : 

```bash
pytest --cov=myproj tests/

-------------------- coverage: ... ---------------------
Name                 Stmts   Miss  Cover
----------------------------------------
myproj/__init__          2      0   100%
myproj/myproj          257     13    94%
myproj/feature4286      94      7    92%
----------------------------------------
TOTAL                  353     20    94%
```

Pas mal du tout, mais on peut faire mieux !

![Coveralls.io](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/coveralls.png)

Un service existe sur le web pour faciliter cette analyse : [Coveralls](http://coveralls.io/)

C'est également gratuit pour les projets open source, et on peut s'inscrire avec son compte Github.

En connectant Coveralls à Travis, on peut générer l'analyse de couverture de code automatiquement.

Pour cela, on ajoute simplement quelques lignes de plus dans `.travis.yml`

```yml
language: python
python:
  - "3.6"
# Commande pour installer votre code
install:
  - pip install .
# Commandes pour installer les dépendances
before_script:
  - pip install -r requirements.txt
  - pip install python-coveralls
  - pip install pytest-cov
# Commande pour exécuter les tests
script:
  - pytest
# Commande pour envoyer les résultats de couverture de code à coveralls.io
after_success:
  coveralls
```

J'ai également ajouté un fichier `pytest.ini` au même endroit, pour que pytest puisse récupérer ses paramètres d'appel :

```
[pytest]
addopts = --doctest-modules --cov amazonscraper
```

Après chaque commit sur Github, Travis va installer le code, exécuter tous mes tests, et envoyer la couverture de code à Coveralls. Je peux alors connaitre mon taux de couverture sur Coveralls, et analyser les lignes non couvertes :

![Lignes non couvertes sur Coveralls](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/coveralls_lignes_non_couvertes.png)

Dans mon cas, il s'agit d'un cas bien particulier : la gestion d'une exception en cas d'échec de communication SSL avec les serveurs d'Amazon. C'est donc difficile à tester de manière automatique (car ça n'est pas systématique).
On peut néanmoins simuler ce comportement pour les tests à l'aide de [**Mock**](#mock).

![Badges sur Github](/assets/article_images/2018-06-24-comment-j-automatise-mes-tests-avec-pytest-travis-et-coveralls/badges_github.png)

**BONUS** : Vous pouvez alors afficher fièrement l'état des tests et la couverture de votre code, sur la page Github de votre projet. Les badges seront mis à jour dynamiquement à chaque modification de votre programme.

![Test successful](https://media.giphy.com/media/vq4q4LqJv3Qcg/giphy.gif)

Si vous ne voulez manquer aucun article, soyez notifié directement dans votre boite mail [en vous inscrivant à la newsletter](http://bit.ly/newsletter-tducret)