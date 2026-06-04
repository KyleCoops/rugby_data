# Rugby medallion lakehouse

## Overview
A rugby medallion data lakehouse project to answer any and all of your burning Rugby data questions.

The first step in this project is an MVP using a single data source to establish a local, end-to-end lakehouse setup to answer one question: what are the win statistics between rugby's greatest rivalry (South Africa vs New Zealand)?

## Getting Started

### Prerequisites
- Python 3.12+
- [uv](https://docs.astral.sh/uv/) (package manager)
- git

### Install dependencies
```bash
uv sync
```

### Download the data
Download `results.csv` from [Kaggle](https://www.kaggle.com/datasets/lylebegbie/international-rugby-union-results-from-18712022) and place it in the `data/` directory.

### Initialize the database
Run all cells in `setup_db.ipynb` to create the `silver_3nf.duckdb` schema.

### Run the pipeline
Run all cells in `explore.ipynb` in order. This processes data through bronze → silver → 3NF.

### Run dbt
```bash
DBT_PROFILES_DIR=./dbt dbt run --project-dir dbt
```

---

## Pipeline Overview
![Text](diagrams/mvp_pipline.png)

### Bronze
- landing stage: The accept-all stage, no-friction entry for data into the data lakehouse
- raw stage: Silver structure-aligned data, detecting schema changes

### Silver
- source aligned: Deduplicated, cleaned, confirmed data aligned to each source
- 3NF: Point-in-time single source of truth records

### Gold
- Data marts serving analytical questions.

## Design decisions

1. Two-stage bronze (landing & raw)
Allows for quickly identifying schema drift from a source. The process from landing to raw focuses on the shape and volume of the data, to detect potential data source issues quickly.

2. A silver source-aligned zone and silver 3NF canonical layer that allows for survivorship between the same entities from multiple sources. This ensures that additional sources added in subsequent steps will have a survivorship step. Also a good opportunity to practice 3NF data modelling.

3. Technology stack (Jupyter notebook, uv, duckdb, polars, dbt). A modern, local stack that requires minimal setup without containerization or extensive resource use on a laptop. Polars syntax is similar to PySpark, reinforcing the practice, and DuckDB serves as the database requiring no installation.

## Data quality & lineage
Data lineage is stored throughout the process through each layer with associated metadata fields stored per row of data. This allows each row to track the full lineage, version of code, and run that produced it. The metadata is as follows:

- Pipeline id: Unique identifier of the code version (git SHA).
- Run id: Unique identifier for each pipeline run (UUID).
- Bronze source: Text field of the source.
- Bronze landing date ingested: The date the row was ingested into the bronze landing zone.
- Bronze raw date ingested: The date the row was ingested into the bronze raw zone.
- Silver source processed: The date the row was processed into the silver source-aligned zone.
- Source 3nf processed: A combination of all the rows for a source, used for source-side changes.
- Silver integrated hash: Hash key of an attribute in the silver 3NF model.

## AI usage

The purpose of this project was learning and reinforcing data engineering practices and principles, not speed. No AI agents were used in the creation of this project.

## Data Sources
|  Source |  Link | File  |
|---|---|---|
|  Kaggle | https://www.kaggle.com/datasets/lylebegbie/international-rugby-union-results-from-18712022  | results.csv  |

## Roadmap
1. MVP (minimal data, contains the bones of full medallion architecture)
2. Productionize from notebook to data pipelines on Databricks
3. Fix known data issues — competition and stadiums
4. Add canonical sources for country, stadium
5. Add additional Kaggle rugby datasets
6. Scrape data results from r/rugbyunion
