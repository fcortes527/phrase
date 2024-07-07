# Phrase
## CS194 Team 3

[Link to Wiki](https://github.com/StanfordCS194/Win24-Team3/wiki)

## General Coding Practices
* Don't push to main
* Develop on your own branch and pull request on your branch
* Two reviewers for pull requests before merging with Main

## General Norms
1. Document anything you're working as as Git Issue. Assign everyone!
2. Document any bugs you encounter as as Git Issue.  Assign everyone!
3. Anytime you're working on your own branch AND DON'T PUSH, send a demo video update to the team.
4. Dissolve the use of teams. More in-person, live coding sessions.
5. Everyone react to demo videos and updates so that we acknowledge each other's work.
6. In general, hold grace and compassion to one another. Realize that effort doesn't always reflect in the code base.

## To update your local code from our repo
```
git checkout main
```
Make sure all of your changes on your old branch are stashed or git committed

```
git pull 
```
Make sure you are on your main branch when pulling 

## To make a pull request from your branch to main
```
git add .

git commit -m "SOME DESCRIPTIVE MESSAGE IN THE PRESENT TENSE ABOUT YOUR CODE"

git push
```

## If  your project doesn't build try
```
XCode --> Product --> Clean Build Folder
```
This refactors your project directory 
