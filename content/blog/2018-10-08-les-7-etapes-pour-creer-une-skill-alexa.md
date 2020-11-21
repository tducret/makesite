<!-- title: Les 7 étapes pour créer une skill Alexa -->

Les assistants vocaux sont de plus en plus présents dans nos vies. Google Home, Siri, Alexa : les géants du web ont tous développé leur solution. Les services offerts par ces assistants se multiplient. *Dans le jargon d'Amazon, ces services sont appelés **skills**.* Il existe des skills pour écouter la radio, piloter votre installation domotique... et même demander une [blague de Chuck Norris](http://www.blague-chuck-norris.fr/page1.html).

Aujourd'hui, il en existe plus de 10 000 aux Etats-Unis. En France, tout reste à faire. Nous sommes à un moment clé de ce nouveau marché *(un peu comme quand [Steve Jobs avait annoncé aux développeurs l'ouverture de l'App Store sur iPhone](https://www.youtube.com/watch?v=xo9cKe_Fch8))*.

De plus, je suis sûr que la skill de vos rêves n'a pas encore été créée.

Bref, ce sont deux bonnes raisons pour **créer une skill Alexa vous-même** !

> Nota : il n'est pas nécessaire d'avoir une enceinte connectée pour développer une skill et la tester

---

#### 📖 Table des matières

[Étape 1 - Trouver une idée](#Étape-1---trouver-une-idée)

[Étape 2 - Définir l'interaction](#Étape-2---définir-linteraction)

[Étape 3 - Configurer l'interaction](#Étape-3---configurer-linteraction)

[Étape 4 - Coder la fonction](#Étape-4---coder-la-fonction)

[Étape 5 - Charger la fonction sur Lambda](#Étape-5---charger-la-fonction-sur-lambda)

[Étape 6 - Tester](#Étape-6---tester)

[Étape 7 - Publier votre skill sur Amazon store](#Étape-7---publier-votre-skill-sur-amazon-store)

---

# Étape 1 - Trouver une idée

Toutes les idées ne sont pas forcément adaptées pour un assistant vocal.

D'après Amazon, votre projet est **intéressant pour Alexa** si c'est un service :

- Rapide
- Facile
- Fun

![Boutique de skills Alexa en France](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/store_france.png)

Pour vous inspirer, vous pouvez aller jeter un oeil sur le store [français](https://www.amazon.fr/alexa-skills/b/ref=sd_allcat_k_a2s_all?ie=UTF8&node=13944548031), [anglais](https://www.amazon.co.uk/alexa-skills/b/ref=nav_shopall_k_a2s_all?ie=UTF8&node=10068517031) ou [américain](https://www.amazon.com/alexa-skills/b/ref=sd_allcat_ods_ha_con_skills_st?ie=UTF8&node=13727921011).

# Étape 2 - Définir l'interaction

Lorsque vous créez un **logiciel classique**, vous définissez les entrées et sorties de vos fonctions.

Par exemple, pour une fonction qui renvoie les prochains passages de bus à un arrêt :

```python
prochains_passages = demander_prochains_passages(nom_arret)
```

Ici, `nom_arret` est l'entrée, `prochains_passages` est la sortie.

Lorsqu'il s'agit d'une **skill Alexa**, vous devrez définir *l'interaction* avec l'utilisateur. C'est-à-dire sa façon de dialoguer avec l'assistant vocal pour obtenir les informations souhaitées.

Pour le même exemple, cela pourrait être :

- Quel est le prochain bus à l'arrêt *Ramonville*?
- Quand passe le prochain bus à l'arrêt *Ramonville*?
- Prochain bus à l'arrêt *Ramonville*?

Alexa pourrait alors répondre :

> A l'arrêt *Ramonville*, le prochain bus *79* à destination de *Labège Couder* passera dans *5* minutes.


Vous trouverez plus de détail pour cette étape dans le [guide de conception d'Amazon](https://developer.amazon.com/designing-for-voice/design-process/#establish-the-purpose-and-user-stories)

# Étape 3 - Configurer l'interaction

> À partir de cette étape, vous aurez besoin d'un compte **Alexa Developer** et d'un autre pour **Amazon Web Services (AWS) Lambda**.
> Je ne vais pas détailler la partie création de compte, mais voici les liens utiles : [Console Alexa Developer](https://developer.amazon.com/alexa/console/ask) et [Création d'un compte AWS](https://portal.aws.amazon.com/billing/signup#/start)

### Création de la skill

Rendez-vous sur le [portail de développement Alexa](https://developer.amazon.com/alexa/console/ask), où nous allons créer cette nouvelle skill.

Cliquez sur le bouton **Create Skill**, entrez le nom souhaité, la langue, et laissez l'option **Custom** sélectionnée.

Cliquez alors de nouveau sur le bouton **Create Skill**.

![Fenêtre de création de la skill Alexa](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/creation_skill.png)

Vous arrivez à la fenêtre de configuration de skill suivante :

![Console de développement de votre skill](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/accueil_console_creation_skill.png)

### Définition de l'invocation

Pour commencer, nous allons choisir le ou les mots que l'utilisateur devra prononcer pour appeler la skill.

Cliquez sur **Invocation** dans le menu de gauche, saisissez votre choix (ici : *bus toulouse*), et cliquez sur **Save Model** pour sauvegarder.

![Choix de l'invocation de la skill](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/invocation_skill.png)

Cela va permettre d'appeler votre skill en disant par exemple :

- Alexa, ouvre la skill *Bus Toulouse*
- Alexa, lance *Bus Toulouse*
- Alexa, active la skill *Bus Toulouse*

### Création des intents

A partir de maintenant, nous allons définir le format des requêtes orales de l'utilisateur. Amazon parle de **intents** (*intentions* en français).

> Pour tout le jargon linguistique d'Amazon, j'ai créé un lexique [ici](#lexique)

Dans le menu de gauche, à côté de *Intents*, cliquez sur **Add**. Donnez-lui un nom (par exemple : `demande_prochains_passages_a_un_arret`) et cliquez sur **Create custom intent**.

![Ajout d'un intent](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/ajout_intent.png)

Dans *Sample Utterances*, vous pouvez désormais entrer les phrases possibles. *Utterance* signifie en français *énoncé* ou *déclaration*.

Pour notre exemple, nous pouvons reprendre les questions définies plus haut... **à un détail près.**

Et oui, l'utilisateur ne va pas demander les prochains passages à *Ramonville* à chaque fois.

C'est là qu'intervient la notion de **slot**, sorte de variable dans la phrase.

On entre donc : *Quel est le prochain bus à l'arrêt `{arret_bus}`*

> Nota : Amazon ne veut pas du point d'interrogation dans nos questions

![Ajout d'une utterance avec un slot](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/ajout_utterance.png)

La console de développement détecte que le slot `{arret_bus}` n'existe pas encore. On clique sur **Add**.

On entre alors les deux autres phrases :

- Quand passe le prochain bus à l'arrêt `{arret_bus}`
- Prochain bus à l'arrêt `{arret_bus}`

![A la fin de la saisie des utterances](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/fin_ajout_utterances.png)

### Définition du type de slot

On voit dans la capture précédente que le slot `{arret_bus}` n'a pas de *Slot type* associé.

On peut regarder les types disponibles en français. *Et oui, ils sont spécifiques à chaque langue. Il y aura donc probablement plus de types de slots en anglais.*

![Types de slots](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/slot_types.png)

> Vous trouverez plus d'infos sur les types standards d'Amazon sur la page [Slot type reference](https://developer.amazon.com/fr/docs/custom-skills/slot-type-reference.html)

Dans notre cas, nous allons créer un nouveau type de slot **liste_arrets_bus**. Il contiendra la liste des noms de tous les arrêts de bus possibles.

Pour cela, cliquez sur le bouton **Add** à côté de *Slot Types* dans le menu de gauche.

Saisissez alors le nom du type de slot (**liste_arrets_bus**) et cliquez sur **Create custom slot type**.

Vous pouvez alors ajouter les valeurs possibles une à une.

> Il est également possible d'ajouter une longue liste ou un fichier csv, en cliquant sur le bouton **Bulk Edit**.

![Définition des valeurs du type de slot](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/definition_slot_type.png)

Sauvegardez ce type en cliquant sur le bouton du haut **Save Model**.

Vous pouvez alors retourner sur l'*intent* `demande_prochains_passages_a_un_arret` *(en cliquant dessus dans le menu de gauche, sous **Intents**)*.

Puis, sélectionnez le type de slot **liste_arrets_bus** pour le slot `{arret_bus}`.

Quand tout est prêt, cliquez sur le bouton du haut **Save Model**, puis **Build Model**.

---

#### Lexique

- **Invocation** (*invocation*) : c'est le ou les mots d'appel de la skill *(ex : 🗣️ bus toulouse)*
- **Intent** (*intention*) : c'est une fonctionnalité mise à disposition pour les utilisateurs *(ex : `demande_prochains_passages_a_un_arret`)*. Il regroupe une ou plusieurs *utterances*.
- **Utterance** (*énoncé*) : c'est une phrase prononcée par un utilisateur *(ex : Quel est le prochain bus à l'arrêt XXX)*
- **Slot** (*emplacement*) : c'est une sorte de variable, que l'on peut inclure dans les *utterances* *(ex : Quel est le prochain bus à l'arrêt `{arret_bus}`?, où `{arret_bus}` est le slot)*

*Retour au chapitre [Création des intents](#création-des-intents)*

# Étape 4 - Coder la fonction

La partie de [configuration de la skill](#Étape-3---configurer-linteraction) étant terminée, **il va falloir coder !**

> Pour cet article, nous parlerons uniquement du Python. Néanmoins, il est également possible de développer ses applications en [NodeJS](https://github.com/alexa/alexa-skills-kit-sdk-for-nodejs) et [Java](https://github.com/alexa/alexa-skills-kit-sdk-for-java).

J'utilise le [SDK Python officiel d'Amazon](https://github.com/alexa/alexa-skills-kit-sdk-for-python) pour coder l'application. Il existe aussi le projet [Flask Ask](https://github.com/johnwheeler/flask-ask), mais je crains qu'il ne soit plus maintenu régulièrement (suite à l'arrivée du SDK officiel ?).

Pour prendre en main le fonctionnement d'une application pour Alexa, je vous conseille de suivre les tutoriels du SDK :

- [Hello World](https://github.com/alexa/skill-sample-python-helloworld-decorators)
- [Color Picker](https://github.com/alexa/skill-sample-python-colorpicker)
- [Fact](https://github.com/alexa/skill-sample-python-fact)
- rendez-vous [ici](https://github.com/alexa/alexa-skills-kit-sdk-for-python#samples) pour les autres

Pour notre exemple, faisons un zoom sur la fonction principale *(et les commentaires pointés par ☝)* :

```python
@sb.request_handler(can_handle_func=is_intent_name(
    "demande_prochains_passages_a_un_arret"))
# ☝ On retrouve bien le nom de l'intent défini à l'étape 3

def demande_prochains_passages_a_un_arret(handler_input):
    slots = handler_input.request_envelope.request.intent.slots

    if arret_bus_slot in slots:
        arret_bus_demande = slots["arret_bus"].value
    # ☝ On récupère le nom de l'arrêt dans le slot {arret_bus}

    liste_p = prochains_passages(stop_area_name=arret_bus_demande)
    # ☝ On appelle la fonction qui renvoie les prochains passages

    if len(liste_p) < 1:
        speech = "Dans les prochaines heures, \
aucun passage prévu à l'arrêt {}.".format(arret_bus_demande)
# ☝ La variable **speech** contiendra la phrase qui sera prononcée par Alexa

    else:
        speech = "A l'arrêt {}, ".format(arret_bus_demande)
        for p in liste_p:
            if p is None:
                speech = "Dans les prochaines heures, \
    aucun passage prévu à l'arrêt {}.".format(arret_bus_demande)
            else:
                speech += "Le bus {}, à destination de {}, passera dans {}.".format(
                	p.ligne, p.destination, p.timedelta_str)

    handler_input.response_builder.speak(speech)
    return handler_input.response_builder.response
```

Si vous voulez voir le code complet, allez sur la page du projet [bus toulouse](https://github.com/tducret/alexa-skill-bus-toulouse) ou directement sur le code [bus_toulouse.py](https://github.com/tducret/alexa-skill-bus-toulouse/blob/master/bus_toulouse.py).

![Cookiecutter](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/cookiecutter.png)
Si vous connaissez [Cookiecutter](https://github.com/audreyr/cookiecutter), j'ai créé un template [Alexa skill en Python](https://github.com/tducret/cookiecutter-alexa-skill-python) pour créer un nouveau projet rapidement.

# Étape 5 - Charger la fonction sur Lambda

Lambda permet d'héberger des fonctions dans le cloud d'Amazon. Pas besoin d'allouer de serveur, de configurer des OS, de faire du load balancing, etc. Vous vous contentez de charger votre fonction (ici notre application Alexa) et Lambda vous fournit une url unique pour l'appeler.

Mieux, comme Lambda et Alexa sont développés par Amazon, leur intégration est facilitée.

![Amazon Lambda](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/lambda.png)

### Création de la fonction Lambda

Connectez-vous sur [la console Lambda](https://eu-west-1.console.aws.amazon.com/lambda/home?region=eu-west-1#/functions).

> Nota : l'intégration Lambda<>Alexa n'est pas disponible dans tous les datacenters européens. Je vous conseille donc celui d'Irlande.

Cliquez sur le bouton **Créer une fonction**, puis :

- laissez l'option **Créer à partir de zéro**
- **Nom** : le nom de votre fonction (ici *alexa-skill-bus-toulouse*)
- **Exécution** : Python 3.6
- **Rôle** : pour votre première fonction, vous devrez créer un rôle. Sélectionnez donc **Créer un rôle à partir de modèles**
- **Nom du rôle** : comme vous voulez, par exemple *role-alexa-skill*
- **Modèles de stratégie** : choisissez **Autorisations Microservice**
- cliquez enfin sur le bouton **Créer une fonction**

Patientez quelques instants pendant la création de la fonction.

### Configuration

Une fois sur la page de la fonction, cliquez sur **Alexa Skills Kit** dans le menu de gauche **Ajouter des déclencheurs**.

![Configuration Lambda](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/configuration_lambda.png)

Vous devrez alors ajouter l'identifiant de votre skill et cliquer sur **Ajouter**.

Cet identifiant peut être récupéré dans le menu **Endpoint** de la console de développement Alexa (pas Lambda).

![Sélection du menu Endpoint sur la console de développement Alexa](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/selection_endpoint.png)

C'est le champ **Your Skill ID** dans *AWS Lambda ARN*.

Vous devriez avoir quelque-chose qui ressemble à ça.

![Configuration du déclencheur sur Lambda](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/configuration_declencheur_Lambda.png)

En retour, vous pouvez configurer l'identifiant de le fonction Lambda dans la console de développement Alexa.

L'identifiant de la fonction peut être obtenu en haut à droite de la console Lambda (du type : *arn:aws:lambda:eu-west...*)

Votre console de développement Alexa devrait alors ressembler à ça :

![Configuration du endpoint sur la console de développement Alexa](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/configuration_endpoint.png)

N'oubliez pas de cliquer sur le bouton **Save Endpoints**.

### Ajout du code

Plus bas, vous trouverez la partie **Code de fonction**. C'est ici que vous allez charger votre application.

Le plus simple est de zipper vos codes sources et dépendances, et de choisir l'option **Charger un fichier ZIP** dans le menu *Type d'entrée de code*.

> Les pages [ajout de ask-sdk à votre projet](https://alexa-skills-kit-python-sdk.readthedocs.io/en/latest/GETTING_STARTED.html#adding-the-ask-sdk-for-python-to-your-project) et [créer un package de déploiement Python dans Lambda](https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example-deployment-pkg.html#with-s3-example-deployment-pkg-python) pourront vous aider.

Quand vous en aurez assez de faire les zip à la main, vous pourrez scripter tout ça.

Pour la skill Bus Toulouse, j'ai créé le script [package.sh](https://github.com/tducret/alexa-skill-bus-toulouse/blob/master/package.sh).

Une fois chargée, vous pouvez cliquer sur **Enregistrer** en haut à droite pour sauvegarder la fonction.

# Étape 6 - Tester

Pour tester une skill, cliquez sur le bouton **Test** dans la barre du haut de la console de développement Alexa.

![Test sur la console de développement Alexa](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/test_console_alexa.png)

Vous pouvez alors interagir avec votre skill à l'écrit ou avec votre micro.

[Cette page Amazon](https://developer.amazon.com/fr/docs/devconsole/test-your-skill.html) détaille les possibilités offertes par ce simulateur.

# Étape 7 - Publier votre skill sur Amazon store

Vous touchez maintenant au but !

Une fois que vos tests sont concluants, vous pouvez publier votre skill sur [le store d'Amazon](https://www.amazon.fr/alexa-skills/b/ref=sd_allcat_k_a2s_all?ie=UTF8&node=13944548031).

Pour cela, cliquez sur le bouton **Distribution** dans le menu du haut.

Vous devrez alors définir les caractéristiques de votre skill et ajouter une icône.

> Astuce : pour créer facilement et rapidement une icône de skill Alexa (ronde, avec les 2 tailles demandées). Amazon a créé [Icon Builder](https://developer.amazon.com/fr/docs/tools/icon-builder.html)

![Publication de la skill sur Amazon](/assets/article_images/2018-10-08-les-7-etapes-pour-creer-une-skill-alexa/publication_skill.png)

[Cette page](https://developer.amazon.com/fr/docs/custom-skills/certification-requirements-for-custom-skills.html) rappelle les contraintes à respecter pour publier votre skill.

---

Voilà, il ne reste plus qu'à patienter quelques heures pour que les équipes d'Amazon certifient votre skill.

Vous la verrez alors apparaitre sur le store un peu plus tard.

N'hésitez pas à tester [Bus Toulouse](https://www.amazon.fr/gp/product/B07HFC8NHF) et laissez un avis [⭐⭐⭐⭐⭐](https://www.amazon.fr/review/create-review/ref=cm_cr_dp_d_wr_but_btm?ie=UTF8&channel=glance-detail&asin=B07HFC8NHF)

---

Retour à la [📖 table des matières](#-table-des-matières)

Si vous ne voulez manquer aucun article, soyez notifié directement dans votre boite mail [en vous inscrivant à la newsletter](http://bit.ly/newsletter-tducret)