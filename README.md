# Projet : reproducibility

**Auteur :** Thomas Sol Dourdin

"reproducibility" est un projet reproductible type, mis au point pour préparer un café data LIENSs dédié à la reproductibilité.

## Données

Le projet utilise un jeu de données unique, `Allo.tsv`, contenant 6 variables et 201 observations :

| Variable    | Type      | Description                                              |
|-------------|-----------|------------------------------------------------------------|
| `Station`   | character | Nom des stations d'échantillonnage                        |
| `Espece`    | character | Nom des espèces échantillonnées                            |
| `Lot`       | integer   | Numéro du lot d'échantillonnage                            |
| `Longueurs` | numeric   | Longueur mesurée de la coquille (cm)                       |
| `PSI`       | numeric   | Valeur de quelque chose...                                 |
| `IC`        | numeric   | Indice de condition des individus                          |

## Environnement d'analyse original

Le nettoyage, le traitement et la visualisation des données ont été réalisés sous R :

```
R version 4.5.2 (2025-10-31)
Platform: x86_64-apple-darwin20
Running under: macOS Tahoe 26.5
```

Les dépendances exactes (versions de packages) sont figées dans `renv.lock`, et le pipeline d'analyse est géré avec le package `targets` (voir `Reproducibility_targets.R` et `_targets.yaml`). Le rapport final est un document Quarto (`report/article/Article.qmd`) rendu en `.docx`.

## Reproduire l'analyse dans votre environnement local

Si votre environnement est le même ou proche de celui utilisé pour le projet (cf. section "Environnement d'analyse original"), vous pouvez simplement cloner ce dépôt GitHub :

```bash
git clone https://github.com/TSolDour/reproducibility.git
cd reproducibility
```

Ouvrez le projet *reproducibility.Rproj* et executez la commande `renv::restore()`. Cela ré-installera le librairie projet automatiquement. Quelques erreurs peuvent survenir lors de l'installation - suivez les indications de renv et tout se passera bien !

Ensuite, ouvrez le script *reproducibility_target.R*, exécutez **Ctrl+A** puis **Ctrl+enter**. Ensuite, exécutez les commandes suivantes:

```r
Sys.setenv(TAR_PROJECT="reproducibility")
tar_make()
```

Ainsi les outputs du pipeline devraient se trouver dans les dossiers *results/plot* et *report/article*.

## Reproduire l'analyse avec Docker

Pour éviter tout problème lié à la version de R, de Quarto, ou des packages installés en local, l'ensemble de l'environnement est fourni sous forme d'image Docker.

### Option 1 — Récupérer l'image déjà construite (recommandé)

```bash
docker pull ghcr.io/tsoldour/reproducibility:1.0
```

Cette image est un instantané figé de l'environnement original : elle garantit un résultat identique, même si les dépôts externes (CRAN, PPM, Quarto) venaient à évoluer avec le temps.

### Option 2 — Reconstruire l'image depuis le code source

```bash
git clone https://github.com/TSolDour/reproducibility.git
cd reproducibility
docker build -t reproducibility .
```

Cette option permet d'inspecter exactement comment l'environnement est construit (voir le `Dockerfile`), au prix d'un temps de build plus long (installation de R, compilation des packages, téléchargement de Quarto).

### Lancer l'analyse

Le pipeline (`targets::tar_make()`) s'exécute automatiquement au démarrage du conteneur. Pour récupérer les résultats sur votre machine, montez les dossiers de sortie en volumes :

```bash
docker run --rm \
  -v $(pwd)/dockerOutput/results/:/project/results \
  -v $(pwd)/dockerOutput/report/article:/project/report/article \
  reproducibility
```

*(Remplacez `reproducibility` par `ghcr.io/tsoldour/reproducibility:1.0` si vous utilisez l'image publiée.)*

À la fin de l'exécution, vous trouverez sur votre machine :

- **`results/`** : les objets et graphiques produits par le pipeline `targets` (ex. `results/plots`).
- **`report/article/`** : l'article rendu au format Word (`Article.docx`).

### Explorer l'image sans lancer le pipeline

Pour inspecter l'arborescence du projet ou lancer R interactivement, sans exécuter `targets::tar_make()` :

```bash
docker run --rm -it --entrypoint bash Reproducibility
```

## Structure du projet

```
Reproducibility/
├── Dockerfile              # Environnement reproductible (R, Quarto, dépendances système)
├── renv.lock                # Versions exactes des packages R
├── Reproducibility_targets.R          # Définition du pipeline targets
├── _targets.yaml            # Configuration du pipeline (projet "gasar")
├── data/
│   └── Allo.tsv              # Jeu de données brut
├── R/                        # Fonctions R utilisées par le pipeline
├── report/
│   └── article/
│       └── Article.qmd       # Document Quarto (rendu en .docx)
└── results/                  # Sorties générées par le pipeline (créées à l'exécution)
```

## Licence

Licence-code : MIT
Licence-données et article : CC-BY-4.0
