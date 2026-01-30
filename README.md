# LexTALE Shiny App
This repository contains an R **Shiny** implementation of the **LexTALE vocabulary knowledge test** (Lemhöfer & Broersma, 2012).  
The app presents a series of words and non-words one at a time. For each item, participants must indicate whether they believe the item is a real word in the target language.


## About the LexTALE test

LexTALE was devleoped by Lemhöfer & Broersma (2012) as a quick and reliable alternative to traditional vocabulary tests. It is widely used in psycholinguistics and second language research.

**Reference**:

> Lemhöfer, K., & Broersma, M. (2012). LexTALE: A quick and valid lexical test of vocabulary knowledge in multiple languages. *Behavior Research Methods, 44*(2), 325–343. [https://doi.org/10.3758/s13428-011-0146-0](https://doi.org/10.3758/s13428-011-0146-0)

This app is **not an official distribution** of LexTALE. I share this simple implementation in R in case it useful for other researchers Please respect and acknowledge the work of the test's orignal creators (Lemhöfer & Broersma, 2012). 

---

## Features

* Web-based Shiny interface
* Random participant ID generation
* Word-by-word presentation with progress bar
* Automatic scoring following LexTALE conventions
* Response-level and participant-level data saving
* Easily adaptable to different languages

---

## Repository structure

```
.
├── app.R                         # Main Shiny application
├── words.csv                     # Stimulus list (words and non-words) - edit these to use versions other than English
├── instructions_for_test_takers.txt  # Instructions shown to participants (HTML allowed)
├── responses.csv                 # (Generated) Item-level responses
├── participant_summary.csv       # (Generated) Participant-level summary
└── README.md
```

---

## Requirements

You will need **R** (version ≥ 4.0 recommended) and the following R packages:

* `shiny`
* `digest`

Install missing packages with:

```r
install.packages(c("shiny", "digest"))
```

---

## Running the app locally

1. Clone or download this repository.
2. Set your working directory to the repository folder.
3. Run the app.


## Running on Shiny Server

This app can also be deployed on Shiny Server (an open source version is available).

1. Copy the repository folder to your Shiny Server apps directory (typically /srv/shiny-server/).

2. Ensure the main app file is named app.R.

3. Make sure the following files are present in the same directory:

* app.R

* words.csv

* instructions_for_test_takers.txt

4. Check that the Shiny Server  has write permissions for the app directory, as the app writes output files (responses.csv and participant_summary.csv).

5. Restart Shiny Server

The app will then be available at:

http://<server-address>/<app-folder-name>/

For multi-user or production deployments, you may wish to redirect data output to a database or a user-specific directory to avoid file locking issues.


## Input files

### `words.csv`

This file defines the test items. It must contain at least the following columns:

* `WORD` – the stimulus shown to participants
* `STATUS` – `1` for real words, `0` for non-words
* `INDEX` – non-zero values indicate scored items (items with `0` are ignored in scoring)

To use a different language version of LexTALE, replace this file with the appropriate stimulus list.

### `instructions_for_test_takers.txt`

This file contains the instructions shown before the test starts. HTML markup is allowed, making it easy to format text or add emphasis. You can translate or modify this file to suit your study.

---

## Output files

After a participant completes the test, two files are created (or responses are appended to):

### `responses.csv`

Item-level responses, including:

* participant ID
* stimulus word
* response (Yes/No)
* correctness
* timestamp

### `participant_summary.csv`

Participant-level summary data, including:

* LexTALE score (percentage)
* number of words correctly identified
* number of non-words correctly identified
* test duration (seconds)
* timestamp

---

## Scoring

The LexTALE score is calculated as:

* Percentage correct for **words** (40 items)
* Percentage correct for **non-words** (20 items)
* Final score = average of the two percentages

This follows the procedure described by Lemhöfer & Broersma (2012).

---

## How to cite this implementation

If you use or adapt this Shiny implementation in academic work, please cite both:

# The original LexTALE paper:

>Lemhöfer, K., & Broersma, M. (2012). LexTALE: A quick and valid lexical test of vocabulary knowledge in multiple languages. Behavior Research Methods, 44(2), 325–343. https://doi.org/10.3758/s13428-011-0146-0

# This software implementation:

>Rees, G. P. (2026). LexTALE-R: An R Shiny implementation of the LexTALE vocabulary test. GitHub repository: https://github.com/GeraintRees/LexTALE-R/

