# README #

### Build Status ###
[![Build Status](https://travis-ci.com/mccdci/pokemon.svg?token=t3yyqTToqYEDSgkyWYXi&branch=main)](https://travis-ci.com/mccdci/pokemon)

In order to fully understand and experience this subject as well as completely grasp how wide-spread it (is and) can be, an example project will be documented on the following pages.

### The Project ###
A Pokémon iOS app and a specialised pipeline for it. The app itself is straightforward in the sense that it utilises the open-source API from pokeapi and is designed with UIKit - the images below give more insight into this part of the documentation.

In the updated app after refactoring, users will be able to ​register and login​.

After logging in the user is presented with the homescreen, where the user’s ​favourite pokémons​ are listed. Upon selecting a pokémon, an image of it and some details about it are displayed. Moreover, the user will have the possibility to remove the pokémon from the list of favourites.

The pokémon list shows ​all pokémons​ available. Also here, pokémon details are present upon tapping on a pokémon as well as adding the selected pokémon to the list of favourites.

Finally, it is also possible to check/update information on a ​settings​ page. There only the password can be edited, the user can log out or delete his/her account from this screen as well.

## Nice-to-have #1: ##
The pokémon can only be added to the favourites list, if the list contains not more than 6 pokémons

## Nice-to-have #2: ##
The user can search for specific pokémons via a search bar

### The Pipeline ###
As for the tools used to create the pipeline, they include, but are not limited to TravisCI, BitBucket, Firestore, etc.

### The Setup ###
Start by cloning the project’s repository from bitbucket:

remember to change the ‘USERNAME’ with your account name

​git clone https://USERNAME@bitbucket.org/mccdci/pokemon-pipeline.git​

